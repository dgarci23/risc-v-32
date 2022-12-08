module top_ram2port(
	input [17:0] SW,
	input [1:0]  KEY,
	input 	    CLOCK_50,
	output [17:0] LEDR,
	output  [7:0] LEDG,
	input 		 UART_RXD
	);
	
	  wire [7:0] rx_data;
  wire rx_done;
  
  	rx_controller rx (
		.clk(CLOCK_50),
		.UART_RXD(UART_RXD),
		.RX_DATA(rx_data),
		.RX_DONE(rx_done)
	);
	
	reg [23:0] instr_wdata;
	
	ram2port text_mem (
	.byteena_a(4'b1111),
	.clock(CLOCK_50),
	.data({rx_data, instr_wdata}),
	.rdaddress(SW[15:0]),
	.wraddress(instr_waddr[10:2]),
	.wren(rx_done & SW[17] & (instr_waddr[1:0] == 2'b11)),
	.q(LEDR)
  );
  
  wire instr_wen;
  assign instr_wen = (rx_done)&SW[17];
  wire instr_byteen = instr_waddr[1:0];
  
  assign LEDG = instr_waddr;
  
  reg [10:0] instr_waddr;
  
  always @(posedge CLOCK_50) begin
		if (~KEY[0]) begin
			instr_waddr <= 0;
			instr_wdata <= 0;
		end
		else begin
			if (instr_wen) begin
				instr_waddr <= instr_waddr + 1;
				instr_wdata <= {rx_data, instr_wdata[23:8]};
			end
		end
  end
	
endmodule