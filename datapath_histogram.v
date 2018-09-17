module datapath_histogram #(
    parameter p_bins = 30
)(
    input wire i_clk,
    input wire i_rst,

    input wire [7:0] data_in,
    input wire valid_in,
    input wire sof_in,
    output wire busy_out,

    output wire [7:0] data_out,
    output wire valid_out,
    output wire sof_out,
    input wire busy_in
);

wire [15:0] a_mul_q;
wire [7:0] bin = a_mul_q[15:8];
wire stalled = busy_in;

reg [3:0] valid_q;

mul #(
    .a_bits (8),
    .b_bits (8)
    ) mul_a (
    .i_clk(i_clk),
    .i_a  (p_bins-1),
    .i_b  (data_in),
    .o_q  (a_mul_q)
);

shiftbuffer #(
    .p_stages(18),
    .p_width(8)
) end_shifter (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_stall(stalled),
    .in(bin),
    .in_valid(valid_q[3]),
    .out(data_out),
    .out_valid(valid_out)
);

always @(posedge i_clk) begin
    if (i_rst) begin
        valid_q <= 0;
    end else begin
        valid_q[0] <= valid_in;
        valid_q[3:1] <= valid_q[2:0];
    end 
end // always @(posedge i_clk)

endmodule