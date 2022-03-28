module text_mem 
	
	#(parameter DEPTH = 8, parameter WIDTH = 256)
	
	(
		input			[4*DEPTH-1:0]			addr,
		output 		[4*DEPTH-1:0]			out
	);
	
	reg [DEPTH-1:0] text [WIDTH-1:0];
	
	initial begin $readmemb("text.mem", text, 0, 255); end
	//initial begin $readmemb("text.txt", text, 0, 255); end

	assign out = {text[addr+3], text[addr+2], text[addr+1], text[addr]};
	
endmodule
