module main_tb ();

  reg clk, rst;

  main uut (
    .CLOCK_50(clk),
    .KEY({~rst, ~rst, ~rst}),
    .SW(18'd0)
  );

  always #1 clk = ~clk;


  initial begin
    clk = 0; rst = 1; #2; rst = 0; //#40;
    $dumpfile("test.vcd");
    $dumpvars(0, uut);
    #100;
    $finish;
  end



endmodule
