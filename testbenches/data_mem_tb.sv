`timescale 1ns/1ns
module data_mem_tb();

  reg clk, MemWrite, MemRead, CE;
  reg [31:0] in;
  reg [7:0] addr;
  wire [31:0] out;
  reg [2:0] MemLen;

  data_mem uut (
    .in(in),
    .clk(clk),
    .addr(addr),
    .MemLen(MemLen),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .CE(CE),
    .out(out)
  );

  always #1 clk = ~clk;

  initial begin
    $dumpfile("data_mem.vcd");
    $dumpvars(0, uut);
    clk = 1; MemWrite = 1; MemRead = 1; CE = 1; in=32'h7FFFFF7F; addr = 8'b0000_0000; #1;
    // First case: LB, addr 00, expected sign_ex (0) byteen (0001)
    MemLen = 2'b01;
    #2; 
    assert_status(0, 4'b0001, 32'h7FFFFF7F, 32'h0000007F);
    // Second case: LH, addr 00, expected sign_ex (1) byteen (0011)
    MemLen = 2'b10;
    #2;
    assert_status(8'hff, 4'b0011, 32'h7fffff7f, 32'h0000ff7f);
    // Third case: LH, addr 10, expected sign_ex (0) byteen (1100)
    MemLen = 2'b10;
    addr = 8'b0000_0010;
    #2;
    assert_status(8'hff, 4'b1100, 32'hff7fff7f, 32'h0000ff7f);
    // First case: LB, addr 00, expected sign_ex (1) byteen (0100)
    MemLen = 3'b101;
    #2; 
    assert_status(8'h00, 4'b0100, 32'h7f7fff7f, 32'h0000007f);
    $finish;
  end

  function void assert_status(int e_sign_ex, e_byteen, e_ram_in, e_out);
    assert (uut.sign_ex == e_sign_ex & uut.byteen == e_byteen & uut.ram_in == e_ram_in && uut.out == e_out) 
    else   
      print_status();
  endfunction

  function void print_status();
    $display("Sign Extension: %h", uut.sign_ex);
    $display("Byte Enable: %b", uut.byteen);
    $display("RAM in: %h", uut.ram_in);
    $display("Out: %h", uut.out);
    $display();
  endfunction

endmodule
