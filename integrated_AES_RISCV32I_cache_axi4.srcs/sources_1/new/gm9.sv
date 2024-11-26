module gm9 (input logic [7:0] in,
            output logic [7:0] out);
            
logic gm2_w;
logic gm4_w;

gm2 gm2 (.in (in),
         .out(gm2_w));
         
gm4 gm4 (.in (gm2_w),
         .out(gm4_w));
                
assign out = gm4_w ^ in;
    
endmodule