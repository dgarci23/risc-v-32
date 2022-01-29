module main_tb ();

  reg clk, rst;

  main uut (
    .CLOCK_50(clk),
    .KEY(~rst)
  );

  always #1 clk = ~clk;

  integer i;

  initial begin
    clk = 0; rst = 1; #2; rst = 0; #1;
    for (i = 0; i < 51; i++) begin
      #2;
    end
    #50;
    $display("PC: %d -- x15: %d", uut.processor.IF_pc, uut.processor.register_file.regs[15].register.q);
    $finish;
  end



endmodule
