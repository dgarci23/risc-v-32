module io

#(
	parameter IO_SIZE = 2,
	parameter IO_DEPTH = 32
)

(
	input	clk,
	output	[IO_DEPTH-1:0]	seven_seg_out,
	output	[IO_DEPTH-1:0] led_out,
	input	[31:0] io_addr,
	input	[IO_DEPTH-1:0] io_data_in,
	input	io_w_en
);

reg [IO_DEPTH-1:0] seven_seg;
reg [IO_DEPTH-1:0] led;

always @(posedge clk)
begin
	// Seven Segment Display
	if (io_w_en && io_addr == 32)
		seven_seg <= io_data_in;
	// LEDs
	if (io_w_en && io_addr == 36)
		led <= io_data_in;
end

seven_segment seven_segment_0 (
	.in(seven_seg[3:0]),
	.out(seven_seg_out[6:0])
);

seven_segment seven_segment_1 (
	.in(seven_seg[7:4]),
	.out(seven_seg_out[13:7])
);

seven_segment seven_segment_2 (
	.in(seven_seg[11:8]),
	.out(seven_seg_out[20:14])
);

seven_segment seven_segment_3 (
	.in(seven_seg[15:12]),
	.out(seven_seg_out[27:21])
);


assign led_out = led;

endmodule
