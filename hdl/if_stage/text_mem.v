module text_mem 
	
	#(parameter DEPTH = 8, parameter WIDTH = 128)
	
	(
		input			[4*DEPTH-1:0]			raddr,
		//input										clk,
		//input			[DEPTH-1:0]				in,	
		//input										we,
		//input										rst,
		output 		[4*DEPTH-1:0]			out
	);
	
	reg [DEPTH-1:0] text [WIDTH-1:0];
	reg [$clog2(WIDTH):0] waddr;
	

	
	initial begin $readmemb("text.mem", text, 0, 255); end
	//initial begin $readmemb("hdl/if_stage/text.mem", text, 0, 255); end
	

	assign out = {text[raddr+3], text[raddr+2], text[raddr+1], text[raddr]};
	
endmodule
