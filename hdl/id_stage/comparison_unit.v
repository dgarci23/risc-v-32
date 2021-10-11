module comparison_unit

	#(parameter WIDTH = 32)

	(
		input			[WIDTH-1:0]			a,
		input			[WIDTH-1:0]			b,
		input			[2:0]					sel,
		output reg							flag
	);
	
	
	always @(*)
		case (sel)
			0: flag <= (a == b);
			1: flag <= (a!=b);
			2: flag <= (a < b);
			3: flag <= ($signed(a) < $signed(b));
			4: flag <= (a > b);
			5: flag <= ($signed(a) > $signed(b));
			default: flag <= 0;
		endcase
		
endmodule