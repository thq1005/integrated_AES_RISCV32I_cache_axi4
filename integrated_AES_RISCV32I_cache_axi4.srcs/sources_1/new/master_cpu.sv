`include "define.sv"

module master_cpu(
      input logic clk_i,
      input logic rst_ni,
      // AXI interface
      //master0: cpu to mem
      //AW channel
      output logic [`ID_BITS - 1:0] m0_awid,
      output logic [`ADDR_WIDTH - 1:0] m0_awaddr,
      output logic [`LEN_BITS - 1:0] m0_awlen,
      output logic [`SIZE_BITS -1 :0] m0_awsize,
      output logic [1:0] m0_awburst,
      output logic m0_awvalid,
      input  logic m0_awready,
      //W channel
      output logic [`DATA_WIDTH - 1:0] m0_wdata,
      output logic [(`DATA_WIDTH/8)-1:0] m0_wstrb,
      output logic m0_wvalid,
      output logic m0_wlast,
      input  logic m0_wready,
      //B channel
      input  logic [`ID_BITS - 1:0] m0_bid,
      input  logic [2:0] m0_bresp,
      input  logic m0_bvalid,
      output logic m0_bready,
      //AR channel
      output logic [`ID_BITS - 1:0] m0_arid,
      output logic [`ADDR_WIDTH - 1:0] m0_araddr,
      output logic [`LEN_BITS - 1:0] m0_arlen,
      output logic [1:0] m0_arburst,
      output logic [`SIZE_BITS - 1:0] m0_arsize,
      output logic m0_arvalid,
      input  logic m0_arready,
      //R channel
      input  logic [`ID_BITS - 1:0] m0_rid,
      input  logic [`DATA_WIDTH - 1:0] m0_rdata,
      input  logic [2:0] m0_rresp,
      input  logic m0_rvalid,
      input  logic m0_rlast,
      output logic m0_rready,

      //master1: cpu to aes
      //AW channel
      output logic [`ID_BITS - 1:0] m1_awid,
      output logic [`ADDR_WIDTH - 1:0] m1_awaddr,
      output logic [`LEN_BITS - 1:0] m1_awlen,
      output logic [`SIZE_BITS -1 :0] m1_awsize,
      output logic [1:0] m1_awburst,
      output logic m1_awvalid,
      input  logic m1_awready,
      //W channel
      output logic [`DATA_WIDTH - 1:0] m1_wdata,
      output logic [(`DATA_WIDTH/8)-1:0] m1_wstrb,
      output logic m1_wvalid,
      output logic m1_wlast,
      input  logic m1_wready,
      //B channel
      input  logic [`ID_BITS - 1:0] m1_bid,
      input  logic [2:0] m1_bresp,
      input  logic m1_bvalid,
      output logic m1_bready,
      //AR channel
      output logic [`ID_BITS - 1:0] m1_arid,
      output logic [`ADDR_WIDTH - 1:0] m1_araddr,
      output logic [`LEN_BITS - 1:0] m1_arlen,
      output logic [1:0] m1_arburst,
      output logic [`SIZE_BITS - 1:0] m1_arsize,
      output logic m1_arvalid,
      input  logic m1_arready,
      //R channel
      input  logic [`ID_BITS - 1:0] m1_rid,
      input  logic [`DATA_WIDTH - 1:0] m1_rdata,
      input  logic [2:0] m1_rresp,
      input  logic m1_rvalid,
      input  logic m1_rlast,
      output logic m1_rready
    );
    
    logic [`ADDR_WIDTH-1:0] mem_addr_w;
    logic [`DATA_WIDTH_CACHE-1:0] mem_wdata_w, mem_rdata_w;
    logic mem_we_w,mem_cs_w,mem_rvalid_w,mem_handshaked_w;
    
    logic [`ADDR_WIDTH-1:0] aes_addr_w;
    logic [`DATA_WIDTH-1:0] aes_wdata_w, aes_rdata_w;
    logic aes_we_w,aes_cs_w,aes_rvalid_w;

    axi_interface_master_0 m0_itf (
    .clk_i        (clk_i),
    .rst_ni       (rst_ni),
    .awid_o       (m0_awid),
    .awaddr_o     (m0_awaddr),
    .awlen_o      (m0_awlen),
    .awsize_o     (m0_awsize),
    .awburst_o    (m0_awburst),
    .awvalid_o    (m0_awvalid),
    .awready_i    (m0_awready),
    .wdata_o      (m0_wdata),
    .wstrb_o      (m0_wstrb),
    .wvalid_o     (m0_wvalid),
    .wlast_o      (m0_wlast),
    .wready_i     (m0_wready),
    .bid_i        (m0_bid),
    .bresp_i      (m0_bresp),
    .bvalid_i     (m0_bvalid),
    .bready_o     (m0_bready),
    .arid_o       (m0_arid),
    .araddr_o     (m0_araddr),
    .arlen_o      (m0_arlen),
    .arburst_o    (m0_arburst),
    .arsize_o     (m0_arsize),
    .arvalid_o    (m0_arvalid),
    .arready_i    (m0_arready),
    .rid_i        (m0_rid),
    .rdata_i      (m0_rdata),
    .rresp_i      (m0_rresp),
    .rvalid_i     (m0_rvalid),
    .rlast_i      (m0_rlast),
    .rready_o     (m0_rready),
    .addr_i       (mem_addr_w),
    .wdata_i      (mem_wdata_w),
    .we_i         (mem_we_w),
    .cs_i         (mem_cs_w),
    .rdata_o      (mem_rdata_w),
    .rvalid_o     (mem_rvalid_w),
    .handshaked_o (mem_handshaked_w)
    );
    
axi_interface_master_1 m1_itf (
    .clk_i        (clk_i),
    .rst_ni       (rst_ni),
    .awid_o       (m1_awid),
    .awaddr_o     (m1_awaddr),
    .awlen_o      (m1_awlen),
    .awsize_o     (m1_awsize),
    .awburst_o    (m1_awburst),
    .awvalid_o    (m1_awvalid),
    .awready_i    (m1_awready),
    .wdata_o      (m1_wdata),
    .wstrb_o      (m1_wstrb),
    .wvalid_o     (m1_wvalid),
    .wlast_o      (m1_wlast),
    .wready_i     (m1_wready),
    .bid_i        (m1_bid),
    .bresp_i      (m1_bresp),
    .bvalid_i     (m1_bvalid),
    .bready_o     (m1_bready),
    .arid_o       (m1_arid),
    .araddr_o     (m1_araddr),
    .arlen_o      (m1_arlen),
    .arburst_o    (m1_arburst),
    .arsize_o     (m1_arsize),
    .arvalid_o    (m1_arvalid),
    .arready_i    (m1_arready),
    .rid_i        (m1_rid),
    .rdata_i      (m1_rdata),
    .rresp_i      (m1_rresp),
    .rvalid_i     (m1_rvalid),
    .rlast_i      (m1_rlast),
    .rready_o     (m1_rready),
    .addr_i       (aes_addr_w),
    .wdata_i      (aes_wdata_w),
    .we_i         (aes_we_w),
    .cs_i         (aes_cs_w),
    .rdata_o      (aes_rdata_w),
    .rvalid_o     (aes_rvalid_w)
    );

    riscv_cache cpu_inst (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    .addr_o  (mem_addr_w),
    .wdata_o (mem_wdata_w),
    .we_o    (mem_we_w),
    .cs_o    (mem_cs_w),
    .rdata_i (mem_rdata_w),
    .rvalid_i(mem_rvalid_w),
    .handshaked_i(mem_handshaked_w),
    .aes_addr_o  (aes_addr_w),
    .aes_wdata_o (aes_wdata_w),
    .aes_we_o    (aes_we_w),
    .aes_cs_o    (aes_cs_w),
    .aes_rdata_i (aes_rdata_w),
    .aes_rvalid_i(aes_rvalid_w)
    );
    
    
endmodule
