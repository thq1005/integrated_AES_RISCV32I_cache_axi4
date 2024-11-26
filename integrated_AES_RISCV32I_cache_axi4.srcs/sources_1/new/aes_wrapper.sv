`include "define.sv"

module aes_wrapper (
  input logic clk_i,
  input logic rst_ni,
  // AXI interface
  //AW channel
  input logic [`ID_BITS - 1:0] awid,
  input logic [`ADDR_WIDTH - 1:0] awaddr,
  input logic [`LEN_BITS - 1:0] awlen,
  input logic [`SIZE_BITS -1 :0] awsize,
  input logic [1:0] awburst,
  input logic awvalid,
  output logic awready,
  //W channel
  input logic [`DATA_WIDTH - 1:0] wdata,
  input logic [(`DATA_WIDTH/8)-1:0] wstrb,
  input logic wvalid,
  input logic wlast,
  output logic wready,
  //B channel
  output logic [`ID_BITS - 1:0] bid,
  output logic [2:0] bresp,
  output logic bvalid,
  input logic bready,
  //AR channel
  input logic [`ID_BITS - 1:0] arid,
  input logic [`ADDR_WIDTH - 1:0] araddr,
  input logic [`LEN_BITS - 1:0] arlen,
  input logic [1:0] arburst,
  input logic [`SIZE_BITS - 1:0] arsize,
  input logic arvalid,
  output logic arready,
  //R channel
  output logic [`ID_BITS - 1:0] rid,
  output logic [`DATA_WIDTH - 1:0] rdata,
  output logic [2:0] rresp,
  output logic rvalid,
  output logic rlast,
  input logic rready
);
parameter IDLE = 3'b000, READ_ADDR = 3'b001, READ_DATA = 3'b010, WRITE_ADDR = 3'b011, WRITE_DATA = 3'b100, WRITE_RESPONSE = 3'b101;
logic  [2:0] state;
logic  [2:0] next_state;
logic  [`SIZE_BITS - 1 :0] arsizereg;
logic  [`ADDR_WIDTH - 1 :0] araddr_reg, awaddr_reg;
logic  [1:0] arsizecnt,awsizecnt; 
logic  [3:0] read_burst_cnt,write_burst_cnt;
logic  [`ADDR_WIDTH - 1:0] A;
logic  [`DATA_WIDTH - 1:0] Q;
logic rw;


aes aes_inst (.clk_i   (clk_i),
              .rst_ni  (rst_ni),
              .addr_i  (A),
              .wdata_i (wdata),
              .we_i    (rw),
              .rdata_o (Q)
         );

integer i;

always_ff @(posedge clk_i) begin
    if (!rst_ni) 
        state <= IDLE;
    else 
        state <= next_state;
end

always_comb begin
    case (state)
        IDLE: begin 
            if (awvalid) 
                next_state = WRITE_ADDR;
            else if (arvalid)
                next_state = READ_ADDR;
            else
                next_state = IDLE;
        end
        WRITE_ADDR: begin
            if (awvalid && awready) 
                next_state = WRITE_DATA;
            else
                next_state = WRITE_ADDR;         
        end
        WRITE_DATA: begin
            if (wvalid && wready && wlast) 
                next_state = WRITE_RESPONSE;
            else
                next_state = WRITE_DATA;         
        end
        WRITE_RESPONSE: begin
            if (bvalid && bready) 
                next_state = IDLE;
            else
                next_state = WRITE_RESPONSE;         
        end
        READ_ADDR: begin
            if (arvalid && arready) 
                next_state = READ_DATA;
            else
                next_state = READ_ADDR;         
        end
        READ_DATA: begin
            if (rvalid && rready && rlast) 
                next_state = IDLE;
            else
                next_state = READ_DATA;         
        end
    endcase    
end

assign awready = (state == WRITE_ADDR) ? 1'b1 : 1'b0;
assign wready  = (state == WRITE_DATA) ? 1'b1 : 1'b0;
assign bresp   = `RESP_OKAY;
assign bvalid  = (state == WRITE_RESPONSE) ? 1'b1 : 1'b0;
assign arready = (state == READ_ADDR) ? 1'b1 : 1'b0;
assign rw      = ((state == WRITE_DATA) && wvalid) ? 1'b1 : 1'b0;

always_ff @(posedge clk_i) begin
    if (!rst_ni) 
        arsizereg <= 0;
    else if (arvalid && arready)
        arsizereg <= arsize; 
    else
        arsizereg <= arsizereg; 
end


//burst cnt
always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        arsizecnt <= 0;
    end else begin
        if (arvalid && arready) begin 
            if (arsize == 0) 
                arsizecnt <= 3;
            else if (arsize == 1) 
                arsizecnt <= 2;
            else 
                arsizecnt <= 0;
        end
        else if (rvalid && rready) begin
            if (arsize == 0)
                arsizecnt <= arsizecnt - 1;
            else if (arsize == 1) 
                arsizecnt <= arsizecnt - 2;
            else 
                arsizecnt <= 0;
        end
    end
end

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        awsizecnt <= 0;
    end else begin
        if (awvalid && awready) begin 
            if (awsize == 0) 
                awsizecnt <= 3;
            else if (awsize == 1) 
                awsizecnt <= 2;
            else 
                awsizecnt <= 0;
        end
        else if (wvalid && wready) begin
            if (awsize == 0)
                awsizecnt <= awsizecnt - 1;
            else if (awsize == 1) 
                awsizecnt <= awsizecnt - 2;
            else 
                awsizecnt <= 0;
        end
    end
end

always_comb begin
    if (arsizereg == 0) begin
        if (arsizecnt == 3)
            rdata = Q[7:0];
        else if (arsizecnt == 2)
            rdata = Q[15:8];
        else if (arsizecnt == 1)
            rdata = Q[23:16];
        else 
            rdata = Q[31:24];
    end
    else if (arsizereg == 1) begin
        if (arsizecnt == 2)
            rdata = Q[15:0];
        else 
            rdata = Q[31:16];
    end
    else 
        rdata = Q;
end

assign rresp    = `RESP_OKAY;
assign rlast    = ((state == READ_DATA) && (read_burst_cnt == 0)) ? 1'b1 : 1'b0;
assign rvalid   = (state == READ_DATA) ? 1'b1 : 1'b0;

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        bid <= 0;
        rid <= 0;    
    end else begin
        bid <= (awvalid && awready) ? awid : bid;
        rid <= (arvalid && arready) ? arid : rid;
    end

end

//ADDR
always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        read_burst_cnt <= 0;
        araddr_reg <= 0;
    end else begin
        if (arvalid && arready) begin
            read_burst_cnt <= arlen;
            araddr_reg <= araddr;
        end else if (rvalid && rready) begin
            read_burst_cnt <= read_burst_cnt - 1;
            if (arsizecnt == 0)
                araddr_reg <= araddr_reg + 4;
            else 
                araddr_reg <= araddr_reg;
        end
    end
end

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        write_burst_cnt <= 0;
        awaddr_reg <= 0;
    end else begin
        if (awvalid && awready) begin
            write_burst_cnt <= awlen;
            awaddr_reg <= awaddr;
        end else if (wvalid && wready) begin
            write_burst_cnt <= write_burst_cnt - 1;
            if (arsizecnt == 0)
                awaddr_reg <= awaddr_reg + 4;
            else 
                awaddr_reg <= awaddr_reg;
        end
    end
end

assign A = (rw) ? awaddr_reg : araddr_reg;

endmodule
