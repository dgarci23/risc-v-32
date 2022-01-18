`timescale 1ns/1ns
`include "./hdl/mem_stage/data_mem.v"
module data_mem_tb();

  reg clk, MemWrite, MemRead;
  reg [31:0] in;
  reg [7:0] addr;
  wire [31:0] out;
  reg [2:0] MemLen;

  data_mem uut (
    .in(in),
    .clk(clk),
    .addr(addr),
    .MemLen(MemLen),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .out(out)
  );

  always #1 clk = ~clk;

  initial begin
    clk = 1; MemWrite = 0; MemRead = 1; MemLen = 0;
    #1; addr = 152;
    #2; $display("%h", out);
    #2; MemWrite = 1; in = 1;
    #6; $display("%h", out);

    $finish;
  end
endmodule
