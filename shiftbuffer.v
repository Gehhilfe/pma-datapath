module shiftbuffer #(
	parameter p_stages = 6,
	parameter p_width = 32
)(
	input wire i_clk,
	input wire i_rst,
	input wire i_stall,
	input wire [p_width-1:0] in,
	input wire in_valid,
	output wire [p_width-1:0] out,
	output wire out_valid
);

reg [p_width*p_stages-1:0] shifter;
reg [p_width*p_stages-1:0] shifter_new;
reg [p_stages-1:0] valid_shifter;
reg [p_stages-1:0] valid_shifter_new;

assign out_valid = valid_shifter[p_stages-1];
assign out = shifter[p_width*p_stages-1 -: p_width];

integer i;

reg found;
reg [p_stages-1:0] shiftstages;

always @(*) begin
	valid_shifter_new = valid_shifter;
	shifter_new = shifter;
	shiftstages = 0;
	found = 0;
	if(in_valid) begin
		for(i=p_stages-1; i >= 0; i = i - 1) begin
			if (!valid_shifter_new[i] && !found) begin
				found = 1;
				shifter_new[i*p_width +: p_width] = in;
				valid_shifter_new[i] = 1;
			end
		end
	end
end

always @(posedge i_clk) begin
	if (i_rst) begin
		shifter <= 0;
		valid_shifter <= 0;
	end else begin
		if (i_stall) begin
			shifter <= shifter_new;
			valid_shifter <= valid_shifter_new;
		end else begin
			if(valid_shifter[p_stages-1]) begin
				shifter <= {shifter_new[p_width*(p_stages-1)-1:0], {p_width{1'b0}}};
				valid_shifter <= {valid_shifter_new[(p_stages)-2:0], 1'b0};
			end else begin
				shifter <= shifter_new;
				valid_shifter <= valid_shifter_new;
			end	
		end
	end
end

endmodule
