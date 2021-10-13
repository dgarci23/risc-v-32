module main_tb ();

  reg clk, rst;

  main uut (
    .CLK(clk),
    .RST(rst)
  );

  always #1 clk = ~clk;

  integer i;

  initial begin
    clk = 0; rst = 1; #2; rst = 0; #1;
    for (i = 0; i < 50; i++) begin
      $display("%d", $signed(uut.register_file.regs[2].register.q));
      $display("next pc: %d", uut.pc_in);
      $display("current pc: %d", uut.IF_pc);
      $display("state: %b", uut.branch_prediction_unit.next_state);
      $display(" ");
      #2;
    end
    $finish;
  end



endmodule
