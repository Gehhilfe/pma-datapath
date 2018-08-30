module tb();


reg clk;
reg [31:0] a, b;
wire [31:0] q;

mul dut(
    .i_clk(clk),
    .i_a  (a),
    .i_b  (b),
    .o_q  (q)
);

initial begin
    clk = 0;
    a = 4;
    b = 2;
end

always
    #5 clk = !clk;


endmodule // tb