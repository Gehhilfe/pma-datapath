module tb_gray();


reg clk, rst, valid_in, sof_in;
reg [7:0] data_in;
wire busy_out, valid_out, sof_out;
reg busy_in;


datapath_gray dut(
    .i_clk(clk),
    .i_rst    (rst),
    .data_in(data_in),
    .valid_in(valid_in),
    .sof_in(sof_in),
    .busy_out (busy_out),

    .data_out (data_out),
    .valid_out(valid_out),
    .sof_out  (sof_out),
    .busy_in  (busy_in)
);

initial begin
    clk = 0;
    rst = 1;
    valid_in = 0;
    sof_in = 0;
    busy_in = 0;
    #100;
    rst = 0;
    @(posedge clk);
    valid_in = 1;
    data_in = 8'h0;
    sof_in = 1;
    @(posedge clk);
    sof_in = 0;
    data_in = 8'h0;
    @(posedge clk);
    data_in = 8'h0;
    @(posedge clk);
    valid_in = 1;
    data_in = 8'hFF;
    @(posedge clk);
    data_in = 8'hFF;
    @(posedge clk);
    data_in = 8'hFF;
    @(posedge clk);

    data_in = 8'h0;
    @(posedge clk);
    data_in = 8'h0;
    @(posedge clk);
    data_in = 8'h0;
    @(posedge clk);
    data_in = 8'hFF;
    @(posedge clk);
    data_in = 8'hFF;
    @(posedge clk);
    data_in = 8'hFF;
    @(posedge clk);

     data_in = 8'h0;
    @(posedge clk);
    data_in = 8'h0;
    @(posedge clk);
    data_in = 8'h0;
    @(posedge clk);
    data_in = 8'hFF;
    @(posedge clk);
    data_in = 8'hFF;
    @(posedge clk);
    data_in = 8'hFF;
    @(posedge clk);

     data_in = 8'h0;
    @(posedge clk);
    data_in = 8'h0;
    @(posedge clk);
    data_in = 8'h0;
    @(posedge clk);
    data_in = 8'hFF;
    @(posedge clk);
    data_in = 8'hFF;
    @(posedge clk);
    data_in = 8'hFF;
    @(posedge clk);


    valid_in = 0;
    busy_in = 1;
    #100
    @(posedge clk);
    busy_in = 0;
    valid_in = 1;
    data_in = 8'h1F;
    @(posedge clk);
    data_in = 8'h3F;
    @(posedge clk);
    data_in = 8'h7F;
    @(posedge clk);
    valid_in = 0;
    #80
    @(posedge clk);
    busy_in = 1;
    #80
    @(posedge clk);
    busy_in = 0;
    #80
    @(posedge clk);
    busy_in = 1;
    #80
    @(posedge clk);
    busy_in = 0;
    #80
    $stop();
end

always
    #5 clk = !clk;


endmodule // tb