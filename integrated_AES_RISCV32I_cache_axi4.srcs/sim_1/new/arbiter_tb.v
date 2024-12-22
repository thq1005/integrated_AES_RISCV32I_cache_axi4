`timescale 1ns / 1ps

module arbiter_tb;
reg clk_i;
reg rst_ni;
//icache
reg [31:0] i_addr_i;
reg i_cs_i;
reg [127:0] i_wdata_i;
reg i_we_i;
wire[127:0] irdata_o;
wire i_rvalid_o;
//dcache
reg [31:0] d_addr_i;
reg d_cs_i;
reg [127:0] d_wdata_i;
reg d_we_i;
wire [127:0] d_rdata_o;
wire d_rvalid_o;
//tome;
wire [31:0] waddr_o;
wire [127:0] wdata_o;
wire we_o;
wire [31:0] raddr_o;
reg [127:0] rdata_i;
reg rvalid_i;
wire re_o;
//stall
wire stall_by_arbiter;


arbiter dut (
    .clk_i      (clk_i),
    .rst_ni     (rst_ni),
    .i_addr_i   (i_addr_i),
    .i_cs_i     (i_cs_i),
    .i_wdata_i  (i_wdata_i),
    .i_we_i     (i_we_i),
    .i_rdata_o  (i_rdata_o),
    .i_rvalid_o (i_rvalid_o),
    .d_addr_i   (d_addr_i),
    .d_cs_i     (d_cs_i),
    .d_wdata_i  (d_wdata_i),
    .d_we_i     (d_we_i),
    .d_rdata_o  (d_rdata_o),  
    .d_rvalid_o (d_rvalid_o), 
    .waddr_o    (waddr_o),
    .wdata_o    (wdata_o),
    .we_o       (we_o),
    .raddr_o    (raddr_o),
    .rdata_i    (rdata_i),
    .rvalid_i   (rvalid_i),
    .re_o       (re_o),
    .stall_by_arbiter   (stall_by_arbiter)
    );
    
always #5 clk_i = ~clk_i;

initial begin
    clk_i       = 0;
    rst_ni      = 0;
    i_cs_i      = 0;
    i_wdata_i   = 0;
    i_we_i      = 0;
    d_cs_i      = 0;
    d_wdata_i   = 0;
    d_we_i      = 0;
    rdata_i     = 0;
    rvalid_i    = 0;
    //th1: I: read D: 0
    repeat(2) @(posedge clk_i);
    #1;
    rst_ni      = 1;
    i_cs_i      = 1;
    i_addr_i    = 4;
    i_wdata_i   = 0;
    i_we_i      = 0;
    d_addr_i    = 0;
    d_cs_i      = 0;
    d_wdata_i   = 0;
    d_we_i      = 0;
    //th2 I:read D: write
    @(posedge clk_i);
    #1;
    i_cs_i      = 1;
    i_addr_i    = 8;
    i_wdata_i   = 0;
    i_we_i      = 0;
    d_addr_i    = 16;
    d_cs_i      = 1;
    d_wdata_i   = 128'h88889999aaaabbbbccccddddeeeeffff;
    d_we_i      = 1;
    //th3 I:read D: write
    @(posedge clk_i);
    #1;
    i_cs_i      = 1;
    i_addr_i    = 8;
    i_wdata_i   = 0;
    i_we_i      = 0;
    d_addr_i    = 16;
    d_cs_i      = 1;
    d_wdata_i   = 0;
    d_we_i      = 0;
    @(posedge clk_i);
    #1;
    i_cs_i      = 0;
    i_addr_i    = 8;
    i_wdata_i   = 0;
    i_we_i      = 0;
    d_addr_i    = 16;
    d_cs_i      = 0;
    d_wdata_i   = 0;
    d_we_i      = 0;
end    
endmodule
