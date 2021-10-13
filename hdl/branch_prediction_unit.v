module branch_prediction_unit

	(
		input clk,
		input rst,
		input	correction,
		input en,
		output reg prediction
	);
	
	
	parameter SNT = 2'b00;
	parameter NT = 2'b01;
	parameter BT = 2'b10;
	parameter SBT = 2'b11;
	
	reg [1:0] state, next_state;
	
	always @(posedge clk)
		if (rst)
			state <= 0;
		else
			state <= next_state;
			
	always @(*) begin
		case (state)
			SNT: begin
				if (en)
					if (correction)
						next_state = NT;
					else
						next_state = SNT;
				prediction = 0;
			end
			NT: begin
				if (en)
					if (correction)
						next_state = BT;
					else
						next_state = SNT;
				prediction = 0;
			end
			BT: begin
				if (en)
					if (correction)
						next_state = SBT;
					else
						next_state = NT;
				prediction = 1'b1;
			end
			SBT: begin
				if (en)
					if (correction)
						next_state = SBT;
					else
						next_state = BT;
				prediction = 1'b1;
			end
			default: begin
				next_state = SNT;
			end
		endcase
	end
	
endmodule
		
		