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
    for (i = 0; i < 200; i++) begin
      $display("%d", $signed(uut.register_file.regs[2].register.q));
      $display(uut.IF_pc);
      // $display(" ");
      #2;
    end
    $finish;
  end



endmodule
