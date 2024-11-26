module gm13 (input logic [7:0] in,
             output logic [7:0] out);

logic gm11_w;
logic gm2_w;
gm11 gm11 (.in (in),
           .out(gm11_w));
         
gm2 gm2 (.in (in),
         .out(gm2_w));
assign out = gm11_w ^ gm2_w;
    
endmodule