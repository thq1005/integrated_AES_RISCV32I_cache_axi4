`include "define.sv"

module cache_controller(
    input logic clk_i,
    input logic rst_ni,
    //request from cpu
    input logic [`ADDR_WIDTH-1:0] addr_i,
    input logic [`DATA_WIDTH-1:0] wdata_i,
    input logic rw_i,       //1: write 0: read
    input logic cs_i,
    //data from mem
    input logic [`DATA_WIDTH-1:0] mem_data_i,
    input logic mem_valid_i,
    //data from cache_array
    input logic rcache_valid_i,
    input logic rcache_dirty_i,
    input logic [`TAGMSB-`TAGLSB:0] rcache_tag_i,
    input logic [`DATA_WIDTH_CACHE-1:0] rcache_data_i,
    input logic full_i,
    //data to cache_array
    output logic wcache_valid_o,
    output logic wcache_dirty_o,
    output logic [`TAGMSB-`TAGLSB:0] wcache_tag_o,
    output logic [`DATA_WIDTH_CACHE-1:0] wcache_data_o,
    output logic [`INDEX-1:0] wcache_index_o,
    output logic wcache_we_o,
    //signal to lru
    output logic lru_cs_o,
    //data to cpu 
    output logic [`DATA_WIDTH-1:0] rdata_o,
    output logic r_valid_o,
    //request to mem
    output logic [`ADDR_WIDTH-1:0] addr_o,
    output logic [`DATA_WIDTH_CACHE-1:0] data_o,
    output logic rw_o,
    output logic cs_o
    );
    
    parameter S0 = 2'b00, S1= 2'b01, S2 = 2'b10, S3 = 2'b11;
    /// S0: IDLE; S1: READ/WRITE  ; S2: WRITE_BACK ; S3: ALLOCATE
    logic [1:0] c_state, next_state;
    
    logic hit;
    ///cpu request
    logic [`ADDR_WIDTH-1:0] addr_reg;
    logic [`DATA_WIDTH-1:0] wdata_reg;
    logic rw_reg;       //1: write 0: read
    //signal for input cache
    logic [1:0] s_cache_index;
    logic s_cache_line;
    logic s_cache_lru;
    logic s_cache_data;
    logic [`DATA_WIDTH_CACHE:0] cache_wdata;
    //signal for output cpu
    logic [3:0] offset;
    logic s_cpu_rvalid;
    
    
    ////FSM
    always_ff @(posedge clk_i) begin
        if (~rst_ni)
            c_state = S0;
        else
            c_state = next_state; 
    end
    
    always_comb begin
        case (c_state)
        S0: begin 
            if (cs_i)
                next_state = S1;
            else 
                next_state = S0;
        end
        S1: begin
            if (hit)
                next_state = S0;
            else begin
                if (full_i && rcache_dirty_i)
                    next_state = S2;
                else 
                    next_state = S3;
            end    
        end
        S2: begin
            next_state = S3;
        end
        S3: begin
            if (mem_valid_i)
                next_state = S1;
        end
        endcase
    end
    ///////
    ///////////////
    //S0: IDLE
    ///////////////
    always_ff @(posedge clk_i) begin
        if (c_state == S1) begin
            addr_reg <= addr_i;
            wdata_reg <= wdata_i;
            rw_reg <= rw_i;
        end
    end
    
    ///////////////
    ///////////////
    //S1: READ/WRITE
    ///////////////
    always_comb begin
        if (c_state == S1) begin
            if (rcache_tag_i == addr_reg[`TAGMSB:`TAGLSB] && rcache_valid_i)
                hit = 1;
            else 
                hit = 0;
        end   
    end
    
    assign s_cpu_rvalid  = ((c_state == S1) && hit && !rw_reg) ? 1:0;
    assign s_cache_index = (c_state == S1) ? 2'b11 : 
                           (c_state == S3) ? 2'b10 : 2'b00;
    assign s_cache_line  = (c_state == S1 | c_state == S3) ? 1 : 0;
    assign s_cache_lru   = (c_state == S1 | c_state == S3) ? 1 : 0;
    assign s_cache_data  = (c_state == S1) ? 1 : 0;
    //signals of cache array
    assign wcache_index_o = addr_reg[6:4];
    assign wcache_we_o    = (s_cache_index) ? rw_reg : 0;
    assign wcache_tag_o   = addr_reg[`TAGMSB:`TAGLSB] ;
    assign wcache_valid_o = (s_cache_line) ? 1 : 0;
    assign wcache_dirty_o = (hit) ? 1 : 0;
    always_comb begin
        cache_wdata = rcache_data_i;
        case (addr_i [3:2])
            2'b00: cache_wdata[31:0]   = wdata_i;
            2'b01: cache_wdata[63:32]  = wdata_i;
            2'b10: cache_wdata[95:64]  = wdata_i;
            2'b11: cache_wdata[127:96] = wdata_i;
        endcase  
    end
    assign wcache_data_o  = (s_cache_data) ? cache_wdata : mem_data_i;
    //signals of cache_LRU
    assign lru_cs_o = s_cache_lru;
    //signals of mem
    assign addr_o = addr_reg;
    assign data_o = rcache_data_i;
    assign rw_o   = (c_state == S2) ? 1 : 0;
    assign cs_o   = (c_state == S2 || c_state == S3) ? 1 : 0;
    //signals to cpu
    assign offset   = addr_reg[3:0];
    assign rdata_o  =  rcache_data_i[127-(8*offset)+:32];
    assign rvalid_o = (s_cpu_rvalid) ? 1:0;

endmodule
