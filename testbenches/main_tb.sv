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
    for (i = 0; i < 20; i++) begin
      #2;
      $display("PC: %d", uut.processor.IF_pc);
      $display("IO: seven_seg: %d - data: %d - io_addr: %d", uut.io.seven_seg, uut.io.io_data_in, uut.io.io_addr);
      //$display("Mem: %b", uut.processor.ID_MemWrite);
    end
    $finish;
  end



endmodule
