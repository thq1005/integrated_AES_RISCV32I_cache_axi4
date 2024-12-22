`timescale 1ns / 1ps
`include "Packet.sv"

program automatic cpu_test (RISCV_io.TB cpu_io);
logic [3:0] numofins;
logic [31:0] inst_arr [16];
Packet pkt2send[16];
integer i;
initial begin 
    reset();
    test1();
    driver();
    #15000;
    $finish;
end
task reset();
    cpu_io.rst_ni <= 0;
    @cpu_io.cb;
    cpu_io.cb.rst_ni <= 1; 
endtask
task gen();   
    numofins = 10;
    for (i=0;i<numofins;i = i+1) begin
        pkt2send[i] = new();
        pkt2send[i].randomize();
        pkt2send[i].gen();
        pkt2send[i].display("Instruction:");
        inst_arr[i]=pkt2send[i].instruction;
    end  
    for (i=numofins;i<16;i=i+1) begin
        inst_arr[i] = 32'h00000000;
    end    
endtask

task test1();
    //lui x2,0xA
    pkt2send[0] = new();
    pkt2send[0].randomize() with {opcode == 7'h37; rd == 2; imm_1 == 11;};
    pkt2send[0].gen();
    pkt2send[0].display("Instruction:");
    inst_arr[0]=pkt2send[0].instruction;
    // addi x2,x2,0x550
    pkt2send[1] = new();
    pkt2send[1].randomize() with {opcode == 7'h13; funct3 == 0; rd == 2; rs1 == 2; imm_0 == 1360;};
    pkt2send[1].gen();
    pkt2send[1].display("Instruction:");
    inst_arr[1]=pkt2send[1].instruction;
    // addi x2,x2,0x550
    pkt2send[2] = new();
    pkt2send[2].randomize() with {opcode == 7'h13; funct3 == 0; rd == 2; rs1 == 2; imm_0 == 1360;};
    pkt2send[2].gen();
    pkt2send[2].display("Instruction:");
    inst_arr[2]=pkt2send[2].instruction;
    //lui x4,0xAAAA0
    pkt2send[3] = new();
    pkt2send[3].randomize() with {opcode == 7'h37; rd == 4; imm_1 == 699040;};
    pkt2send[3].gen();
    pkt2send[3].display("Instruction:");
    inst_arr[3]=pkt2send[3].instruction;
    //lui x3,0x0
    pkt2send[4] = new();
    pkt2send[4].randomize() with {opcode == 7'h37; rd == 3; imm_1 == 0;};
    pkt2send[4].gen();
    pkt2send[4].display("Instruction:");
    inst_arr[4]=pkt2send[4].instruction;
    //ori x3,x3,0x10
    pkt2send[5] = new();
    pkt2send[5].randomize() with {opcode == 7'h13; funct3 == 6; rd == 3; rs1 == 3; imm_0 == 16;};
    pkt2send[5].gen();
    pkt2send[5].display("Instruction:");
    inst_arr[5]=pkt2send[5].instruction;
    //addi x3,x3,0x04 (loop = 0x20)
    pkt2send[6] = new();
    pkt2send[6].randomize() with {opcode == 7'h13; funct3 == 0; rd == 3; rs1 == 3; imm_0 == 4;};
    pkt2send[6].gen();
    pkt2send[6].display("Instruction:");
    inst_arr[6]=pkt2send[6].instruction;
    //addi x2,x2,0x01
    pkt2send[7] = new();
    pkt2send[7].randomize() with {opcode == 7'h13; funct3 == 0; rd == 2; rs1 == 2; imm_0 == 1;};
    pkt2send[7].gen();
    pkt2send[7].display("Instruction:");
    inst_arr[7]=pkt2send[7].instruction;
    //sw x0,0(x3)
    pkt2send[8] = new();
    pkt2send[8].randomize() with {opcode == 7'h23; funct3 == 2; rs2 == 0; rs1 == 3; imm_0 == 0;};
    pkt2send[8].gen();
    pkt2send[8].display("Instruction:");
    inst_arr[8]=pkt2send[8].instruction;
    //sh x2,2(x3)
    pkt2send[9] = new();
    pkt2send[9].randomize() with {opcode == 7'h23; funct3 == 1; rs2 == 2; rs1 == 3; imm_0 == 2;};
    pkt2send[9].gen();
    pkt2send[9].display("Instruction:");
    inst_arr[9]=pkt2send[9].instruction;
    //lw x1,0(x3)
    pkt2send[10] = new();
    pkt2send[10].randomize() with {opcode == 7'h03; funct3 == 2; rd == 1; rs1 == 3; imm_0 == 0;};
    pkt2send[10].gen();
    pkt2send[10].display("Instruction:");
    inst_arr[10]=pkt2send[10].instruction;
    //bne x1,x4,loop
    pkt2send[11] = new();
    pkt2send[11].randomize() with {opcode == 7'h63; funct3 == 1; rs2 == 1; rs1 == 4; imm_0 == 12'hFF6;};
    pkt2send[11].gen();
    pkt2send[11].display("Instruction:");
    inst_arr[11]=pkt2send[11].instruction;
    //jal x4,done (done = 48)
    pkt2send[12] = new();
    pkt2send[12].randomize() with {opcode == 7'h6F;rd == 4; imm_1 == 0;};
    pkt2send[12].gen();
    pkt2send[12].display("Instruction:");
    inst_arr[12]=pkt2send[12].instruction;
    for (i=12;i<16;i=i+1) begin
        inst_arr[i] = 32'h00000000;
    end    
endtask
task driver();
    repeat(120) begin
    @(cpu_io.re_o) begin  
    case(cpu_io.raddr_o)
    32'h00000000: cpu_io.cb.rdata_i <= {inst_arr[0],inst_arr[1],inst_arr[2],inst_arr[3]}; 
    32'h00000010: cpu_io.cb.rdata_i <= {inst_arr[4],inst_arr[5],inst_arr[6],inst_arr[7]};  
    32'h00000020: cpu_io.cb.rdata_i <= {inst_arr[8],inst_arr[9],inst_arr[10],inst_arr[11]}; 
    32'h00000030: cpu_io.cb.rdata_i <= {inst_arr[12],24'h000}; 
    default: cpu_io.cb.data <= 32'h00000000; 
    endcase
    end
    end
endtask
endprogram:test
