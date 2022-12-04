module debouncer 

	#(parameter SIZE = 1)

	(
		input 						clk,
		input 		[SIZE-1:0]	in,
		output reg 	[SIZE-1:0]	out
	);
	
	reg [19:0] count;
	
	always @(posedge clk)
		count <= count + 1'b1;
		
	always @(posedge count[19])
		out <= in;

endmodule