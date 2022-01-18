module ImmGen_tb ();

  reg [31:0] instr;
  wire [31:0] imm;


  ImmGen uut (
      .instr(instr),
      .imm(imm)
  );

  initial begin
    instr = 32'b0000_0000_0000_0000_0000_0000_0001_0011; #1;

    $finish;
  end
endmodule
