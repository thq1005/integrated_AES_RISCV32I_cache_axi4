`include "define.sv" 
module top(
    input logic clk_1_i,
    input logic rst_ni,
    input logic clk_2_i
    );
    
    
    //signal of m0
    logic [`ID_BITS - 1:0] m0_awid;
    logic [`ADDR_WIDTH - 1:0] m0_awaddr;
    logic [`LEN_BITS - 1:0] m0_awlen;
    logic [`SIZE_BITS -1 :0] m0_awsize;
    logic [1:0] m0_awburst;
    logic m0_awvalid;
    logic m0_awready;
    //W channel
    logic [`DATA_WIDTH - 1:0] m0_wdata;
    logic [(`DATA_WIDTH/8)-1:0] m0_wstrb;
    logic m0_wvalid;
    logic m0_wlast;
    logic m0_wready;
    //B channel
    logic [`ID_BITS - 1:0] m0_bid;
    logic [2:0] m0_bresp;
    logic m0_bvalid;
    logic m0_bready;
    //AR channel
    logic [`ID_BITS - 1:0] m0_arid;
    logic [`ADDR_WIDTH - 1:0] m0_araddr;
    logic [`LEN_BITS - 1:0] m0_arlen;
    logic [1:0] m0_arburst;
    logic [`SIZE_BITS - 1:0] m0_arsize;
    logic m0_arvalid;
    logic m0_arready;
    //R channel
    logic [`ID_BITS - 1:0] m0_rid;
    logic [`DATA_WIDTH - 1:0] m0_rdata;
    logic [2:0] m0_rresp;
    logic m0_rvalid;
    logic m0_rlast;
    logic m0_rready;

    //signal of s0
    logic [`ID_BITS - 1:0] s0_awid;
    logic [`ADDR_WIDTH - 1:0] s0_awaddr;
    logic [`LEN_BITS - 1:0] s0_awlen;
    logic [`SIZE_BITS -1 :0] s0_awsize;
    logic [1:0] s0_awburst;
    logic s0_awvalid;
    logic s0_awready;
    //W channel
    logic [`DATA_WIDTH - 1:0] s0_wdata;
    logic [(`DATA_WIDTH/8)-1:0] s0_wstrb;
    logic s0_wvalid;
    logic s0_wlast;
    logic s0_wready;
    //B channel
    logic [`ID_BITS - 1:0] s0_bid;
    logic [2:0] s0_bresp;
    logic s0_bvalid;
    logic s0_bready;
    //AR channel
    logic [`ID_BITS - 1:0] s0_arid;
    logic [`ADDR_WIDTH - 1:0] s0_araddr;
    logic [`LEN_BITS - 1:0] s0_arlen;
    logic [1:0] s0_arburst;
    logic [`SIZE_BITS - 1:0] s0_arsize;
    logic s0_arvalid;
    logic s0_arready;
    //R channel
    logic [`ID_BITS - 1:0] s0_rid;
    logic [`DATA_WIDTH - 1:0] s0_rdata;
    logic [2:0] s0_rresp;
    logic s0_rvalid;
    logic s0_rlast;
    logic s0_rready;

    
    master_0_cpu_mem m0_inst (
        .clk_i      (clk_1_i),
        .rst_ni     (rst_ni),
        .awid       (m0_awid),
        .awaddr     (m0_awaddr),
        .awlen      (m0_awlen),
        .awsize     (m0_awsize),
        .awburst    (m0_awburst),
        .awvalid    (m0_awvalid),
        .awready    (m0_awready),
        .wdata      (m0_wdata),
        .wstrb      (m0_wstrb),
        .wvalid     (m0_wvalid),
        .wlast      (m0_wlast),
        .wready     (m0_wready),
        .bid        (m0_bid),
        .bresp      (m0_bresp),
        .bvalid     (m0_bvalid),
        .bready     (m0_bready),
        .arid       (m0_arid),
        .araddr     (m0_araddr),
        .arlen      (m0_arlen),
        .arburst    (m0_arburst),
        .arsize     (m0_arsize),
        .arvalid    (m0_arvalid),
        .arready    (m0_arready),
        .rid        (m0_rid),
        .rdata      (m0_rdata),
        .rresp      (m0_rresp),
        .rvalid     (m0_rvalid),
        .rlast      (m0_rlast),
        .rready     (m0_rready)
        );
        
    slave_0_sdram s0_inst (
        .clk_i      (clk_2_i),
        .rst_ni     (rst_ni),
        .awid       (s0_awid),
        .awaddr     (s0_awaddr),
        .awlen      (s0_awlen),
        .awsize     (s0_awsize),
        .awburst    (s0_awburst),
        .awvalid    (s0_awvalid),
        .awready    (s0_awready),
        .wdata      (s0_wdata),
        .wstrb      (s0_wstrb),
        .wvalid     (s0_wvalid),
        .wlast      (s0_wlast),
        .wready     (s0_wready),
        .bid        (s0_bid),
        .bresp      (s0_bresp),
        .bvalid     (s0_bvalid),
        .bready     (s0_bready),
        .arid       (s0_arid),
        .araddr     (s0_araddr),
        .arlen      (s0_arlen),
        .arburst    (s0_arburst),
        .arsize     (s0_arsize),
        .arvalid    (s0_arvalid),
        .arready    (s0_arready),
        .rid        (s0_rid),
        .rdata      (s0_rdata),
        .rresp      (s0_rresp),
        .rvalid     (s0_rvalid),
        .rlast      (s0_rlast),
        .rready     (s0_rready)
    );
    
    
    axi_bus bus (
        //m0
        .m0_awid       (m0_awid),
        .m0_awaddr     (m0_awaddr),
        .m0_awlen      (m0_awlen),
        .m0_awsize     (m0_awsize),
        .m0_awburst    (m0_awburst),
        .m0_awvalid    (m0_awvalid),
        .m0_awready    (m0_awready),
        .m0_wdata      (m0_wdata),
        .m0_wstrb      (m0_wstrb),
        .m0_wvalid     (m0_wvalid),
        .m0_wlast      (m0_wlast),
        .m0_wready     (m0_wready),
        .m0_bid        (m0_bid),
        .m0_bresp      (m0_bresp),
        .m0_bvalid     (m0_bvalid),
        .m0_bready     (m0_bready),
        .m0_arid       (m0_arid),
        .m0_araddr     (m0_araddr),
        .m0_arlen      (m0_arlen),
        .m0_arburst    (m0_arburst),
        .m0_arsize     (m0_arsize),
        .m0_arvalid    (m0_arvalid),
        .m0_arready    (m0_arready),
        .m0_rid        (m0_rid),
        .m0_rdata      (m0_rdata),
        .m0_rresp      (m0_rresp),
        .m0_rvalid     (m0_rvalid),
        .m0_rlast      (m0_rlast),
        .m0_rready     (m0_rready),
        //s0
        .s0_awid       (s0_awid),
        .s0_awaddr     (s0_awaddr),
        .s0_awlen      (s0_awlen),
        .s0_awsize     (s0_awsize),
        .s0_awburst    (s0_awburst),
        .s0_awvalid    (s0_awvalid),
        .s0_awready    (s0_awready),
        .s0_wdata      (s0_wdata),
        .s0_wstrb      (s0_wstrb),
        .s0_wvalid     (s0_wvalid),
        .s0_wlast      (s0_wlast),
        .s0_wready     (s0_wready),
        .s0_bid        (s0_bid),
        .s0_bresp      (s0_bresp),
        .s0_bvalid     (s0_bvalid),
        .s0_bready     (s0_bready),
        .s0_arid       (s0_arid),
        .s0_araddr     (s0_araddr),
        .s0_arlen      (s0_arlen),
        .s0_arburst    (s0_arburst),
        .s0_arsize     (s0_arsize),
        .s0_arvalid    (s0_arvalid),
        .s0_arready    (s0_arready),
        .s0_rid        (s0_rid),
        .s0_rdata      (s0_rdata),
        .s0_rresp      (s0_rresp),
        .s0_rvalid     (s0_rvalid),
        .s0_rlast      (s0_rlast),
        .s0_rready     (s0_rready)
    );
    
endmodule
