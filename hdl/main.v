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
	output [6:0] HEX0
  );

  wire [WIDTH-1:0] instr_addr, instr, data_addr, data_w, data_r;
  wire [2:0] data_len;
  wire data_w_en, data_r_en;

  wire [IO_DEPTH-1:0] io_data_out;

  processor #(.WIDTH(WIDTH)) processor (
    .CLK(CLOCK_50),
    .RST(~KEY[0]),
    .IF_pc(instr_addr),
    .IF_instr(instr),
    .MEM_mem_in(data_w),
    .MEM_alu_out(data_addr),
    .MEM_MemLen(data_len),
    .MEM_MemRead(data_r_en),
    .MEM_MemWrite(data_w_en),
    .MEM_mem_out(data_r)
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
	  .io_addr(1'b0),
	  .io_data_in(data_w),
	  .io_w_en(data_w_en&&(data_addr >= 256)),
	  .io_data_out(io_data_out)
  );

  seven_segment seven_segment (
	  .in(io_data_out[3:0]),
	  .out(HEX0)
  );

endmodule
