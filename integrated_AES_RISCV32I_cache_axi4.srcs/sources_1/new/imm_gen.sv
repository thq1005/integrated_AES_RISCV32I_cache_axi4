`include "define.sv"
module imm_gen(
	input logic [31:7] inst_i,
	input logic [3:0] ImmSel_i,
	output logic [31:0] imm_o
	);
		
	assign imm_o = 		(ImmSel_i == `I_TYPE) 			? {{21{inst_i[31]}}, inst_i[30:20]} :
				 		(ImmSel_i == `S_TYPE) 			? {{21{inst_i[31]}}, inst_i[30:25], inst_i[11:7]} : 
						(ImmSel_i == `B_TYPE) 			? {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0} : 
						(ImmSel_i == `J_TYPE) 			? {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0} : 
						(ImmSel_i == `U_TYPE) 			? {inst_i[31:12], {12{1'b0}}} : 
						(ImmSel_i == `AES_BLOCK_TYPE) 	? {24'h000000,`ADDR_BLOCK0}:
						(ImmSel_i == `AES_KEY_TYPE) 	? {24'h000000,`ADDR_KEY0} :
						(ImmSel_i == `AES_CTRL_TYPE) 	? {24'h000000,`ADDR_CTRL} :
						(ImmSel_i == `AES_CONFIG_TYPE) 	? {24'h000000,`ADDR_CONFIG} : 
						(ImmSel_i == `AES_STATUS_TYPE) 	? {24'h000000,`ADDR_STATUS} : 
						(ImmSel_i == `AES_RESULT_TYPE) 	? {24'h000000,`ADDR_RESULT0} : 32'h00000000;
	
endmodule

