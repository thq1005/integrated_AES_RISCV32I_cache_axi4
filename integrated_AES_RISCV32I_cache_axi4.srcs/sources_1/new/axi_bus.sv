`include "define.sv"
module axi_bus(
    //Master 0
    //AW channel
    input  logic [`ID_BITS - 1:0] m0_awid,
    input  logic [`ADDR_WIDTH - 1:0] m0_awaddr,
    input  logic [`LEN_BITS - 1:0] m0_awlen,
    input  logic [`SIZE_BITS -1 :0] m0_awsize,
    input  logic [1:0] m0_awburst,
    input  logic m0_awvalid,
    output  logic m0_awready,
    //W channel
    input logic [`DATA_WIDTH - 1:0] m0_wdata,
    input logic [(`DATA_WIDTH/8)-1:0] m0_wstrb,
    input logic m0_wvalid,
    input logic m0_wlast,
    output  logic m0_wready,
    //B channel
    output logic [`ID_BITS - 1:0] m0_bid,
    output logic [2:0] m0_bresp,
    output logic m0_bvalid,
    input  logic m0_bready,
    //AR channel
    input  logic [`ID_BITS - 1:0] m0_arid,
    input  logic [`ADDR_WIDTH - 1:0] m0_araddr,
    input  logic [`LEN_BITS - 1:0] m0_arlen,
    input  logic [1:0] m0_arburst,
    input  logic [`SIZE_BITS - 1:0] m0_arsize,
    input  logic m0_arvalid,
    output  logic m0_arready,
    //R channel
    output  logic [`ID_BITS - 1:0] m0_rid,
    output  logic [`DATA_WIDTH - 1:0] m0_rdata,
    output  logic [2:0] m0_rresp,
    output  logic m0_rvalid,
    output  logic m0_rlast,
    input logic m0_rready,
    
    //Slave 0
    //AW channel
    output logic [`ID_BITS - 1:0] s0_awid,
    output logic [`ADDR_WIDTH - 1:0] s0_awaddr,
    output logic [`LEN_BITS - 1:0] s0_awlen,
    output logic [`SIZE_BITS -1 :0] s0_awsize,
    output logic [1:0] s0_awburst,
    output logic s0_awvalid,
    input  logic s0_awready,
    //W channel
    output logic [`DATA_WIDTH - 1:0] s0_wdata,
    output logic [(`DATA_WIDTH/8)-1:0] s0_wstrb,
    output logic s0_wvalid,
    output logic s0_wlast,
    input  logic s0_wready,
    //B channel
    input  logic [`ID_BITS - 1:0] s0_bid,
    input  logic [2:0] s0_bresp,
    input  logic s0_bvalid,
    output logic s0_bready,
    //AR channel
    output logic [`ID_BITS - 1:0] s0_arid,
    output logic [`ADDR_WIDTH - 1:0] s0_araddr,
    output logic [`LEN_BITS - 1:0] s0_arlen,
    output logic [1:0] s0_arburst,
    output logic [`SIZE_BITS - 1:0] s0_arsize,
    output logic s0_arvalid,
    input  logic s0_arready,
    //R channel
    input  logic [`ID_BITS - 1:0] s0_rid,
    input  logic [`DATA_WIDTH - 1:0] s0_rdata,
    input  logic [2:0] s0_rresp,
    input  logic s0_rvalid,
    input  logic s0_rlast,
    output logic s0_rready
    );
    
    assign m0_awready = s0_awready;
    assign s0_awid    = m0_awid;
    assign s0_awaddr  = m0_awaddr;
    assign s0_awlen   = m0_awlen;
    assign s0_awsize  = m0_awsize;
    assign s0_awburst = m0_awburst;
    assign s0_awvalid = m0_awvalid;
    
    assign m0_wready  = s0_wready;
    assign s0_wdata   = m0_wdata;
    assign s0_wstrb   = m0_wstrb;
    assign s0_wvalid  = m0_wvalid;
    assign s0_wlast   = m0_wlast;
    
    assign m0_bid     = s0_bid;
    assign m0_bresp   = s0_bresp;
    assign m0_bvalid  = s0_bvalid;
    assign s0_bready  = m0_bready;
    
    assign m0_arready = s0_arready;
    assign s0_arid    = m0_arid;
    assign s0_araddr  = m0_araddr;
    assign s0_arlen   = m0_arlen;
    assign s0_arsize  = m0_arsize;
    assign s0_arburst = m0_arburst;
    assign s0_arvalid = m0_arvalid;
    
    assign m0_rid     = s0_rid;
    assign m0_rdata   = s0_rdata;
    assign m0_rresp   = s0_rresp;
    assign m0_rvalid  = s0_rvalid;
    assign m0_rlast   = s0_rlast;
    assign s0_rready  = m0_rready;
    
endmodule
