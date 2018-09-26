
class transaction;

	rand bit [8-1:0] a00;
	rand bit [8-1:0] a10;
	rand bit [8-1:0] a20;
	rand bit [8-1:0] a01;
	rand bit [8-1:0] a11;
	rand bit [8-1:0] a21;
	rand bit [8-1:0] a02;
	rand bit [8-1:0] a12;
	rand bit [8-1:0] a22;
	bit [8-1:0] result;


	function bit[8-1:0] expectedResultGX();
		begin
			
			int ia00 = a00;
			int ia10 = a10;
			int ia20 = a20;
			int ia01 = a01;
			int ia11 = a11;
			int ia21 = a21;
			int ia02 = a02;
			int ia12 = a12;
			int ia22 = a22;

			int i =  (ia00 + (ia01<<1) + ia02 -ia20 -(ia21<<1) -ia22);
			i = i+4*255;
			i = i/8;
			expectedResultGX = i;
		end
	endfunction

	function bit[8-1:0] expectedResultGY();
		begin
			
			int ia00 = a00;
			int ia10 = a10;
			int ia20 = a20;
			int ia01 = a01;
			int ia11 = a11;
			int ia21 = a21;
			int ia02 = a02;
			int ia12 = a12;
			int ia22 = a22;

			int i =  (ia00 + (ia10<<1) + ia20 -ia02 -(ia12<<1) -ia22);
			i = i+4*255;
			i = i/8;
			expectedResultGY = i;
		end
	endfunction

	task setAll(bit[8-1:0] in);
	  a00 = in;
	  a10 = in;
	  a20 = in;
	  a01 = in;
	  a11 = in;
	  a21 = in;
	  a02 = in;
	  a12 = in;
	  a22 = in;
	endtask

endclass


class generator;

	rand transaction trans;
	mailbox gen2driv;
	int  repeat_count; 
	event ended;

	function new(mailbox gen2driv, event ended);
		this.gen2driv = gen2driv;
		this.ended = ended;
	endfunction

	task main();
		repeat(repeat_count) begin
			trans = new();
			if (!trans.randomize()) $fatal("gen:: trans randomization failed");
			gen2driv.put(trans);
		end
		-> ended;
	endtask

endclass


interface sobel_intf(input logic clk, reset);
	logic [9*8-1:0] data_in;
	logic data_valid;
	logic busy_out;
	logic valid_out;
	logic [8-1:0] result_gx;
	logic [8-1:0] result_gy;

	clocking driver_cb @(posedge clk);
		default input #1 output #1;
		output data_in;
		output data_valid;
		input busy_out;
		input result_gx;
		input result_gy;
		input valid_out;
	endclocking

	clocking monitor_cb @(posedge clk);
		default input #1 output #1;
		input data_in;
		input data_valid;
		input busy_out;
		input result_gx;
		input result_gy;
		input valid_out;
	endclocking


	modport DRIVER (clocking driver_cb,input clk,reset);
	modport MONITOR (clocking monitor_cb,input clk,reset);
endinterface : sobel_intf

class driver;
	virtual sobel_intf sobel_vif;

	mailbox gen2driv;

	function new(virtual sobel_intf sobel_vif, mailbox gen2driv);
		this.sobel_vif = sobel_vif;
		this.gen2driv = gen2driv;
	endfunction

`define DRIV_IF sobel_vif.DRIVER.driver_cb 

	task reset;
		wait(sobel_vif.reset);
		$display("--------- [DRIVER] Reset Started ---------");
		`DRIV_IF.data_in <= 0;
		`DRIV_IF.data_valid <= 0;
		wait(!sobel_vif.reset);
  		$display("--------- [DRIVER] Reset Ended -----------");
  	endtask

  	int no_transactions;

  	task drive;
  		no_transactions <= 0;
  		forever begin
  			transaction trans;
  			`DRIV_IF.data_in <= 0;
  			`DRIV_IF.data_valid <= 0;
  			gen2driv.get(trans);
  			$display("--------- [DRIVER-TRANSFER: %0d] ---------", no_transactions);
  			@(posedge sobel_vif.clk);
  			`DRIV_IF.data_in <= {trans.a00, trans.a10, trans.a20, trans.a01, trans.a11, trans.a21, trans.a02, trans.a12, trans.a22};
  			`DRIV_IF.data_valid <= 1;
			wait(!`DRIV_IF.busy_out);
			@(posedge sobel_vif.clk);
			`DRIV_IF.data_valid <= 0;
			@(posedge sobel_vif.clk);
			wait(`DRIV_IF.valid_out);
			$display("\tRESULT_GX = %d", `DRIV_IF.result_gx);
			$display("\tEXP_GX = %d", trans.expectedResultGX());
			$display("\tRESULT_GY = %d", `DRIV_IF.result_gy);
			$display("\tEXP_GY = %d", trans.expectedResultGY());
			assert (`DRIV_IF.result_gx == trans.expectedResultGX()) else $error("It's gone wrong");
			assert (`DRIV_IF.result_gy == trans.expectedResultGY()) else $error("It's gone wrong");
			$display("-----------------------------------------");
  			no_transactions++;
  		end // forever
  	endtask	
endclass

class environment;
	generator 			gen;
	driver 				driv;
	mailbox     		gen2driv;
	event 	    		gen_ended;
	virtual sobel_intf 	sobel_vif;

	function new(virtual sobel_intf sobel_vif);
		this.sobel_vif  = sobel_vif;
		gen2driv 		= new();
		gen 			= new(gen2driv, gen_ended);
		driv 			= new(sobel_vif, gen2driv);
	endfunction

	task pre_test();
	  transaction trans;
	  for(int i = 0; i < 255; i++) begin
	  	trans = new();
	  	trans.setAll(i);
	  	gen2driv.put(trans);
	  end
	  driv.reset();
	endtask
	 
	task test();
	  fork
	    gen.main();
	    driv.drive();
	  join_any
	endtask
	 
	task post_test();
	  wait(gen_ended.triggered);
	  wait(gen.repeat_count == driv.no_transactions);
	endtask

	task run;
	  pre_test();
	  test();
	  post_test();
	  $finish;
	endtask
endclass

program test(sobel_intf intf);
	environment env;
	 
	initial begin
	  env = new(intf);
	  env.gen.repeat_count = 100000;
	  env.run();
	end
endprogram


module tbench_top;

	bit clk;
	bit reset;

	always #5 clk = ~clk;

	initial begin
		reset = 1;
		#50 reset = 0;
	end

	sobel_intf intf(clk, reset);

	sobel_gx_gy DUT (
		.i_clk    (clk),
		.i_rst    (reset),
		.busy_out (intf.busy_out),
		.valid_in (intf.data_valid),
		.valid_out(intf.valid_out),
		.data_out_gx (intf.result_gx),
		.data_out_gy (intf.result_gy),
		.data_in  (intf.data_in)
	);

	test t1(intf);
endmodule // tbench_top