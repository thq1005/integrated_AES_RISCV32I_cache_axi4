`include "define.sv"
module axi_interface_master(
input logic clk_i,
    input logic rst_ni,
    //AW channel
    output logic [`ID_BITS - 1:0] awid_o,
    output logic [`ADDR_WIDTH - 1:0] awaddr_o,
    output logic [`LEN_BITS - 1:0] awlen_o,
    output logic [`SIZE_BITS -1 :0] awsize_o,
    output logic [1:0] awburst_o,
    output logic awvalid_o,
    input  logic awready_i,
    //W channel
    output logic [`DATA_WIDTH - 1:0] wdata_o,
    output logic [(`DATA_WIDTH/8)-1:0] wstrb_o,
    output logic wvalid_o,
    output logic wlast_o,
    input  logic wready_i,
    //B channel
    input  logic [`ID_BITS - 1:0] bid_i,
    input  logic [2:0] bresp_i,
    input  logic bvalid_i,
    output logic bready_o,
    //AR channel
    output logic [`ID_BITS - 1:0] arid_o,
    output logic [`ADDR_WIDTH - 1:0] araddr_o,
    output logic [`LEN_BITS - 1:0] arlen_o,
    output logic [1:0] arburst_o,
    output logic [`SIZE_BITS - 1:0] arsize_o,
    output logic arvalid_o,
    input  logic arready_i,
    //R channel
    input  logic [`ID_BITS - 1:0] rid_i,
    input  logic [`DATA_WIDTH - 1:0] rdata_i,
    input  logic [2:0] rresp_i,
    input  logic rvalid_i,
    input  logic rlast_i,
    output logic rready_o,
    //signal of cpu
    input logic [`ADDR_WIDTH - 1:0] addr_i,
    input logic [`DATA_WIDTH_CACHE - 1:0] wdata_i,
    input logic we_i,
    output logic [`DATA_WIDTH_CACHE - 1:0] rdata_o,
    output logic rvalid_o
    );
    
    
endmodule
