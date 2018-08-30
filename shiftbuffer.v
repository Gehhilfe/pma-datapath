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
reg [p_width*p_stages-1:0] shifter_new_stalled;
reg [p_stages-1:0] valid_shifter;
reg [p_stages-1:0] valid_shifter_new_stalled;

assign out_valid = valid_shifter[p_stages-1];
assign out = shifter[p_width*p_stages-1 -: p_width];

integer i;

reg found;

always @(*) begin
	shifter_new_stalled = shifter;
	valid_shifter_new_stalled = valid_shifter;
	found = 0;
	if(in_valid) begin
		for(i=p_stages-1; i >= 0; i = i - 1) begin
			if (!valid_shifter_new_stalled[i+1]) begin
				shifter_new_stalled[(i+1)*p_width-1 -: p_width] = shifter[i*p_width-1-:p_width];
				shifter_new_stalled[i*p_width-1 -: p_width] = 0;
				valid_shifter_new_stalled[i+1] = valid_shifter[i];
				valid_shifter_new_stalled[i] = 0;
			end
		end
		shifter_new_stalled[p_width-1:0] = in;
		valid_shifter_new_stalled[0] = 1;
		for(i=0; i < p_stages-1; i = i + 1) begin
			if (!valid_shifter_new_stalled[i]) begin
				found = 1;
			end
			if (found) begin
				shifter_new_stalled[i*p_width-1 -: p_width] = shifter[i*p_width-1 -: p_width];
				valid_shifter_new_stalled[i] = valid_shifter[i];
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
			shifter <= shifter_new_stalled;
			valid_shifter <= valid_shifter_new_stalled;
		end else begin
			if (in_valid) begin
				shifter <= {shifter[p_width*(p_stages-1)-1:0], in};
				valid_shifter <= {valid_shifter[(p_stages)-2:0], in_valid};
			end else begin
				shifter <= {shifter[p_width*(p_stages-1)-1:0], {p_width{1'b0}}};
				valid_shifter <= {valid_shifter[(p_stages)-2:0], 1'b0};
			end
		end
	end
end

endmodule
