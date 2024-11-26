`include "define.sv"

module cache_array(
    input logic clk_i,
    input logic rst_ni,
    //request
    input logic [`INDEX-1:0] index_i,
    input logic we_i,
    //tag
    input logic valid_i,
    input logic dirty_i,
    input logic [25:0] tag_i,
    input logic [`INDEX_WAY-1:0] address_way_i,
    input logic [31:0] cpu_address_i,
    output logic [`INDEX_WAY-1:0] address_way_o,
    output logic valid_o,
    output logic dirty_o,
    output logic [24:0] tag_o,
    output logic full_o,
    //data
    input logic [127:0] data_write_i,
    output logic [127:0] data_read_o
    );
    
    logic valid_mem [0:`DEPTH-1][0:`INDEX_WAY-1];
    logic dirty_mem [0:`DEPTH-1][0:`INDEX_WAY-1];
    logic [25:0] tag_mem [0:`DEPTH-1][0:`INDEX_WAY-1];
    logic [`DATA_WIDTH_CACHE-1:0] data_mem [0:`DEPTH-1][0:`INDEX_WAY-1];
    
    logic [3:0] offset;
    logic hit [0:`WAYS - 1];
    
    logic [`INDEX_WAY-1:0] way_w;
    logic [`INDEX_WAY-1:0] address_way_w;
    
    //intital cache
    initial begin
        for (int i = 0;i < `DEPTH ; i++)
            for (int j = 0;j < `WAYS ; j++) begin
                valid_mem[i][j] = 0;
                dirty_mem[i][j] = 0;
                tag_mem[i][j] = 0;
                data_mem[i][j] = 0;
            end
    end
    
    //
    assign offset = cpu_address_i[3:0];
    
    always_comb begin 
        for(int i = 0; i < `WAYS ; i++) begin
            hit[i] = ((cpu_address_i[`TAGMSB:`TAGLSB]==tag_mem[index_i][i]) && valid_mem [index_i][i]) ? 1 : 0;
        end
        
        case ({hit[3],hit[2],hit[1],hit[0]})
            4'b1000: begin
                address_way_w = 2'b11;
                valid_o = valid_mem [index_i][3];
                dirty_o = dirty_mem [index_i][3];
                tag_o = tag_mem [index_i][3];
                data_read_o = data_mem [index_i][3];
             end
             4'b0100: begin
                address_way_w = 2'b10;
                valid_o = valid_mem [index_i][2];
                dirty_o = dirty_mem [index_i][2];
                tag_o = tag_mem [index_i][2];
                data_read_o = data_mem [index_i][2];
             end
             4'b0010: begin
                address_way_w = 2'b01;
                valid_o = valid_mem [index_i][1];
                dirty_o = dirty_mem [index_i][1];
                tag_o = tag_mem [index_i][1];
                data_read_o = data_mem [index_i][1];
             end
             4'b0001: begin
                address_way_w = 2'b00;
                valid_o = valid_mem [index_i][0];
                dirty_o = dirty_mem [index_i][0];
                tag_o = tag_mem [index_i][0];
                data_read_o = data_mem [index_i][0];
             end
             default: begin
                address_way_w = address_way_i;
                valid_o = valid_mem [index_i][address_way_i];
                dirty_o = dirty_mem [index_i][address_way_i];
                tag_o = tag_mem [index_i][address_way_i];
                data_read_o = data_mem [index_i][address_way_i];
             end
          endcase
    end
    
    assign full_o = valid_mem[index_i][0] &
                    valid_mem[index_i][1] &
                    valid_mem[index_i][2] &
                    valid_mem[index_i][3];
                    
    assign way_w = (hit[3]|hit[2]|hit[1]|hit[0]) ? address_way_w : address_way_i;
    
    assign address_way_o = (we_i)? way_w : address_way_w;
    
    always_ff @(posedge clk_i) begin
        if (we_i) begin
            valid_mem[index_i][way_w] = valid_i;
            dirty_mem[index_i][way_w] = dirty_i;
            tag_mem [index_i][way_w]  = tag_i;
            data_mem [index_i][way_w] = data_write_i;
        end
    end
endmodule
