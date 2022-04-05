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

  wire [IO_DEPTH-1:0] io_data_out, MEM_mem_out;

  processor #(.WIDTH(WIDTH)) processor (
    .CLK(CLOCK_50),
    .RST(~KEY[0]),
    .IF_pc(instr_addr), 		// Address of current instruction fetched
    .IF_instr(instr),			// Instruction returned from memory
    .MEM_mem_in(data_w),		// Data written TO memory
    .MEM_alu_out(data_addr),	// Address of data
    .MEM_MemLen(data_len),		// Length of the data
    .MEM_MemRead(data_r_en),	// Control signal for READ of memory
    .MEM_MemWrite(data_w_en),	// Control signal for WRITE to memory
    .MEM_mem_out(MEM_mem_out)		// Data read FROM memory
  );
  

  data_mem #(.WIDTH(DATA_SIZE), .DEPTH(DATA_DEPTH)) data_mem (
    .clk(CLOCK_50),
    .in(data_w),											// Data TO memory
    .addr(data_addr[$clog2(DATA_SIZE)-1:0]),		// Address
    .MemLen(data_len),		
    .MemRead(data_r_en),
    .MemWrite(data_w_en),
    .CE(data_addr < 256),
    .out(data_r)											// Data FROM memory
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
	  .in1(io_data_out),
	  .in0(data_r),
	  .sel(data_addr >= 32'd32),
	  .out(MEM_mem_out)
	);

endmodule
