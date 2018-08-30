module datapath_gray #(
    parameter C_ROW_SIZE = 8
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


wire stalled = busy_in;
assign busy_out = stalled;

reg [2:0] r_color_ctr;

reg [7:0] r_red, r_green, r_blue;
reg [24-1:0] r_blue_q;

localparam lp_sof_delay = 12;
reg [lp_sof_delay-1:0] r_sof_delay;

localparam lp_dataout_buffer_len = 8;
reg [lp_dataout_buffer_len*8-1:0] r_data_out;
reg [lp_dataout_buffer_len-1:0] r_data_out_valid;
reg [lp_dataout_buffer_len-1:0] r_data_out_sof;

localparam lp_pipe_color_ctr_bits = 4*3;
localparam lp_result_out_delay_bits = 6;
reg [lp_pipe_color_ctr_bits-1:0] pipe_color_ctr;
reg [lp_result_out_delay_bits-1:0] pipe_result_delay;

wire [5:0] red_constant = 19;
wire [6:0] green_constant = 75;
wire [3:0] blue_constant = 3;


// MUX Constant to mul
// one hot encoded
reg [6:0] a_mul_a_muxed;
wire [7+8-1:0] a_mul_q;
always @(*) begin
    case (r_color_ctr)
        3'b001:  a_mul_a_muxed = {1'b0, red_constant};
        3'b010:  a_mul_a_muxed = green_constant;
        3'b100:  a_mul_a_muxed = {2'b0, blue_constant};
        default: a_mul_a_muxed = {1'b0, red_constant};
    endcase // r_color_ctr
end

mul #(
    .a_bits (7),
    .b_bits (8)
    ) mul_a (
    .i_clk(i_clk),
    .i_a  (a_mul_a_muxed),
    .i_b  (data_in),
    .o_q  (a_mul_q)
);

// DEMUX
reg red_en;
reg green_en;
reg blue_en;


wire [7:0] redplusgreen;

add #(
    .a_bits (8),
    .b_bits (8),
    .q_bits (8)
) add_a (
    .i_clk(i_clk),
    .i_a  (r_red),
    .i_b  (r_green),
    .o_q  (redplusgreen)
);


wire [7:0] gray;

add #(
    .a_bits (8),
    .b_bits (8),
    .q_bits (8)
) add_b (
    .i_clk(i_clk),
    .i_a  (redplusgreen),
    .i_b  (r_blue),
    .o_q  (gray)
);

always @(*) begin 
    {blue_en, green_en, red_en} <= pipe_color_ctr[lp_pipe_color_ctr_bits-1:lp_pipe_color_ctr_bits-3];
end


shiftbuffer #(
	.p_stages(18),
	.p_width(9)
) end_shifter (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_stall(stalled),
	.in({gray, r_sof_delay[lp_sof_delay-1]}),
	.in_valid(pipe_result_delay[lp_result_out_delay_bits-1]),
	.out({data_out, sof_out}),
	.out_valid(valid_out)
);

always @(posedge i_clk) begin
    if (i_rst) begin
        r_color_ctr <= 3'b001;
        pipe_result_delay <= 0;
        pipe_color_ctr <= 0;
    end // if (i_rst)
    else begin
        if(!stalled && valid_in) begin
            r_color_ctr[0] <= r_color_ctr[2];
            r_color_ctr[2:1] <= r_color_ctr[1:0];
        end

        pipe_color_ctr <= {pipe_color_ctr[lp_pipe_color_ctr_bits-4:0], r_color_ctr};

        pipe_result_delay <= {pipe_result_delay[lp_result_out_delay_bits-2:0], blue_en};
        r_sof_delay <= {r_sof_delay[lp_sof_delay-2:0], sof_in};

        r_blue_q <= {r_blue_q[15:0], r_blue};

        if(red_en)   r_red   <= a_mul_q[7+8-1 -: 8];
        if(green_en) r_green <= a_mul_q[7+8-1 -: 8];
        if(blue_en)  r_blue  <= a_mul_q[7+8-1 -: 8];
    end // else
end


endmodule // datapath_gray
