module conv_seq_to_parallel #(
    parameter C_ROW_SIZE = 8,
    parameter p_dataBits = 8,
    parameter p_rows = 3,
    parameter p_cols = 3
)(
    input wire i_clk,
    input wire i_rst,

    input wire [p_dataBits-1:0] data_in,
    input wire valid_in,
    input wire sof_in,
    output wire busy_out,

    output reg [p_rows*p_cols*p_dataBits-1:0] data_out,
    output reg valid_out,
    output wire sof_out,
    input wire busy_in
);



wire [p_rows*p_cols*p_dataBits-1:0] data_out_next;
wire stalled = busy_in;
assign busy_out = stalled;

wire [p_dataBits*(p_rows)-1:0] row_in;
wire [p_rows-1:0] row_valid_in;
assign row_in[p_dataBits-1:0] = (!stalled && valid_in)?data_in:0;
assign row_valid_in[0] = (!stalled && valid_in);
wire [p_cols*p_rows-1:0] valid_out_shift;


localparam lp_sift_out_bits = C_ROW_SIZE*(p_rows-1)+p_cols+1;
reg [lp_sift_out_bits-1:0] sof_out_shift;

reg valid_in_reg;

assign sof_out = (valid_out)?sof_out_shift[lp_sift_out_bits-1]:0;

always @(posedge i_clk) begin
    valid_in_reg <= (stalled)?0:valid_in;
    if (i_rst) begin
        data_out <= 0;
        valid_out <= 0;
        sof_out_shift <= 0;
    end // if (i_rst)
    else begin
        data_out <= data_out_next;
        if(!valid_out && (valid_in || valid_in_reg))
            valid_out <= &valid_out_shift;
        else begin
            if(!stalled && !valid_in_reg) valid_out <= 0;
        end
        if(valid_in) begin
            sof_out_shift[lp_sift_out_bits-1:0] <= {sof_out_shift[lp_sift_out_bits-2:0], sof_in};
        end
    end // else
end // always @(posedge i_clk)

genvar i;
genvar j;
generate
    for (i = 0; i < p_rows; i = i + 1) begin
        reg [p_dataBits*C_ROW_SIZE-1:0] row_shift;
        reg [C_ROW_SIZE-1:0] row_valid;

        assign valid_out_shift[(i+1)*p_cols-1-:p_cols] = row_valid[p_cols-1:0];

        if(i < p_rows-1) begin
            assign row_in[p_dataBits*(i+2)-1 -: p_dataBits] = row_shift[p_dataBits*C_ROW_SIZE-1 -: p_dataBits];
            assign row_valid_in[i+1] = row_valid[C_ROW_SIZE-1];
        end


        assign data_out_next[i*p_rows*p_dataBits+p_cols*p_dataBits-1 -: p_cols*p_dataBits] = row_shift[p_cols*p_dataBits-1:0];

        always @(posedge i_clk) begin
            if (i_rst) begin
                row_shift <= 0;
                row_valid <= 0;
            end // if (i_rst)
            else begin
                if(!stalled && valid_in) begin
                    row_shift[p_dataBits*C_ROW_SIZE-1:p_dataBits] <= row_shift[p_dataBits*C_ROW_SIZE-1-p_dataBits:0];
                    if(sof_in) begin
                        row_valid[C_ROW_SIZE-1:1] <= 0;
                    end else begin
                        row_valid[C_ROW_SIZE-1:1] <= row_valid[C_ROW_SIZE-2:0];
                    end
                    row_shift[p_dataBits-1:0] <= row_in[p_dataBits*(i+1)-1 -: p_dataBits];
                    row_valid[0] <= row_valid_in[i];
                end // if(!stalled)
            end // else
        end
    end
endgenerate

endmodule