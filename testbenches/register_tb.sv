`include "./hdl/register.v"
`timescale 1ns/1ns
module register_tb();

	reg clk, rst, en;
	reg [31:0] in;
	wire [31:0] out;

	register register (
		.d(in),
		.q(out),
		.en(en),
		.rst(rst),
		.clk(clk)
	);

	always #1 clk = ~clk;

	initial begin

		clk = 1; rst = 0; en = 1;

		in = 1; #0.5; assert(out == 0) else $display("Error: %d", out);
		en = 0; #2; assert(out == 0) else $display("Error: %d", out);
		en = 1; #2; assert(out == in) else $display("Error: %d", out);
		rst = 1; en = 0; #2; assert(out == 0) else $display("Error: %d", out);

		$finish;
	end



endmodule
