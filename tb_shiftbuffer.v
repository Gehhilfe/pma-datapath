module tb_shiftbuffer();

reg clk, rst, stall, in_valid;
reg [7:0] in;

wire out_valid;
wire [7:0] out;

shiftbuffer #(
	.p_stages(7),
	.p_width(8)
) dut (
	.i_clk(clk),
	.i_rst(rst),
	.i_stall(stall),
	.in(in),
	.in_valid(in_valid),
	.out(out),
	.out_valid(out_valid)
);

initial begin
    clk = 0;
    rst = 1;
    stall = 0;
    in = 0;
    in_valid = 0;
    #100;
    rst = 0;
    
    @(posedge clk);
    in = 1;
    in_valid = 1;
    @(posedge clk);
    in = 2;
    in_valid = 1;
    @(posedge clk);
    in = 3;
    in_valid = 1;
    stall = 1;
    @(posedge clk);
    in = 4;
    in_valid = 1;
    stall = 1;
    @(posedge clk);
    in_valid = 0;
    #10000;
    @(posedge clk);
    in = 5;
    in_valid = 1;
    stall = 0;
    @(posedge clk);
    in_valid = 0;
    @(posedge clk);
    in_valid = 0;
    @(posedge clk);
    in_valid = 0;
    @(posedge clk);
    in = 6;
    in_valid = 1;
    stall = 1;
    @(posedge clk);
    in_valid = 0;
    stall = 0;
    #100
    $stop();
end

always
    #5 clk = !clk;


endmodule
