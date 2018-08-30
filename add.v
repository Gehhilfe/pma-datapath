module add
#(
    parameter latency = 3,
    parameter a_bits = 32,
    parameter b_bits = 32,
    parameter q_bits = 32
)(
    input wire               i_clk,
    input wire  [a_bits-1:0] i_a,
    input wire  [b_bits-1:0] i_b,
    output wire [q_bits-1:0] o_q
);

reg [q_bits-1:0] r_lat [latency-1:0];

assign o_q = r_lat[latency-1];

integer i;
always @(posedge i_clk) begin
    r_lat[0] <= i_a + i_b;
    for(i=1; i < latency; i = i + 1) begin
        r_lat[i] <= r_lat[i-1];
    end // for(i=1; i < latency; i = i + 1)
end


endmodule