module main

  #(
	  parameter WIDTH 	= 32,
	  parameter DATA_SIZE 	= 256,
	  parameter DATA_DEPTH 	= 8,
	  parameter TEXT_SIZE 	= 256,
	  parameter TEXT_DEPTH 	= 8,
	  parameter IO_SIZE 	= 1,
	  parameter IO_DEPTH 	= 32
  )

  (
        input       CLOCK_50,
        input [0:0] KEY,
	input [17:0]	SW,
		  output [6:0] HEX0, HEX1, HEX2, HEX3,
		  output	[17:0] LEDR,
		  output	[7:0]	 LEDG
  );

  wire [WIDTH-1:0] instr_addr, instr, data_addr, data_w, data_r;
  wire [2:0] data_len;
  wire data_w_en, data_r_en;

  wire [IO_DEPTH-1:0] io_data_out, MEM_mem_in;

  processor #(.WIDTH(WIDTH)) processor (
    .CLK(CLOCK_50),
    .RST(~KEY[0]),
    .IF_pc(instr_addr),
    .IF_instr(instr),
    .MEM_mem_in(MEM_mem_in),
    .MEM_alu_out(data_addr),
    .MEM_MemLen(data_len),
    .MEM_MemRead(data_r_en),
    .MEM_MemWrite(data_w_en),
    .MEM_mem_out(data_w)
  );

  data_mem #(.WIDTH(DATA_SIZE), .DEPTH(DATA_DEPTH)) data_mem (
    .clk(CLOCK_50),
    .in(data_w),
    .addr(data_addr[$clog2(DATA_SIZE)-1:0]),
    .MemLen(data_len),
    .MemRead(data_r_en),
    .MemWrite(data_w_en),
    .CE(data_addr < 256),
    .out(data_r)
  );

  text_mem #(.WIDTH(TEXT_SIZE), .DEPTH(TEXT_DEPTH)) text_mem (
    .addr(instr_addr),
    .out(instr)
  );

  io #(.IO_SIZE(IO_SIZE), .IO_DEPTH(IO_DEPTH)) io (
	  .clk(CLOCK_50),
	  .io_addr(data_addr),
	  .io_data_in(data_w),
	  .io_w_en(data_w_en),
	  .seven_seg_out({HEX3, HEX2, HEX1, HEX0}),
	  .led_out({LEDR, LEDG}),
	  .sw_in(SW),
	  .io_data_out(io_data_out)
  );

  mux2_1 io_mux (
	  .in0(io_data_out),
	  .in1(data_r),
	  .sel(data_addr == 32'd256),
	  .out(MEM_mem_in)
 );

endmodule
