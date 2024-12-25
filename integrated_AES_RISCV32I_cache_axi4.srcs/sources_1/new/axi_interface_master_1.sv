`include "define.sv"

module axi_interface_master_1(
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
    input logic [`DATA_WIDTH - 1:0] wdata_i,
    input logic we_i,
    input logic cs_i,
    output logic [`DATA_WIDTH - 1:0] rdata_o,
    output logic rvalid_o
    );
    
    localparam IDLE = 4'd0, WA = 4'd1, W = 4'd2, B = 4'd3, RA = 4'd4, R = 4'd5;           
    logic [3:0] state, next_state;
        
    always_ff @(posedge clk_i) begin
        if(~rst_ni) 
            state <= 0;
        else
            state <= next_state; 
    end         
                
    always_comb begin
        case (state)
        IDLE: begin
            if (we_i && cs_i)
                next_state = WA;
            else if (!we_i && cs_i)
                next_state = RA;
            else 
                next_state = IDLE;
        end        
        WA: begin
            if (awvalid_o && awready_i)
                next_state = W;
            else
                next_state = WA;
        end
        W: begin
            if (wvalid_o && wready_i && wlast_o)
                next_state = B;
            else
                next_state = W;
        end
        B: begin
            if (bvalid_i && bready_o) 
                next_state = IDLE;
            else 
                next_state = B;
        end
        RA: begin
            if (arvalid_o && arready_i)
                next_state = R;
            else 
                next_state = RA;    
        end
        R: begin
            if (rvalid_i && rready_o && rlast_i)
                next_state = IDLE;
            else 
                next_state = R;
        end
        endcase
    end    
    
    
    always_ff @(posedge clk_i) begin
        if (!rst_ni) 
            rdata_o = 0;
        else if (state == R) begin
            if (rvalid_i && rready_o) begin
                    rdata_o = rdata_i;
            end
        end 
    end
    
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            rvalid_o = 0;
        end 
        else if (rlast_i) 
            rvalid_o = 1;
        else 
            rvalid_o = 0;
    end
    
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            awaddr_o <= 0;
            wstrb_o  <= 0;
            wdata_0  <= 0;
            araddr_o <= 0;
        end else if (state == IDLE) begin
            awaddr_o <= addr_i;
            wstrb_o  <= 4'hf;
            wdata_o  <= wdata_i; 
            araddr_o <= addr_i;
        end
        else begin
            awaddr_o  <= awaddr_o;
            wdata_o   <= wdata_o;
            wstrb_o   <= wstrb_o;
            araddr_o  <= araddr_o; 
        end
    end
      
    assign arid_o    = 2;
    assign arlen_o   = 0;
    assign arsize_o  = 2;
    assign arburst_o = 0;
    assign rready_o  = (state == R);
    assign arvalid_o = (state == RA);
    
    assign awid_o    = 2;
    assign awlen_o   = 0;
    assign awsize_o  = 2;
    assign awburst_o = 0;
    assign awvalid_o = (state == WA);
    
    assign wlast_o  = (state == W);
    assign wvalid_o = (state == W);
    assign bready_o = (state == B);
                 
        
endmodule