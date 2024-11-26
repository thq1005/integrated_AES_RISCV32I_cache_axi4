`include "define.sv"
module cpu_wrapper  (
  input logic clk_i,
  input logic rst_ni,
  // master 0 - RAM
  //AW channel
  output logic [`ID_BITS - 1:0] awid_m0,
  output logic [`ADDR_WIDTH - 1:0] awaddr_m0,
  output logic [`LEN_BITS - 1:0] awlen_m0,
  output logic [`SIZE_BITS -1 :0] awsize_m0,
  output logic [1:0] awburst_m0,
  output logic awvalid_m0,
  input  logic awready_m0,
  //W channel
  output logic [`DATA_WIDTH - 1:0] wdata_m0,
  output logic [(`DATA_WIDTH/8)-1:0] wstrb_m0,
  output logic wvalid_m0,
  output logic wlast_m0,
  input  logic wready_m0,
  //B channel
  input  logic [`ID_BITS - 1:0] bid_m0,
  input  logic [2:0] bresp_m0,
  input  logic bvalid_m0,
  output logic bready_m0,
  //AR channel
  output logic [`ID_BITS - 1:0] arid_m0,
  output logic [`ADDR_WIDTH - 1:0] araddr_m0,
  output logic [`LEN_BITS - 1:0] arlen_m0,
  output logic [1:0] arburst_m0,
  output logic [`SIZE_BITS - 1:0] arsize_m0,
  output logic arvalid_m0,
  input  logic arready_m0,
  //R channel
  input  logic [`ID_BITS - 1:0] rid_m0,
  input  logic [`DATA_WIDTH - 1:0] rdata_m0,
  input  logic [2:0] rresp_m0,
  input  logic rvalid_m0,
  input  logic rlast_m0,
  output logic rready_m0
);


logic [`ADDR_WIDTH-1:0] addr_o;
logic [`DATA_WIDTH-1:0] wdata_o;
logic rw_o;


riscv_cache cpu_inst (.clk (clk),
                      .rst (rst),
                      .inst(inst),
                      .prg_addr(prg_addr),
                      .addr_dmem(o_DM_addr),
                      .wdata_dmem(o_DM_wdata),
                      .write_dmem(o_DM_write),
                      .read_dmem(o_DM_read),
                      .dmem_rdata(rdata_m0));
              
localparam IDLE = 4'd0, WA = 4'd1, W = 4'd2, B = 4'd3, RA = 4'd4, R = 4'd5;           
logic [3:0] m0_state, m0_next_state;
logic [3:0] m1_state, m1_next_state;

always @(posedge clk) begin
    if(!rst) 
        m0_state <= 0;
    else
        m0_state <= m0_next_state; 
end         
            
always @(o_DM_write or o_DM_read or m0_state) begin
    case (m0_state)
    IDLE: begin
        if (o_DM_write)
            m0_next_state = WA;
        else if (o_DM_read)
            m0_next_state = RA;
        else 
            m0_next_state = IDLE;
    end        
    WA: begin
        if (awvalid_m0 && awready_m0)
            m0_next_state = W;
        else
            m0_next_state = WA;
    end
    W: begin
        if (wvalid_m0 && wready_m0 && wlast_m0)
            m0_next_state = B;
        else
            m0_next_state = W;
    end
    B: begin
        if (bvalid_m0 && bready_m0) 
            m0_next_state = IDLE;
        else 
            m0_next_state = B;
    end
    RA: begin
        if (arvalid_m0 && arready_m0)
            m0_next_state = R;
        else 
            m0_next_state = RA;    
    end
    R: begin
        if (rvalid_m0 && rready_m0 && rlast_m0)
            m0_next_state = IDLE;
        else 
            m0_next_state = R;
    end
    endcase
end    

always @(posedge clk or posedge rst) begin
    if (rst) begin
        awaddr_m0 <= 0;
        wdata_m0 <= 0;
        wstrb_m0 <= 0;
        araddr_m0 <= 0;
    end else if (m0_state == IDLE) begin
        awaddr_m0 <= o_DM_addr;
        wdata_m0 <= o_DM_wdata;
        wstrb_m0 <= 4'hf;
        araddr_m0 <= o_DM_addr;
    end
    else begin
        awaddr_m0 <= awaddr_m0;
        wdata_m0 <= wdata_m0;
        wstrb_m0 <= wstrb_m0;
        araddr_m0 <= o_DM_addr; 
    end
end
  
assign arid_m0 = 1;
assign arlen_m0 = 0;
assign arsize_m0 = 3;
assign arburst_m0 = 0;
assign rready_m0 = (m0_state == R);
assign arvalid_m0 = (m0_state == RA);

assign awid_m0 = 1;
assign awlen_m0 = 0;
assign awsize_m0 = 0;
assign awburst_m0 = 0;
assign awvalid_m0 = (m0_state == WA);

assign wlast_m0 = (m0_state == W);
assign wvalid_m0 = (m0_state == W);
assign bready_m0 = (m0_state == B);
              

endmodule
