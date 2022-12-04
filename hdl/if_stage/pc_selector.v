module pc_selector 

	#(parameter WIDTH=32)

	(
		// Control Signals
		input 							ID_Jump,
		input 							ID_Branch,
		input 							IF_Branch,
		input				[1:0]			PCSrc,
		// Control Signals - Dynamic Prediction
		input								ID_prediction,
		input 							ID_correction,
		input 							IF_prediction,
		// Values
		input 			[WIDTH-1:0] ID_pc,
		input 			[WIDTH-1:0]	ID_imm,
		input 			[WIDTH-1:0]	IF_pc,
		input 			[WIDTH-1:0] IF_imm,
		input 			[WIDTH-1:0] imm_pc,
		input 			[WIDTH-1:0] indirect_pc,
		output reg 		[WIDTH-1:0] pc_in
	);
	
	always @(*) begin
		if (ID_Jump) begin
			if (PCSrc == 2'b10)
				pc_in = indirect_pc;
			else
				pc_in = imm_pc;
		end
		else begin
			if (ID_Branch & (ID_prediction^ID_correction)) begin
					if (ID_correction)
						pc_in = ID_pc + ID_imm;
					else
						pc_in = ID_pc + 32'd4;
			end
			else
				if (IF_Branch)
					if (IF_prediction)
						pc_in = IF_pc + IF_imm;
					else
						pc_in = IF_pc + 32'd4;
				else
					pc_in = IF_pc + 32'd4;
		end
	end
	
endmodule
	
	