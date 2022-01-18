module register_file (
	input						clk,
	input			[4:0]		rs1,
	input			[4:0]		rs2,
	input			[4:0]		rd,
	input						RegWrite,
	input			[31:0]	in,
	output		[31:0]	out1,
	output		[31:0]	out2
	);
	
	wire [31:0] data [31:0];
	
	genvar i;
	generate
		for (i=0; i<=31; i=i+1) begin : regs
			register register (
				.clk(clk),
				.rst(1'b0),
				.en((rd == i)&RegWrite),
				.d(in&{32{~(i == 0)}}),
				.q(data[i])
			);
		end
	endgenerate
	
	assign out1 = data[rs1];
	assign out2 = data[rs2];
	
endmodule
				