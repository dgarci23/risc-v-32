module alu
	
	#(parameter WIDTH = 32)
	
	(
		input				[WIDTH-1:0]		a,
		input				[WIDTH-1:0]		b,
		input				[3:0]				ALUOp,
		output	reg	[WIDTH-1:0]		out
	);
	
	always @(*)
		case (ALUOp)
			0: out = a&b;
			1: out = a|b;
			2: out = a + b;
			3: out = a - b;
			4: out = a^b;
			5: out = a<<(b[4:0]);
			6: out = a>>(b[4:0]);
			7: out = a>>>(b[4:0]);
			8:	out = ($signed(a) < $signed(b));
			9: out = (a < b);
			default: out = 0;
		endcase

endmodule