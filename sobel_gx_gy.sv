module sobel_gx_gy#(
    parameter p_data_bits = 8
) (
    input wire i_clk,
    input wire i_rst,

    output reg busy_out,
    input wire valid_in,
    input wire [9*p_data_bits-1:0] data_in,

    output reg valid_out,
    output logic [p_data_bits-1:0] data_out_gx,
    output logic [p_data_bits-1:0] data_out_gy
);


typedef enum {IDLE, START_A, START_B, START_C, START_D, WAIT_A, WAIT_B, DONE} States;
typedef enum {A,B,C,D,UNWIND} AdderInput;
States cur_state, next_state;

logic save_data;
logic save_gx;
logic save_gy;
reg [9*p_data_bits-1:0] r_data;

wire [p_data_bits-1:0] a00 = r_data[9*p_data_bits-1 -: p_data_bits];
wire [p_data_bits-1:0] a10 = r_data[8*p_data_bits-1 -: p_data_bits];
wire [p_data_bits-1:0] a20 = r_data[7*p_data_bits-1 -: p_data_bits];

wire [p_data_bits-1:0] a01 = r_data[6*p_data_bits-1 -: p_data_bits];
wire [p_data_bits-1:0] a11 = r_data[5*p_data_bits-1 -: p_data_bits];
wire [p_data_bits-1:0] a21 = r_data[4*p_data_bits-1 -: p_data_bits];

wire [p_data_bits-1:0] a02 = r_data[3*p_data_bits-1 -: p_data_bits];
wire [p_data_bits-1:0] a12 = r_data[2*p_data_bits-1 -: p_data_bits];
wire [p_data_bits-1:0] a22 = r_data[1*p_data_bits-1 -: p_data_bits];


logic [2*p_data_bits-1:0] adder1_a;
logic [2*p_data_bits-1:0] adder1_b;
logic [2*p_data_bits-1:0] adder1_c;
logic [2*p_data_bits-1:0] adder1_q;
logic [2*p_data_bits-1:0] adder1_q_lat;

AdderInput adder1_input;

add3 #(
 .a_bits (p_data_bits*2),
 .b_bits (p_data_bits*2),
 .c_bits (p_data_bits*2),
 .q_bits (p_data_bits*2)
) add_a (
    .i_clk(i_clk),
    .i_a  (adder1_a),
    .i_b  (adder1_b),
    .i_c  (adder1_c),
    .o_q  (adder1_q)
);

logic [2*p_data_bits-1:0] adder2_q;

wire [2*p_data_bits-1:0] add_middle_const = 4*((2**p_data_bits)-1);

add #(
 .a_bits (p_data_bits*2),
 .b_bits (p_data_bits*2),
 .q_bits (p_data_bits*2)
) add_middle (
    .i_clk(i_clk),
    .i_a  (adder1_q),
    .i_b  (add_middle_const),
    .o_q  (adder2_q)
);

reg [7:0] wait_ctr, next_wait_ctr;

always_comb begin
    case(adder1_input)
        A: begin
            adder1_a = a00;
            adder1_b = a01<<1;
            adder1_c = a02;
        end

        B: begin
            adder1_a = -a20;
            adder1_b = -a21<<1;
            adder1_c = -a22;
        end

        C: begin
            adder1_a = a00;
            adder1_b = a10<<1;
            adder1_c = a20;
        end

        D: begin
            adder1_a = -a02;
            adder1_b = -a12<<1;
            adder1_c = -a22;
        end

        UNWIND: begin
            adder1_a = adder1_q_lat;
            adder1_b = adder1_q;
            adder1_c = 0;
        end
    endcase // adder1_input 
end

always_comb begin
    busy_out = 1;
    save_data = 0;
    adder1_input = A;
    next_wait_ctr = (|wait_ctr)?wait_ctr-1'b1:0;
    valid_out = 0;
    next_state = cur_state;
    save_gx = 0;
    save_gy = 0;
    case (cur_state)
        IDLE: begin
            busy_out = 0;
            if(valid_in) begin
                next_state = START_A;
                save_data = 1;
            end
        end // case IDLE:

        START_A: begin
            adder1_input = A;
            next_state = START_B;
        end // START_A:

        START_B: begin
            adder1_input = B;
            next_state = START_C;
            next_wait_ctr = 14;
        end

        START_C: begin
            adder1_input = C;
            next_state = START_D;
        end // START_A:

        START_D: begin
            adder1_input = D;
            next_state = WAIT_A;
        end

        WAIT_A: begin
            adder1_input = UNWIND;
            if(wait_ctr == 0) begin
                save_gx = 1;
                next_wait_ctr = 1;
                next_state = WAIT_B;
            end
        end

        WAIT_B: begin
            adder1_input = UNWIND;
            if(wait_ctr == 0) begin
                save_gy = 1;
                next_state = DONE;
            end
        end

        DONE: begin
            valid_out = 1;
            next_state = IDLE;
        end
    endcase
end

always_ff @(posedge i_clk) begin

    adder1_q_lat <= adder1_q;

    if(i_rst) begin
        cur_state <= IDLE;
        wait_ctr <= 0;
    end else begin
        cur_state <= next_state;
        wait_ctr <= next_wait_ctr;
        if(save_data) begin
            r_data <= data_in;
        end

        if(save_gx) data_out_gx <= (adder2_q>>3);
        if(save_gy) data_out_gy <= (adder2_q>>3);
    end
end

endmodule;