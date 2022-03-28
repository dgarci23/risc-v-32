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
    for (i = 0; i < 6; i++) begin
      #2;
      $display("PC: %d", uut.processor.IF_pc);
      $display("IO: en: %d - data: %d", uut.io.io_w_en, uut.data_w);
      $display("Mem: %b", uut.processor.ID_MemWrite);
    end
    $finish;
  end



endmodule
