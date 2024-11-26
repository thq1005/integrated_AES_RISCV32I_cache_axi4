module gm14 (input logic [7:0] in,
             output logic [7:0] out);

logic gm13_w;

gm13 gm13 (.in (in),
           .out(gm11_w));

assign out = gm13_w ^ in;
    
endmodule