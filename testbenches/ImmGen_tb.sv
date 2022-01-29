module ImmGen_tb ();

  reg [31:0] instr;
  wire [31:0] imm;


  ImmGen uut (
      .instr(instr),
      .imm(imm)
  );

  initial begin
    instr = 32'b11111111111111111111000001101111; #3;
    $display("%b: %d %d %d %d %d", imm,$bits({10{instr[31]}}), $bits(instr[19:12]), $bits(instr[20]), $bits(instr[30:21]), $bits(1'b0));


    $finish;
  end
endmodule
