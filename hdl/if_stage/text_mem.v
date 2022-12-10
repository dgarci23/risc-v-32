module text_mem 
	
	#(parameter DEPTH = 8, parameter WIDTH = 128)
	
	(
		input			[4*DEPTH-1:0]			raddr,
		input									clk,
		input			[DEPTH-1:0]				in,	
		input									we,
		input									rst,
		output 			[4*DEPTH-1:0]			out
	);
	
	reg [3*DEPTH-1:0] instr_wdata;
	reg [4*DEPTH-1:0] instr_waddr;
	
	/*ram2port text_mem (
		.byteena_a(4'b1111),
		.clock(clk),
		.data({in, instr_wdata}),
		.rdaddress(raddr[4*DEPTH-1:2]),
		.wraddress(instr_waddr[31:2]),
		.wren(we & (instr_waddr[1:0]==2'b11)),
		.q(out)
  	);*/
	
	always @(posedge clk) begin
			if (rst) begin
				instr_waddr <= 0;
				instr_wdata <= 0;
			end
			else begin
				if (we) begin
					instr_waddr <= instr_waddr + 1;
					instr_wdata <= {in, instr_wdata[23:8]};
				end
			end
	end
	
endmodule
