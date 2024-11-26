
module memory(
    input logic clk_i,
    input logic rst_ni,
    input logic [31:0] addr_i,
    input logic [31:0] wdata_i,
    input logic rw_i,
	/* ------------ */
    output logic [31:0] rdata_o
);

	/* Spec of memory */
	/*
	 4KB instruction and data, the first 2KB for instruction and the second 2KB for data
	 Address:
	 	0 -> 511 : instructions
		512 -> 1023 : data memory
	
	*/
	/* -------------- */

	/* imem */
	logic [31:0] imem [512]; //2KB instruction memory
	
	initial begin
		$readmemh("memfile.txt", imem); 
	end

	/* ------------- */

	/* dmem */

	logic [31:0] dmem [512]; 
	
	logic temp;
	
	assign temp = (addr_i > 511) ? 1 : 0; 
	always_ff @(posedge clk_i) begin
	    if (!rst_ni) begin
	       for (int i = 0;i < 512; i++) begin
	           dmem[i] = '0;
	       end
	    end
		else if (rw_i) begin
			dmem[addr_i[31:2]-512]   <= wdata_i;
		end
	end


	/* --------------- */

	always_ff @(posedge clk_i) begin
		if (!rst_ni) begin
		    rdata_o  = 32'b0;
		end
		else if (!temp) 
		    rdata_o = imem[addr_i[31:2]];
		else 
		    rdata_o = dmem[addr_i[31:2]-512];
	end

endmodule
