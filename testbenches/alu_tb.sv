`timescale 1ns/1ns
`include "./hdl/id_stage/alu.v"
module alu_tb();

  reg [31:0] a, b;
  reg [3:0] sel;
  wire [31:0] out;

  alu uut (
      .a(a),
      .b(b),
      .ALUOp(sel),
      .out(out)
  );

  initial begin
    a = 5; b = 2; #1;
    sel = 0; #1; assert(out == (a&b));
    sel = 1; #1; assert(out == (a|b));
    sel = 2; #1; assert(out == (a+b));
    sel = 3; #1; assert(out == (a-b));
    sel = 4; #1; assert(out == (a^b));
    sel = 5; #1; assert(out == (a<<b[4:0]));
    sel = 6; #1; assert(out == (a>>b[4:0]));
    sel = 7; #1; assert(out == (a>>>b[4:0])); 
    sel = 8; #1; assert(out == ($signed(a) < $signed(b)));
    sel = 9; #1; assert(out == (a<b));
  end

endmodule
