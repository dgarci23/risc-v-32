module mux2_1
	
	#(parameter DEPTH = 32)
	
	(
		input 			[DEPTH-1:0]		in0,
		input				[DEPTH-1:0]		in1,
		input									sel,
		output	reg	[DEPTH-1:0]		out
	);	
	
	always @(*)
		if (sel)
			out <= in1;
		else
			out <= in0;

endmodule