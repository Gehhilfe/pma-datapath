module datapath_gray #(
    parameter C_ROW_SIZE = 8
)(
    input wire i_clk,
    input wire i_rst,

    input wire [8*3-1:0] data_in,
    input wire valid_in,
    input wire sof_in,
    output wire busy_out,

    output wire [7:0] data_out,
    output wire valid_out,
    output wire sof_out,
    input wire busy_in
);


wire stalled = busy_in;
assign busy_out = stalled;

wire [7:0] red   = data_in[ 0 +: 8];
wire [7:0] green = data_in[ 8 +: 8];
wire [7:0] blue  = data_in[16 +: 8];

wire [5:0] red_constant = 19;
wire [6:0] green_constant = 75;
wire [3:0] blue_constant = 3;

wire [8+6-1:0] red_m;
wire [7:0] red_m_round = red_m[8+6-1:6];
mul #(
    .a_bits (8),
    .b_bits (6)
    ) mul_r (
    .i_clk(i_clk),
    .i_a  (red),
    .i_b  (red_constant),
    .o_q  (red_m)
);

wire [8+7-1:0] green_m;
wire [7:0] green_m_round = green_m[8+7-1:7];
mul #(
    .a_bits (8),
    .b_bits (7)
    ) mul_g (
    .i_clk(i_clk),
    .i_a  (green),
    .i_b  (green_constant),
    .o_q  (green_m)
);

wire [8+4-1:0] blue_m;
wire [7:0] blue_m_round = blue_m[8+4-1:4];
mul #(
    .a_bits (8),
    .b_bits (4)
) mul_b (
    .i_clk(i_clk),
    .i_a  (blue),
    .i_b  (blue_constant),
    .o_q  (blue_m)
);

wire [7:0] blueplusgreen;

add #(
    .a_bits (8),
    .b_bits (8),
    .q_bits (8)
) add_lower (
    .i_clk(i_clk),
    .i_a  (green_m_round),
    .i_b  (blue_m_round),
    .o_q  (blueplusgreen)
);

reg [7:0] red_delayed [0:3];

always @(posedge i_clk) begin
	red_delayed[0] <= red_m_round;
	red_delayed[1] <= red_delayed[0];
	red_delayed[2] <= red_delayed[1];
end

wire [8:0] gray;

wire [7:0] gray_capped;

add #(
    .a_bits (8),
    .b_bits (8),
    .q_bits (9)
) add_upper (
    .i_clk(i_clk),
    .i_a  (red_delayed[2]),
    .i_b  (blueplusgreen),
    .o_q  (gray)
);

assign gray_capped = (gray[8])?8'hFF:gray[7:0];

localparam lp_delay_valid = 10;

reg [lp_delay_valid-1:0] valid_delay;
reg [lp_delay_valid-1:0] sof_delay;

always @(posedge i_clk) begin
	if(i_rst) begin
		valid_delay <= 0;
		sof_delay <= 0;
	end else begin
		valid_delay[0] <= valid_in;
		sof_delay[0] <= sof_in;

		valid_delay[lp_delay_valid-1:1] <= valid_delay[lp_delay_valid-2:0];
		sof_delay[lp_delay_valid-1:1] <= sof_delay[lp_delay_valid-2:0];
	end
end


shiftbuffer #(
	.p_stages(18),
	.p_width(9)
) end_shifter (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_stall(stalled),
	.in({gray_capped, sof_delay[lp_delay_valid-1]}),
	.in_valid(valid_delay[lp_delay_valid-1]),
	.out({data_out, sof_out}),
	.out_valid(valid_out)
);

endmodule // datapath_gray
