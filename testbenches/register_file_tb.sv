//`include "./hdl/register.v"
//`include "./hdl/id_stage/register_file/register_file.v"
`timescale 1ns/1ns
module register_file_tb();

  reg [4:0] rs1, rs2, rd;
  reg clk, RegWrite;
  reg [31:0] in;
  wire [31:0] out1, out2;

  register_file uut (
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .RegWrite(RegWrite),
        .in(in),
        .out1(out1),
        .out2(out2)
  );

  always #1 clk = ~clk;

  initial begin
    clk = 1; rs1 = 1; rs2 = 1; rd = 1; in = 5; RegWrite = 0; #1; // to LOW
    $display(clk); #1; // to HIGH
    $display(clk); #1; // to LOW
    RegWrite = 1; assert (out1 == 5);
    $display(clk); #1; // to HIGH
    $display(clk); #1; // to LOW

    $finish;

  end

endmodule
