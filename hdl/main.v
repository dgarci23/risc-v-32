module main

  #(
	  parameter WIDTH 	= 32,
	  parameter DATA_SIZE 	= 256,
	  parameter DATA_DEPTH 	= 8,
	  parameter TEXT_SIZE 	= 256,
	  parameter TEXT_DEPTH 	= 8,
	  parameter IO_SIZE 	= 1,
	  parameter IO_DEPTH 	= 32
  )

  (
        input      		CLOCK_50,
        input 	[2:0] 	KEY,
		  input 	[17:0]	SW,
		  output [6:0] 	HEX0, HEX1, HEX2, HEX3,
		  output	[17:0] 	LEDR,
		  output	[7:0]	 	LEDG,
		  // UART
		  input				UART_RXD
  );

  wire [WIDTH-1:0] instr_addr, instr, data_addr, data_w, data_r;
  wire [2:0] data_len;
  wire data_w_en, data_r_en;

  wire [IO_DEPTH-1:0] io_data_out, MEM_mem_out;
  
  
  wire [2:0] KEY_DB;
  debouncer #(.SIZE(3)) debouncer (
	 .clk(CLOCK_50),
	 .in(KEY),
	 .out(KEY_DB)
  );
  
  wire clk;
  clk_divider clk_divider (
	.clk_in(CLOCK_50),
	.divider(SW[10:0]),
	.clk_out(clk)
  );

  processor #(.WIDTH(WIDTH)) processor (
    .CLK(SW[16] ? (~KEY_DB[2]) : clk),
    .RST(~KEY_DB[0]),
	.EN(~SW[17]),
    .IF_pc(instr_addr), 		// Address of current instruction fetched
    .IF_instr(instr),			// Instruction returned from memory
    .MEM_mem_in(data_w),		// Data written TO memory
    .MEM_alu_out(data_addr),	// Address of data
    .MEM_MemLen(data_len),		// Length of the data
    .MEM_MemRead(data_r_en),	// Control signal for READ of memory
    .MEM_MemWrite(data_w_en),	// Control signal for WRITE to memory
    .MEM_mem_out(MEM_mem_out)		// Data read FROM memory
  );
  
  wire [7:0] rx_data;
  wire rx_done;
  
  assign LEDR[17:10] = rx_data;
  assign LEDR[9] = rx_done;
  assign LEDR[8:0] = instr_addr;
  
	rx_controller rx (
		.clk(CLOCK_50),
		.UART_RXD(UART_RXD),
		.RX_DATA(rx_data),
		.RX_DONE(rx_done)
	);

  data_mem #(.WIDTH(DATA_SIZE), .DEPTH(DATA_DEPTH)) data_mem (
    .clk(CLOCK_50),
    .in(data_w),											// Data TO memory
    .addr(data_addr[$clog2(DATA_SIZE)-1:0]),		// Address
    .MemLen(data_len),		
    .MemRead(data_r_en),
    .MemWrite(data_w_en),
    .CE(data_addr < 256),
    .out(data_r)											// Data FROM memory
  );

  test_mem #(.WIDTH(TEXT_SIZE), .DEPTH(TEXT_DEPTH), .MODE("test")) text_mem (
    .addr(instr_addr[WIDTH-1:2]),
	.clk(CLOCK_50),
	.in(rx_data),
	.byteen(4'b1111),
	.we(rx_done&SW[17]),
    .out(instr)
  );

  /*text_mem #(.WIDTH(TEXT_SIZE), .DEPTH(TEXT_DEPTH)) text_mem (
    .raddr(instr_addr),
	 .in(rx_data),
	 .clk(CLOCK_50),
	 .rst(~KEY_DB[1]),
	 .we(rx_done&SW[17]),
    .out(instr)
  );*/
  
  /*reg [23:0] instr_wdata;
	reg [31:0] instr_waddr;
	
	ram2port text_mem (
		.byteena_a(4'b1111),
		.clock(CLOCK_50),
		.data({rx_data, instr_wdata}),
		.rdaddress(instr_addr[31:2]),
		.wraddress(instr_waddr[31:2]),
		.wren(rx_done&SW[17] & (instr_waddr[1:0]==2'b11)),
		.q(instr)
  	);
	
	always @(posedge CLOCK_50) begin
			if (~KEY_DB[1]) begin
				instr_waddr <= 0;
				instr_wdata <= 0;
			end
			else begin
				if (rx_done) begin
					instr_waddr <= instr_waddr + 1;
					instr_wdata <= {rx_data, instr_wdata[23:8]};
				end
			end
	end*/


  io #(.IO_SIZE(IO_SIZE), .IO_DEPTH(IO_DEPTH)) io (
	  .clk(CLOCK_50),
	  .io_addr(data_addr),
	  .io_data_in(data_w),
	  .io_w_en(data_w_en),
	  .seven_seg_out({HEX3, HEX2, HEX1, HEX0}),
	  .led_out({LEDG}),
	  .sw_in(SW),
	  .io_data_out(io_data_out)
  );

  mux2_1 io_mux (
	  .in1(io_data_out),
	  .in0(data_r),
	  .sel(data_addr >= 32'd32),
	  .out(MEM_mem_out)
	);

endmodule
