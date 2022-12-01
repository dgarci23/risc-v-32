module tx_controller 

	#(
		parameter CLKS_PER_BIT = 5208
	)
	
	(
		input		[7:0]		TX_DATA,
		input					TX_SEND,
		input					clk,
		output	reg		UART_TXD,
		output	reg		TX_DONE,
		output	reg		TX_BUSY
	);
	
	parameter IDLE         = 3'b000;
	parameter START = 3'b001;
	parameter DATA = 3'b010;
	parameter STOP 		 = 3'b011;
	parameter CLEANUP      = 3'b100;
	
	
	reg [2:0] state = 0;
	reg [15:0] counter = 0;
	reg [2:0]  index = 0;
	

	
	always @(posedge clk)
	begin
		case (state)
			IDLE:
				begin
					TX_DONE <= 1'b0;
					counter <= 0;
					index <= 0;
					TX_BUSY <= 0;
					if (TX_SEND == 1'b0)
					begin
						UART_TXD <= 1'b1;
						state <= IDLE;
					end
					else
					begin
						UART_TXD <= 1'b0;
						state <= START;
						TX_BUSY <= 1'b1;
					end
				end
			START:
				begin
					if (counter < CLKS_PER_BIT - 1)
						begin
							counter <= counter + 1;
							UART_TXD <= 1'b0;
							state <= START;
						end
					else
						begin
							counter <= 0;
							state <= DATA;
							index <= 0;
						end
				end
			DATA:
				begin
					UART_TXD <= TX_DATA[index];
					if (counter < CLKS_PER_BIT - 1)
					begin
						counter <= counter + 1;
						state <= DATA;
					end
					else
					begin
						if (index < 7)
						begin
							counter <= 0;
							state <= DATA;
							index <= index + 1;
						end
						else
						begin
							counter <= 0;
							state <= STOP;
							index <= 0;
						end
					end
				end
			STOP:
				begin
					UART_TXD <= 1'b1;
					if (counter < CLKS_PER_BIT - 1)
					begin
						counter <= counter + 1;
						state <= STOP;
					end
					else
					begin
						counter <= 0;
						state <= CLEANUP;
					end
				end
			CLEANUP:
				begin
					TX_DONE <= 1'b1;
					state <= IDLE;
				end
			default:
				begin
					state <= IDLE;
				end

					
		endcase
	end	
endmodule