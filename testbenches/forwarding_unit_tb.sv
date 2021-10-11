`timescale 1ns/1ns
`include "./hdl/forwarding_unit.v"

module forwarding_unit_tb();

  reg [2:0] ID_FwdRisk, EX_FwdRisk, MEM_FwdRisk, WB_FwdRisk;
  reg [4:0] ID_rs1, ID_rs2, EX_rd, MEM_rd, WB_rd;
  wire [1:0] FwdA, FwdB;

  forwarding_unit uut (
      .ID_FwdRisk(ID_FwdRisk),
      .EX_FwdRisk(EX_FwdRisk),
      .MEM_FwdRisk(MEM_FwdRisk),
      .WB_FwdRisk(WB_FwdRisk),
      .ID_rs1(ID_rs1),
      .ID_rs2(ID_rs2),
      .EX_rd(EX_rd),
      .MEM_rd(MEM_rd),
      .WB_rd(WB_rd),
      .FwdA(FwdA),
      .FwdB(FwdB)
  );

  initial begin

    ID_FwdRisk = 3'b001; EX_FwdRisk = 3'b001; MEM_FwdRisk = 3'b001; WB_FwdRisk = 3'b001;
    ID_rs1 = 6; ID_rs2 = 6; EX_rd = 6; MEM_rd = 6; WB_rd = 6;
    #1;
    $display("%b", FwdA);
    $display("%b", FwdB);

  end
endmodule
