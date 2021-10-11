module mux4_1

	#(parameter DEPTH = 32)
	
	(
		input			[DEPTH-1:0]			in0,
		input			[DEPTH-1:0]			in1,
		input			[DEPTH-1:0]			in2,
		input			[DEPTH-1:0]			in3,
		input			[1:0]					sel,
		output		[DEPTH-1:0]			out
	);
	
	assign out = sel[1] ? (sel[0] ? in3 : in2) : (sel[0] ? in1: in0);

	
endmodule