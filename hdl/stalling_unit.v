module stalling_unit

	(
		input					EX_MemRead,
		input		[4:0]		EX_rd,
		input		[4:0]		ID_rs1,
		input		[4:0]		ID_rs2,
		output				MemStall
	);
	
	assign MemStall = EX_MemRead & (EX_rd == ID_rs1 | EX_rd == ID_rs2);

endmodule	