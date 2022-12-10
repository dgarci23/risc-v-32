module test_mem 
	
	#(parameter DEPTH = 8, parameter WIDTH = 128, parameter MODE="test")
	
	(
		input			[4*DEPTH-1:0]			addr,
		input									clk,
		input			[4*DEPTH-1:0]			in,	
		input			[3:0]					byteen,
		input									we,
		output 		[4*DEPTH-1:0]				out
	);
	
	reg [4*DEPTH-1:0] text [WIDTH-1:0];
	
	initial begin 
		if (MODE=="test") begin
			$readmemb("hdl/if_stage/text.mem", text, 0, WIDTH-1);
		end else begin
			for (int i =0; i < WIDTH; i++) begin
				text[i] = 0;
			end
		end
	end

	assign out = text[addr];

	always @(posedge clk) begin
		if (we) begin
			if (byteen[0]) begin
				text[addr][0+:8] <= in[7:0];
			end
			if (byteen[1]) begin
				text[addr][8+:8] <= in[15:8];
			end
			if (byteen[2]) begin
				text[addr][16+:8] <= in[23:16];
			end
			if (byteen[3]) begin
				text[addr][24+:8] <= in[31:24];
			end
		end	
	end
	
endmodule