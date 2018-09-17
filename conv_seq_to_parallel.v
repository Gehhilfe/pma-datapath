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

    output wire [p_rows*p_cols*p_dataBits-1:0] data_out,
    output wire valid_out,
    output wire sof_out,
    input wire busy_in
);


wire stalled = busy_in;
assign busy_out = stalled;

wire [p_dataBits*(p_rows+1)-1:0] row_in;
assign row_in[p_dataBits-1:0] = data_in;

genvar i;
genvar j;
generate
    for (i = 0; i < p_rows; i = i + 1) begin
        reg [p_dataBits*C_ROW_SIZE-1:0] row_shift;
        reg [C_ROW_SIZE-1:0] row_valid;

        assign row_in[p_dataBits*(i+1)-1 -: p_dataBits] = row_shift[p_dataBits*C_ROW_SIZE-1 -: p_dataBits];


        for (j = 0; j < p_cols; j = j +1) begin
            assign data_out[i*p_cols*p_dataBits+(j+1)*p_dataBits-1 :- p_dataBits] = row_shift[j*p_dataBits-1 -: p_dataBits];
        end // for(j = 0; j < p_cols; j = j +1)

        always @(posedge i_clk) begin
            if (i_rst) begin
                row_shift <= 0;
            end // if (i_rst)
            else begin
                if(!stalled && valid_in) begin
                    row_shift[p_dataBits*C_ROW_SIZE-1:p_dataBits] <= row_shift[p_dataBits*C_ROW_SIZE-1-p_dataBits:0];
                    if(sof_in) begin
                        row_valid[C_ROW_SIZE-1:1] <= 0;
                    end else begin
                        row_valid[C_ROW_SIZE-1:1] <= row_valid[C_ROW_SIZE-2:0];
                    end
                    row_shift[p_dataBits-1:0] <= row_in[p_dataBits*i-1 -: p_dataBits];
                    row_valid[0] <= 1;
                end // if(!stalled)
            end // else
        end
    end
endgenerate

endmodule