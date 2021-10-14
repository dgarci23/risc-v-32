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
    #50;
    for (i = 0; i < 11; i++) begin
      $display("%d", $signed(uut.register_file.regs[6].register.q));
      $display("current pc: %d", uut.MEM_pc);
      #2;
    end
    $finish;
  end



endmodule
