`include "define.sv"

module master_0_cpu_mem(
      input logic clk_i,
      input logic rst_ni,
      // AXI interface
      //AW channel
      output logic [`ID_BITS - 1:0] awid,
      output logic [`ADDR_WIDTH - 1:0] awaddr,
      output logic [`LEN_BITS - 1:0] awlen,
      output logic [`SIZE_BITS -1 :0] awsize,
      output logic [1:0] awburst,
      output logic awvalid,
      input  logic awready,
      //W channel
      output logic [`DATA_WIDTH - 1:0] wdata,
      output logic [(`DATA_WIDTH/8)-1:0] wstrb,
      output logic wvalid,
      output logic wlast,
      input  logic wready,
      //B channel
      input  logic [`ID_BITS - 1:0] bid,
      input  logic [2:0] bresp,
      input  logic bvalid,
      output logic bready,
      //AR channel
      output logic [`ID_BITS - 1:0] arid,
      output logic [`ADDR_WIDTH - 1:0] araddr,
      output logic [`LEN_BITS - 1:0] arlen,
      output logic [1:0] arburst,
      output logic [`SIZE_BITS - 1:0] arsize,
      output logic arvalid,
      input  logic arready,
      //R channel
      input  logic [`ID_BITS - 1:0] rid,
      input  logic [`DATA_WIDTH - 1:0] rdata,
      input  logic [2:0] rresp,
      input  logic rvalid,
      input  logic rlast,
      output logic rready
    );
    
    logic [`ADDR_WIDTH-1:0] addr_w;
    logic [`DATA_WIDTH_CACHE - 1:0] wdata_w,rdata_w;
    logic we_w,cs_w,rvalid_w,handshaked_w;
    
    
    axi_interface_master_0 m0_itf (
    .clk_i        (clk_i),
    .rst_ni       (rst_ni),
    .awid_o       (awid),
    .awaddr_o     (awaddr),
    .awlen_o      (awlen),
    .awsize_o     (awsize),
    .awburst_o    (awburst),
    .awvalid_o    (awvalid),
    .awready_i    (awready),
    .wdata_o      (wdata),
    .wstrb_o      (wstrb),
    .wvalid_o     (wvalid),
    .wlast_o      (wlast),
    .wready_i     (wready),
    .bid_i        (bid),
    .bresp_i      (bresp),
    .bvalid_i     (bvalid),
    .bready_o     (bready),
    .arid_o       (arid),
    .araddr_o     (araddr),
    .arlen_o      (arlen),
    .arburst_o    (arburst),
    .arsize_o     (arsize),
    .arvalid_o    (arvalid),
    .arready_i    (arready),
    .rid_i        (rid),
    .rdata_i      (rdata),
    .rresp_i      (rresp),
    .rvalid_i     (rvalid),
    .rlast_i      (rlast),
    .rready_o     (rready),
    .addr_i       (addr_w),
    .wdata_i      (wdata_w),
    .we_i         (we_w),
    .cs_i         (cs_w),
    .rdata_o      (rdata_w),
    .rvalid_o     (rvalid_w),
    .handshaked_o (handshaked_w)
    );
    
    riscv_cache cpu_inst (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    .addr_o  (addr_w),
    .wdata_o (wdata_w),
    .we_o    (we_w),
    .cs_o    (cs_w),
    .rdata_i (rdata_w),
    .rvalid_i(rvalid_w),
    .handshaked_i(handshaked_w)
    );
    
    
endmodule
