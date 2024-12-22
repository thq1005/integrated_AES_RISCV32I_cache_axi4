
module fifo(
    input logic clk_i,
    input logic rst_ni,
    input logic we,
    input logic re,
    input logic d,
    output logic q,
    output logic full
    );
    
    logic empty;
    logic [3:0] fifo;
    logic [1:0] rp; //read pointer
    logic [1:0] wp; //write pointer
    
    always_ff @(posedge clk_i) begin
        if (~rst_ni) 
            rp <= 0;
        else 
            if (re && !empty) begin
                rp <= rp + 1;
                if (rp == wp) 
                    empty <= 1;
            end
    end
    
    always_ff @(posedge clk_i) begin
        if (~rst_ni) 
            wp <= 0;
        else 
            if (we && !full)
                wp <= wp + 1;
                if (rp == wp) 
                    full <= 1;
    end
    
    always_ff @(posedge clk_i) begin
        if (~rst_ni) begin
            fifo <= 0;
        end
        else begin
            if (we && !full)
                fifo[wp] <= d;
        end
    end
    
    always_ff @(posedge clk_i) begin
        if (~rst_ni) begin
            q <= 0;
        end
        else if (re && !empty)
            q = fifo[rp]; 
    end
    

endmodule
