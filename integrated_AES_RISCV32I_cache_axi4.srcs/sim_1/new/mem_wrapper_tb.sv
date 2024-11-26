`timescale 1ns / 1ps

module mem_wrapper_tb;
logic clk_i;
logic rst_ni;
// AXI interface
//AW channel
logic [`ID_BITS - 1:0] awid;
logic [`ADDR_WIDTH - 1:0] awaddr;
logic [`LEN_BITS - 1:0] awlen;
logic [`SIZE_BITS -1 :0] awsize;
logic [1:0] awburst;
logic awvalid;
logic awready;
//W channel
logic [`DATA_WIDTH - 1:0] wdata;
logic [(`DATA_WIDTH/8)-1:0] wstrb;
logic wvalid;
logic wlast;
logic wready;
//B channel
logic [`ID_BITS - 1:0] bid;
logic [2:0] bresp;
logic bvalid;
logic bready;
//AR channel
logic [`ID_BITS - 1:0] arid;
logic [`ADDR_WIDTH - 1:0] araddr;
logic [`LEN_BITS - 1:0] arlen;
logic [1:0] arburst;
logic [`SIZE_BITS - 1:0] arsize;
logic arvalid;
logic arready;
//R channel
logic [`ID_BITS - 1:0] rid;
logic [`DATA_WIDTH - 1:0] rdata;
logic [2:0] rresp;
logic rvalid;
logic rlast;
logic rready;

mem_wrapper dut (
.clk_i(clk_i),
.rst_ni(rst_ni),
.awid(awid),
.awaddr(awaddr),
.awlen(awlen),
.awsize(awsize),
.awburst(awburst),
.awvalid(awvalid),
.awready(awready),
.wdata(wdata),
.wstrb(wstrb),
.wvalid(wvalid),
.wlast(wlast),
.wready(wready),
.bid(bid),
.bresp(bresp),
.bvalid(bvalid),
.bready(bready),
.arid(arid),
.araddr(araddr),
.arlen(arlen),
.arburst(arburst),
.arsize(arsize),
.arvalid(arvalid),
.arready(arready),
.rid(rid),
.rdata(rdata),
.rresp(rresp),
.rvalid(rvalid),
.rlast(rlast),
.rready(rready)
);

// Clock generation
initial clk_i = 0;
always #5 clk_i = ~clk_i; // 10ns clock period

// Reset generation
initial begin
rst_ni = 0;
#20 rst_ni = 1;
end

// Test sequence
initial begin
// Initialize inputs
#30;
awid = 0;
awaddr = 0;
awlen = 0;
awsize = 0;
awburst = 0;
awvalid = 0;

wdata = 0;
wstrb = 0;
wvalid = 0;
wlast = 0;

bready = 0;

arid = 0;
araddr = 0;
arlen = 0;
arburst = 0;
arsize = 0;
arvalid = 0;

rready = 0;

write (32'h200,32'h00112233,32'h44556677,32'h8899aabb,32'hccddeeff,3,3,0);
end

// Task for writing to mem
task write (input [`ADDR_WIDTH-1:0] address, 
            input [`DATA_WIDTH-1:0] data0,
            input [`DATA_WIDTH-1:0] data1,
            input [`DATA_WIDTH-1:0] data2,
            input [`DATA_WIDTH-1:0] data3,
            input [`SIZE_BITS-1:0] size,
            input [`LEN_BITS-1:0] len,
            input [1:0] burst);
            
    awaddr = address;
    awsize = size;
    awlen  = len;
    awburst = burst;
    awvalid = 1;
    @(awready);
    @(posedge clk_i);
    awvalid = 0;
    wvalid = 1; 
    for (int i = 0 ; i < len; i++) begin
        @(posedge clk_i);
        if (i == 0)
            wdata = data0;
        else if (i == 1) 
            wdata = data1;
        else if (i == 2) 
            wdata = data2;
        else if (i == 3)
            wdata = data3;
   
        if (i== len-1) 
            wlast = 1;
    end
    wvalid = 1;

    @(posedge clk_i)
    bready = 1;
    wvalid = 0;
    @(posedge clk_i)
    bready = 0;
endtask

// Task for reading from mem
task read (input [`ADDR_WIDTH-1:0] address);

endtask


endmodule
