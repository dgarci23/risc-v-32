module forwarding_unit
	
	#(parameter WIDTH = 32)
	
	(
		// Control Signals that signal if instruction could require forwarding
		input 			[2:0]			ID_FwdRisk,
		input 			[2:0]			EX_FwdRisk,
		input 			[2:0]			MEM_FwdRisk,
		input 			[2:0]			WB_FwdRisk,
		// Source Register
		input				[4:0]			ID_rs1,
		input				[4:0]			ID_rs2,
		// Destination Register
		input				[4:0]			EX_rd,
		input				[4:0]			MEM_rd,
		input				[4:0]			WB_rd,
		// Output Forward Control Signals
		output			[1:0]			FwdA,
		output			[1:0]			FwdB
	);
	
	wire EX_FwdA = EX_FwdRisk[2]&ID_FwdRisk[0]&(EX_rd != 0)&(ID_rs1 == EX_rd);
	wire EX_FwdB = EX_FwdRisk[2]&ID_FwdRisk[1]&(EX_rd != 0)&(ID_rs2 == EX_rd);
	
	wire MEM_FwdA = MEM_FwdRisk[2]&ID_FwdRisk[0]&(MEM_rd != 0)&(ID_rs1 == MEM_rd)&~(EX_FwdA);
	wire MEM_FwdB = MEM_FwdRisk[2]&ID_FwdRisk[1]&(MEM_rd != 0)&(ID_rs2 == MEM_rd)&~(EX_FwdB);
	
	wire WB_FwdA = WB_FwdRisk[2]&ID_FwdRisk[0]&(WB_rd != 0)&(ID_rs1 == WB_rd)&~(EX_FwdA)&~(MEM_FwdA);
	wire WB_FwdB = WB_FwdRisk[2]&ID_FwdRisk[1]&(WB_rd != 0)&(ID_rs2 == WB_rd)&~(EX_FwdB)&~(MEM_FwdB);
	
	assign FwdA = WB_FwdA ? 2'd3 : (MEM_FwdA ? 2'd2 : (EX_FwdA ? 2'd1 : 2'd0));
	assign FwdB = WB_FwdB ? 2'd3 : (MEM_FwdB ? 2'd2 : (EX_FwdB ? 2'd1 : 2'd0));
	
endmodule
	