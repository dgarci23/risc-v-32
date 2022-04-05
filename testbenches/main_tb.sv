module main_tb ();

  reg clk, rst;

  main uut (
    .CLOCK_50(clk),
    .KEY(~rst),
    .SW(20)
  );

  always #1 clk = ~clk;

  integer i;

  initial begin
    clk = 0; rst = 1; #2; rst = 0; #1;
    for (i = 0; i < 20; i++) begin
      #2;
      $display("PC: %d", uut.processor.IF_pc);
      $display("DATA TO PROC: %d", uut.MEM_mem_out);
      //$display("Mem: %b", uut.processor.ID_MemWrite);
    end
    $finish;
  end



endmodule
