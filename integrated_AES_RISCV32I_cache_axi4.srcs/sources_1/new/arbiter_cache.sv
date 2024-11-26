`include "define.sv" 

module arbiter_cache(
    input logic clk_i,
    input logic rst_ni,
    input logic [`ADDR_WIDTH - 1:0] i_cache_addr_i,
    input logic [`DATA_WIDTH_CACHE - 1:0] i_cache_data_i,
    input logic i_cache_rw_i,
    input logic i_cache_valid_i,
    input logic [`ADDR_WIDTH - 1:0] d_cache_addr_i,
    input logic [`DATA_WIDTH_CACHE - 1:0] d_cache_data_i,
    input logic d_cache_rw_i,
    input logic d_cache_valid_i,
    input logic [`DATA_WIDTH_CACHE - 1:0] mem_data_i,
    input logic mem_valid_i,
    output logic [`DATA_WIDTH_CACHE - 1:0] i_cache_data_o,
    output logic i_cache_valid_o,
    output logic [`DATA_WIDTH_CACHE - 1:0] d_cache_data_o,
    output logic d_cache_valid_o,
    output logic [`ADDR_WIDTH-1 : 0] l1_cache_addr_o,
    output logic [`DATA_WIDTH_CACHE - 1:0] l1_cache_data_o,
    output logic l1_cache_rw_o,
    output logic l1_cache_valid_o
);

    localparam IDLE = 2'b00, I_CACHE = 2'b01, D_CACHE = 2'b10;
    
    logic next_state, state;

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (i_cache_valid_i) next_state = I_CACHE;
                else if ((~i_cache_valid_i) & d_cache_valid_i) next_state = D_CACHE;
            end
            I_CACHE: begin
                if ((~i_cache_valid_i) & (~d_cache_valid_i)) next_state = IDLE;
                else if ((~i_cache_valid_i) & d_cache_valid_i) next_state = D_CACHE;
            end
            D_CACHE: begin
                if ((~i_cache_valid_i) & (~d_cache_valid_i)) next_state = IDLE;
                else if (i_cache_valid_i & (~d_cache_valid_i)) next_state = I_CACHE;
            end
            default: next_state = IDLE;
        endcase
    end

    always_comb begin
        if (state == I_CACHE) begin
            l1_cache_addr_o  = i_cache_addr_i;
            l1_cache_data_o  = i_cache_data_i;
            l1_cache_rw_o    = i_cache_rw_i;
            l1_cache_valid_o = i_cache_valid_i;
            i_cache_data_o   = mem_data_i;
            i_cache_valid_o  = mem_valid_i;
            d_cache_data_o   = '0;
            d_cache_valid_o  = '0;
        end
        else if (state == D_CACHE) begin
            l1_cache_addr_o  = d_cache_addr_i;
            l1_cache_data_o  = d_cache_data_i;
            l1_cache_rw_o    = d_cache_rw_i;
            l1_cache_valid_o = d_cache_valid_i;
            i_cache_data_o   = '0;
            i_cache_valid_o  = '0;
            d_cache_data_o   = mem_data_i;
            d_cache_valid_o  = mem_valid_i;
        end
        else begin 
            l1_cache_addr_o  = '0;
            l1_cache_data_o  = '0;
            l1_cache_rw_o    = '0;
            l1_cache_valid_o = '0;
            i_cache_data_o   = '0;
            i_cache_valid_o  = '0;
            d_cache_data_o   = '0;
            d_cache_valid_o  = '0;
        end
    end

    always_ff @(posedge clk_i, negedge rst_ni) begin
        if (!rst_ni) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

endmodule
