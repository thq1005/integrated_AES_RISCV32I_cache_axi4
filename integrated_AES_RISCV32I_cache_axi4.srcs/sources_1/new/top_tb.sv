`timescale 1ns / 1ps
module top_tb;
    logic clk_1_i;
    logic clk_2_i;
    logic rst_ni;
    
    top top_inst (.clk_1_i (clk_1_i),
                  .clk_2_i (clk_2_i),
                  .rst_ni  (rst_ni));
    
    always #5 clk_1_i = ~clk_1_i;
    always #5 clk_2_i = ~clk_2_i;
    
    initial begin
        clk_1_i = 0;
        clk_2_i = 0;
        rst_ni  = 0;
        #20;
        rst_ni  = 1;
    end
endmodule
