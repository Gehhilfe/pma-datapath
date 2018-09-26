module tb_conv_seq_to_parllel();

reg clk, rst, stall, in_valid, in_sof;

reg [7:0] in;

wire busy_out, valid_out, sof_out;
reg busy_in;
wire [71:0] out;

conv_seq_to_parallel dut(
    .i_clk(clk),
    .i_rst    (rst),
    .data_in(in),
    .valid_in(in_valid),
    .sof_in(in_sof),
    .busy_out (busy_out),

    .data_out (out),
    .valid_out(valid_out),
    .sof_out  (sof_out),
    .busy_in  (busy_in)
);

integer i;

initial begin
    clk = 0;
    rst = 1;
    in_valid = 0;
    in_sof = 0;
    busy_in = 0;
    #100;
    rst = 0;
    @(posedge clk);
    in_sof = 1;
    in_valid = 1;
    in = 0;
    @(posedge clk);
    in_sof = 0;
    for (i = 1; i < 100; i = i + 1) begin
        in_valid = 1;
        in = i%9'b100000000;
        @(posedge clk);
    end
    for (i = 100; i < 200; i = i + 1) begin
        in_valid = 1;
        in = i%9'b100000000;
        @(posedge clk);
        in_valid = 0;
        in = i%9'b100000000;
        @(posedge clk);
    end
    for (i = 200; i < 210; i = i + 1) begin
        in_valid = 1;
        in = i%9'b100000000;
        busy_in = 1;
        @(posedge clk);
        #20
        @(posedge clk);
        busy_in = 0;
        @(posedge clk);
    end

    in_valid = 0;
    #80
    $stop();
end

always
    #5 clk = !clk;

endmodule // tb_conv_seq_to_parllel