module rx_controller 

	#(
		parameter CLKS_PER_BIT = 5208
	)
	
	(
		input						clk,
		input						UART_RXD,
		output	reg [7:0] 	RX_DATA,
		output	reg 			RX_DONE
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
					counter <= 0;
					index <= 0;
					RX_DONE <= 0;
					
					if (UART_RXD == 1'b0)
						state <= START;
					else
						state <= IDLE;
				end
			
			START:
				begin
					if (counter == CLKS_PER_BIT/2)
						begin
							if (UART_RXD == 1'b0)
								begin
									counter <= 0;
									state <= DATA;
								end
							else
								state <= IDLE;
						end
					else
						begin
							counter <= counter + 1;
							state <= START;
						end
				end
			DATA:
				begin
					if (counter < CLKS_PER_BIT - 1)
					begin
						counter <= counter + 1;
						state <= DATA;
					end
					else
					begin
						counter <= 0;
						RX_DATA[index] <= UART_RXD;
						
						if (index < 7)
						begin
							index <= index + 1;
							state <= DATA;
						end
						else
						begin
							index <= 0;
							state <= STOP;
						end
					end
				end
			STOP:
				begin
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
					RX_DONE <= 1'b1;
					state <= IDLE;
				end
			default:
				state <= IDLE;
		endcase
	end			
endmodule