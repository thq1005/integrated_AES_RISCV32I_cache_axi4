`include "define.sv"

module cache(
    input logic clk_i,
    input logic rst_ni,
    //request in
    input logic [`ADDR_WIDTH-1:0] addr_i,
    input logic [`DATA_WIDTH:0] wdata_i,
    input logic rw_i,
    input logic cs_i,
    //data from mem
    input logic [`DATA_WIDTH_CACHE-1:0] mem_data_i,
    input logic mem_valid_i,
    //output for request 
    output logic [31:0] rdata_o,
    output logic rvalid_o,
    //request to mem
    output logic [`ADDR_WIDTH-1:0] mem_addr_o,
    output logic [`DATA_WIDTH_CACHE-1:0] mem_wdata_o,
    output logic mem_rw_o,
    output logic mem_cs_o
    );
    
    logic rcache_valid, rcache_dirty;
    logic [`TAGMSB-`TAGLSB:0] rcache_tag;
    logic [`DATA_WIDTH_CACHE-1:0] rcache_data;
    logic full;
      
    logic wcache_valid;
    logic wcache_dirty;
    logic [`TAGMSB-`TAGLSB:0] wcache_tag;
    logic [`DATA_WIDTH_CACHE-1:0] wcache_data;
    logic [`INDEX-1:0] wcache_index;
    logic wcache_we;
    
    logic lru_cs;
    logic [`INDEX_WAY-1:0] address_0;
    logic [`INDEX_WAY-1:0] address_1;
    cache_controller ctrl (.clk_i          (clk_i),
                           .rst_ni         (rst_ni),
                           .addr_i         (addr_i),
                           .wdata_i        (wdata_i),
                           .rw_i           (rw_i),
                           .cs_i           (cs_i),
                           .mem_data_i     (mem_data_i),
                           .mem_valid_i    (mem_valid_i),
                           .rcache_valid_i (rcache_valid),
                           .rcache_dirty_i (rcache_dirty),
                           .rcache_tag_i   (rcache_tag),
                           .rcache_data_i  (rcache_data),
                           .full_i         (full),
                           .wcache_valid_o (wcache_valid),
                           .wcache_dirty_o (wcache_dirty),
                           .wcache_tag_o   (wcache_tag),
                           .wcache_data_o  (wcache_data),
                           .wcache_index_o (wcache_index),
                           .wcache_we_o    (wcache_we),
                           .lru_cs_o       (lru_cs),
                           .rdata_o        (rdata_o),
                           .r_valid_o      (rvalid_o),
                           .addr_o         (mem_addr_o),
                           .data_o         (mem_wdata_o),
                           .rw_o           (mem_rw_o),
                           .cs_o           (mem_cs_o)
                           );
    
    cache_array array (.clk_i         (clk_i),
                       .rst_ni        (rst_ni),
                       .index_i       (wcache_index),
                       .we_i          (wcache_we),
                       .valid_i       (wcache_valid),
                       .dirty_i       (wcache_dirty),
                       .tag_i         (wcache_tag),
                       .address_way_i (address_0),
                       .cpu_address_i (addr_i),
                       .address_way_o (address_1),
                       .valid_o       (rcache_valid),
                       .dirty_o       (rcache_dirty),
                       .tag_o         (rcache_tag),
                       .full_o        (full),
                       .data_write_i  (wcache_data),
                       .data_read_o   (rcache_data)
                       );
    
    cache_LRU lru (.clk_i     (clk_i),
                   .rst_ni    (rst_ni),
                   .cs_i      (lru_cs),
                   .index_i   (wcache_index),
                   .address_i (address_1),
                   .address_o (address_0)
                   );
    
endmodule
