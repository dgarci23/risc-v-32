module io

#(
	parameter IO_SIZE = 1,
	parameter IO_DEPTH = 32
)

(
	input	clk,
	input	[0:0] io_addr,
	input	[IO_DEPTH-1:0] io_data_in,
	input	io_w_en,
	output	[IO_DEPTH-1:0] io_data_out
);

reg [IO_DEPTH-1:0] io_data;

always @(posedge clk)
	if (io_w_en)
		io_data <= io_data_in;

assign io_data_out = io_data;

endmodule
