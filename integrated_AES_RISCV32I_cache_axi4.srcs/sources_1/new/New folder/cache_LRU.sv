`include "define.sv"

module cache_LRU(
    input logic clk_i,
    input logic rst_ni,
    input logic cs_i,
    input logic [`INDEX-1:0] index_i,
    input logic [`INDEX_WAY-1:0] address_i,
    output logic [`INDEX_WAY-1:0] address_o
    );

/* Tree-pLRU
             N0              access:      0 = left , 1 = right
         /      \            replacement: 0 = right, 1 = left
       N1        N2
     /   \     /   \
   |W0| |W1| |W2| |W3|   */

logic N0 [0:`DEPTH - 1];
logic N1 [0:`DEPTH - 1];
logic N2 [0:`DEPTH - 1];

always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
        integer i;
        for (i = 0; i < `DEPTH; i++) begin
            N0[i] <= 1'b0;
            N1[i] <= 1'b0;
            N2[i] <= 1'b0;
        end
    end
    else begin
        if (cs_i) begin
            N0[index_i] = address_i[1];
            if (!N0[index_i]) begin
                N1[index_i] = address_i[0];
            end
            else begin
                N2[index_i] = address_i[0]; 
            end
        end
    end 
end

always_comb begin
    casex ({N0[index_i],N1[index_i],N2[index_i]})
    3'b0x0: address_o = 2'b11;
    3'b0x1: address_o = 2'b10;
    3'b10x: address_o = 2'b01;
    3'b11x: address_o = 2'b00;
    default: address_o = 2'b00;
    endcase
end


endmodule
