`timescale 1ns/1ns
`include "./hdl/id_stage/comparison_unit.v"

module comparison_unit_tb ();

  reg [31:0] a, b;
  wire flag;
  reg [2:0] sel;

  comparison_unit uut (
      .a(a),
      .b(b),
      .sel(sel),
      .flag(flag)
  );

  initial begin
    a = 32'h1000_0001; b = 32'h0000_0001; sel = 0; #1;
    assert(flag == (a == b));
    sel = 1; #1;
    assert(flag == (a!=b));
    sel = 2; #1;
    assert(flag == (a < b));
    sel = 3; #1;
    assert(flag == ($signed(a) < $signed(b)));
    sel = 4; #1;
    assert(flag == (a > b));
    sel = 5; #1;
    assert(flag == ($signed(a) > $signed(b)));
  end

endmodule
