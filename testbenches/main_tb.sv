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
    #50;
    for (i = 0; i < 51; i++) begin
      $display("Reg: %h", $signed(uut.processor.register_file.regs[5].register.q));
      #2;
    end
    $finish;
  end



endmodule
