`include "define.sv"

module Asynchronous_AXI_to_AXI_Bridge(
    //Master 0
    input logic ACLK_m,
    input logic ARESETn_m,
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
    input logic ACLK_s,
    input logic ARESETn_s,
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
    
    //fifo for AW channel
    logic [`ID_BITS + `LEN_BITS + `SIZE_BITS + 2 + `ADDR_WIDTH - 1 :0] aw_fifo [`FIFO_DEPTH];
    logic [2:0] aw_wptr, aw_rptr;
    logic aw_empty, aw_full;



    assign aw_full  = (aw_wptr + 1 == aw_rptr);
    assign aw_empty = (aw_wptr == aw_rptr);

    always_ff @(posedge ACLK_m) begin
        if (!ARESETn_m) begin
            aw_wptr <= 0;
            for (int i = 0; i < 8; i++)
                aw_fifo[i] = 0;
        end
        else if (m0_awvalid && !aw_full) begin 
            aw_wptr <= aw_wptr + 1;
            aw_fifo[aw_wptr] <= {m0_awaddr,m0_awid,m0_awsize,m0_awlen,m0_awburst};
        end
    end

    always_ff @(posedge ACLK_s) begin
        if (!ARESETn_s)
            aw_rptr <= 0;
        else if (s0_awready && !aw_empty) begin
            aw_rptr <= aw_rptr + 1;
        end
    end

    assign m0_awready = !aw_full;
    assign {s0_awaddr,s0_awid,s0_awsize,s0_awlen,s0_awburst} = aw_fifo[aw_rptr];
    assign s0_awvalid = !aw_empty;

    //fifo for W channel
    logic [5 + `DATA_WIDTH - 1 :0] w_fifo [`FIFO_DEPTH];
    logic [2:0] w_wptr, w_rptr;
    logic w_empty, w_full;

    assign w_full  = (w_wptr + 1 == w_rptr);
    assign w_empty = (w_wptr == w_rptr);

    always_ff @(posedge ACLK_m) begin
        if (!ARESETn_m) begin
            w_wptr <= 0;
            for (int i = 0; i < 8; i++)
                w_fifo[i] = 0;
        end
        else if (m0_wvalid && !w_full) begin 
            w_wptr <= w_wptr + 1;
            w_fifo[w_wptr] <= {m0_wdata,m0_wstrb,m0_wlast};
        end
    end

    always_ff @(posedge ACLK_s) begin
        if (!ARESETn_s)
            w_rptr <= 0;
        else if (s0_wready && !w_empty) begin
            w_rptr <= w_rptr + 1;
        end
    end

    assign m0_wready = !w_full;
    assign {s0_wdata,s0_wstrb,s0_wlast} = w_fifo[w_rptr];
    assign s0_wvalid = !w_empty;

    //fifo for B channel
    logic [3 + `ID_BITS - 1 :0] b_fifo [`FIFO_DEPTH];
    logic [2:0] b_wptr, b_rptr;
    logic b_empty, b_full;

    assign b_full  = (b_wptr + 1 == b_rptr);
    assign b_empty = (b_wptr == b_rptr);

    always_ff @(posedge ACLK_s) begin
        if (!ARESETn_s) begin
            b_wptr <= 0;
            for (int i = 0; i < 8; i++)
                b_fifo[i] = 0;
        end   
        else if (s0_bvalid && !b_full) begin 
            b_wptr <= b_wptr + 1;
            b_fifo[b_wptr] <= {s0_bid,s0_bresp};
        end
    end

    always_ff @(posedge ACLK_m) begin
        if (!ARESETn_m)
            b_rptr <= 0;
        else if (m0_bready && !b_empty) begin
            b_rptr <= b_rptr + 1;
        end
    end

    assign s0_bready = !b_full;
    assign {m0_bid,m0_bresp} = b_fifo[b_rptr];
    assign m0_bvalid = !b_empty;

    //fifo for AR channel
    logic [`ID_BITS + `LEN_BITS + `SIZE_BITS + 2 + `ADDR_WIDTH - 1 :0] ar_fifo [`FIFO_DEPTH];
    logic [2:0] ar_wptr, ar_rptr;
    logic ar_empty, ar_full;

    assign ar_full  = (ar_wptr + 1 == ar_rptr);
    assign ar_empty = (ar_wptr == ar_rptr);

    always_ff @(posedge ACLK_m) begin
        if (!ARESETn_m) begin
            ar_wptr <= 0;
            for (int i = 0; i < 8; i++)
                ar_fifo[i] = 0;
        end
        else if (m0_arvalid && !ar_full) begin 
            ar_wptr <= ar_wptr + 1;
            ar_fifo[ar_wptr] <= {m0_araddr,m0_arid,m0_arsize,m0_arlen,m0_arburst};
        end
    end

    always_ff @(posedge ACLK_s) begin
        if (!ARESETn_s) begin
            ar_rptr <= 0;
            for (int i = 0; i < 8; i++)
                ar_fifo[i] = 0;
        end
        else if (s0_arready && !ar_empty) begin
            ar_rptr <= ar_rptr + 1;
        end
    end

    assign m0_arready = !ar_full;
    assign {s0_araddr,s0_arid,s0_arsize,s0_arlen,s0_arburst} = ar_fifo[ar_rptr];
    assign s0_arvalid = !ar_empty;

    //fifo for R channel
    logic [`DATA_WIDTH + 4 + `ID_BITS - 1 :0] r_fifo [`FIFO_DEPTH];
    logic [2:0] r_wptr, r_rptr;
    logic r_empty, r_full;

    assign r_full  = (r_wptr + 1 == r_rptr);
    assign r_empty = (r_wptr == r_rptr);

    always_ff @(posedge ACLK_s) begin
        if (!ARESETn_s) begin
            r_wptr <= 0;
            for (int i = 0; i < 8; i++)
                r_fifo[i] = 0;
        end
        else if (s0_rvalid && !r_full) begin 
            r_wptr <= r_wptr + 1;
            r_fifo[r_wptr] <= {s0_rid,s0_rdata,s0_rresp,s0_rlast};
        end
    end

    always_ff @(posedge ACLK_m) begin
        if (!ARESETn_m)
            r_rptr <= 0;
        else if (m0_rready && !r_empty) begin
            r_rptr <= r_rptr + 1;
        end
    end

    assign s0_rready = !r_full;
    assign {m0_rid,m0_rdata,m0_rresp,m0_rlast} = r_fifo[r_rptr];
    assign m0_rvalid = !r_empty;

endmodule
