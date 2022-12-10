`timescale 1ns/1ns
module data_mem_tb();

  reg clk, MemWrite, MemRead;
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
    .out(out)
  );

  always #1 clk = ~clk;

  initial begin
    clk = 1; MemWrite = 0; MemRead = 1; in=32'h7FFFFF7F; addr = 8'b0000_0000;
    // First case: LB, addr 00, expected sign_ex (0) byteen (0001)
    MemLen = 2'b01;
    #2; 
    print_status();
    // Second case: LH, addr 00, expected sign_ex (1) byteen (0011)
    MemLen = 2'b10;
    #2;
    print_status();
    // Third case: LH, addr 10, expected sign_ex (0) byteen (1100)
    MemLen = 2'b10;
    addr = 8'b0000_0010;
    #2;
    print_status();
    // First case: LB, addr 00, expected sign_ex (1) byteen (0100)
    MemLen = 3'b101;
    #2; 
    print_status();

    $finish;
  end

  function void print_status();
    $display("Sign Extension: %h", uut.sign_ex);
    $display("Byte Enable: %b", uut.byteen);
    $display("RAM in: %h", uut.ram_in);
    $display("Out: %h", uut.out);
    $display();
  endfunction

endmodule
