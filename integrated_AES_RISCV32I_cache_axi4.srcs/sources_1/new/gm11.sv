module gm11 (input logic [7:0] in,
             output logic [7:0] out);

logic gm9_w;
logic gm2_w;
gm9 gm9 (.in (in),
         .out(gm9_w));
         
gm2 gm2 (.in (in),
         .out(gm2_w));
assign out = gm9_w ^ gm2_w;
    
endmodule