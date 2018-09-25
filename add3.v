module add3
#(
    parameter latency = 3,
    parameter a_bits = 32,
    parameter b_bits = 32,
    parameter c_bits = 32,
    parameter q_bits = 32
)(
    input wire               i_clk,
    input wire  [a_bits-1:0] i_a,
    input wire  [b_bits-1:0] i_b,
    input wire  [c_bits-1:0] i_c,
    output wire [q_bits-1:0] o_q
);

reg [q_bits-1:0] r_lat [latency-1:0];

reg [c_bits-1:0] r_ic [latency-1:0];

wire [q_bits-1:0] apb = r_lat[latency-1];

integer i;
always @(posedge i_clk) begin
    r_lat[0] <= i_a + i_b;
    r_ic[0] <= i_c;
    for(i=1; i < latency; i = i + 1) begin
        r_lat[i] <= r_lat[i-1];
        r_ic[i] <= r_ic[i-1];
    end // for(i=1; i < latency; i = i + 1)
end

reg [q_bits-1:0] r_lat_2 [latency-1:0];
assign o_q = r_lat_2[latency-1];

always @(posedge i_clk) begin
    r_lat_2[0] <= apb + r_ic[latency-1];
    for(i=1; i < latency; i = i + 1) begin
        r_lat_2[i] <= r_lat_2[i-1];
    end // for(i=1; i < latency; i = i + 1)
end

endmodule