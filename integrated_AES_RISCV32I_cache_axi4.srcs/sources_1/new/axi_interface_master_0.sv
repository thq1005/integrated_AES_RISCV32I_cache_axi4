`include "define.sv"

module axi_interface_master_0(
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
    input logic cs_i,
    output logic [`DATA_WIDTH_CACHE - 1:0] rdata_o,
    output logic rvalid_o,
    output logic handshaked_o
    );
    
    localparam IDLE = 4'd0, WA = 4'd1, W = 4'd2, B = 4'd3, RA = 4'd4, R = 4'd5;           
    logic [3:0] state, next_state;
    logic [1:0] len_cnt;
        
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
        if (!rst_ni) begin
            len_cnt = 0;
        end
        else if (state == IDLE) begin
            len_cnt = 3;
        end
        else if (state == W | state == R) begin
            if ((wvalid_o && wready_i) | (rvalid_i && rready_o))
                len_cnt = len_cnt - 1;
        end 
    end
    
    
    always_comb begin
        if (len_cnt == 3) 
            wdata_o = wdata_i[127:96];
        else if (len_cnt == 2) 
            wdata_o = wdata_i[95:64];
        else if (len_cnt == 1) 
            wdata_o = wdata_i[63:32];
        else if (len_cnt == 0)
            wdata_o = wdata_i[31:0];
    end
    
    always_ff @(posedge clk_i) begin
        if (!rst_ni) 
            rdata_o = 0;
        else if (state == R) begin
            if (rvalid_i && rready_o) begin
                if (len_cnt == 3) 
                    rdata_o[127:96] = rdata_i;
                else if (len_cnt == 2) 
                    rdata_o[95:64] = rdata_i;
                else if (len_cnt == 1) 
                    rdata_o[63:32] = rdata_i;
                else if (len_cnt == 0) begin
                    rdata_o[31:0] = rdata_i;
                end
            end 
        end
    end
    
    assign handshaked_o = (state == R)?1:0;
    
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            rvalid_o = 0;
        end 
        else if (rlast_i) 
            rvalid_o = 1;
        else 
            rvalid_o = 0;
    end
    
    assign handshake_o = (state == R)?1:0;
    always_ff @(posedge clk_i) begin
        if (!rst_ni) begin
            awaddr_o <= 0;
            wstrb_o <= 0;
            araddr_o <= 0;
        end else if (state == IDLE) begin
            awaddr_o <= addr_i;
            wstrb_o  <= 4'hf;
            araddr_o <= addr_i;
        end
        else begin
            awaddr_o  <= awaddr_o;
            wstrb_o   <= wstrb_o;
            araddr_o  <= araddr_o; 
        end
    end
      
    assign arid_o    = 1;
    assign arlen_o   = 3;
    assign arsize_o  = 2;
    assign arburst_o = 1;
    assign rready_o  = (state == R);
    assign arvalid_o = (state == RA);
    
    assign awid_o    = 1;
    assign awlen_o   = 3;
    assign awsize_o  = 2;
    assign awburst_o = 1;
    assign awvalid_o = (state == WA);
    
    assign wlast_o  = ((state == W) && (len_cnt == 0));
    assign wvalid_o = (state == W);
    assign bready_o = (state == B);
                 
        
endmodule
