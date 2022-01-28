module main

  #(parameter WIDTH = 32)

  (
        input       CLOCK_50,
        input [0:0] KEY
  );

  wire [WIDTH-1:0] instr_addr, instr, data_addr, data_w, data_r;
  wire [2:0] data_len;
  wire data_w_en, data_r_en;

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

  data_mem #(.WIDTH(256), .DEPTH(8)) data_mem (
    .clk(CLOCK_50),
    .in(data_w),
    .addr(data_addr[$clog2(256)-1:0]),
    .MemLen(data_len),
    .MemRead(data_r_en),
    .MemWrite(data_w_en),
    .out(data_r)
  );

  text_mem #(.DEPTH(8), .WIDTH(256)) text_mem (
    .addr(instr_addr),
    .out(instr)
  );

endmodule
