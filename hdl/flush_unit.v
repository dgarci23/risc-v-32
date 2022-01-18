module flush_unit

	#(parameter WIDTH = 32)
	
	(
		input			[WIDTH-1:0]		in,
		input								sel,
		output		[WIDTH-1:0]		out
	);
	
	assign out = sel ? 1'b0 : in;
	
endmodule