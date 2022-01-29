module ImmGen

	(
		input			[31:0]		instr,
		output reg	[31:0]		imm
	);
	
	
	always @(*)
		case (instr[6:0])
			// B
			7'b1100011: imm <= {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
			// I
			7'b1100111: imm <= {{21{instr[31]}}, instr[30:20]};
			// J
			7'b1101111: imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
			// U
			7'b0110111: imm <= {instr[31:12], 12'b0};
			7'b0010111: imm <= {instr[31:12], 12'b0};
			// I
			7'b0010011: imm <= {{21{instr[31]}}, instr[30:20]};
			// R
			7'b0110011: imm <= 32'b0;
			// I
			7'b0011011: imm <= {{21{instr[31]}}, instr[30:20]};
			// R
			7'b0111011: imm <= 32'b0;
			// I
			7'b0000011: imm <= {{21{instr[31]}}, instr[30:20]};
			// S
			7'b0100011: imm <= {{21{instr[31]}}, instr[30:25], instr[11:7]};
			default: imm <= 32'b0;
		endcase

endmodule
