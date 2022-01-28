module processor

	#(parameter WIDTH = 32)

	(
		input CLK,
		input RST,
		// Instruction
		output [WIDTH-1:0] IF_pc,
		input  [WIDTH-1:0] IF_instr,
		// Data
		output [WIDTH-1:0] MEM_mem_in,
		output [WIDTH-1:0] MEM_alu_out,
		output  [2:0] 		 MEM_MemLen,
		output 						 MEM_MemRead,
		output 						 MEM_MemWrite,
		input  [WIDTH-1:0] MEM_mem_out
	);


	// Reset control
	// wire RST;

	// Control signals - from unit
	wire [22:0] ID_preflush;
	wire ID_RegWrite, EX_RegWrite, MEM_RegWrite, WB_RegWrite;
	wire ID_MemWrite, EX_MemWrite, WB_MemWrite;
	wire ID_MemRead, EX_MemRead, WB_MemRead;
	wire [1:0] ID_PCSrc, EX_PCSrc, MEM_PCSrc, WB_PCSrc;
	wire [2:0] ID_ALUSrc, EX_ALUSrc, MEM_ALUSrc, WB_ALUSrc;
	wire [3:0] ID_ALUOp, EX_ALUOp, MEM_ALUOp, WB_ALUOp;
	wire [2:0] ID_FlagSel, EX_FlagSel, MEM_FlagSel, WB_FlagSel;
	wire [2:0] ID_MemLen, EX_MemLen, WB_MemLen;
	wire [2:0] ID_FwdRisk, EX_FwdRisk, MEM_FwdRisk, WB_FwdRisk;
	wire ID_Branch, EX_Branch, MEM_Branch, WB_Branch;
	wire ID_Jump, EX_Jump, MEM_Jump, WB_Jump;
	wire [22:0] ID_signals, EX_signals, MEM_signals, WB_signals;
	assign {ID_RegWrite, ID_MemWrite, ID_MemRead, ID_PCSrc, ID_ALUSrc, ID_ALUOp, ID_FlagSel, ID_MemLen, ID_FwdRisk, ID_Branch, ID_Jump} = ID_signals;
	assign {EX_RegWrite, EX_MemWrite, EX_MemRead, EX_PCSrc, EX_ALUSrc, EX_ALUOp, EX_FlagSel, EX_MemLen, EX_FwdRisk, EX_Branch, EX_Jump} = EX_signals;
	assign {MEM_RegWrite, MEM_MemWrite, MEM_MemRead, MEM_PCSrc, MEM_ALUSrc, MEM_ALUOp, MEM_FlagSel, MEM_MemLen, MEM_FwdRisk, MEM_Branch, MEM_Jump} = MEM_signals;
	assign {WB_RegWrite, WB_MemWrite, WB_MemRead, WB_PCSrc, WB_ALUSrc, WB_ALUOp, WB_FlagSel, WB_MemLen, WB_FwdRisk, WB_Branch, WB_Jump} = WB_signals;



	// Control signals - outside from unit
	wire ID_Flush, ID_CompFlag, MemStall;
	wire [1:0] FwdA, FwdB;
	wire [2:0] FlagSel;

	// PC Signals
	wire [WIDTH-1:0] ID_pc, EX_pc, MEM_pc;

	// IF Stage
	wire [WIDTH-1:0] pc_in, sequential_pc, imm_pc, indirect_pc, ID_instr;

	// Immediate
	wire [WIDTH-1:0] ID_imm, EX_imm;

	// MEM values
	wire [WIDTH-1:0] MEM_wb_out;

	// WB values
	wire [WIDTH-1:0] WB_wb_out;

	// Register File Values
	wire [WIDTH-1:0] ID_reg_out1, ID_reg_out2;
	wire [4:0] ID_rs1, ID_rs2, ID_rd, EX_rd, MEM_rd, WB_rd;
	assign ID_rs1 = ID_instr[19:15];
	assign ID_rs2 = ID_instr[24:20];
	assign ID_rd = ID_instr[11:7];

	// ALU values
	wire [WIDTH-1:0] ID_alu_in1, ID_alu_in2, EX_alu_out, EX_alu_in1, EX_alu_in2, alu_in1, alu_in2;


	// --------------------------------------- IF Stage ------------------------------------------------

	register PC (
		.rst(RST),
		.en(~(MemStall)), // Updates except when there is a Memory Stall
		.clk(CLK),
		.d(pc_in),
		.q(IF_pc)
	);

	adder #(.WIDTH(WIDTH)) sequential_adder (
		.a(IF_pc),
		.b(32'd4),
		.out(sequential_pc)
	);



	// Dynamic Branch Prediction

	wire IF_Branch = (IF_instr[6:0] == 7'b1100011);
	wire [31:0] IF_imm = {{20{IF_instr[31]}}, IF_instr[7], IF_instr[30:25], IF_instr[11:8], 1'b0};

	wire IF_prediction, ID_prediction;

	wire ID_correction = ID_Branch&ID_CompFlag;

	branch_prediction_unit branch_prediction_unit (
		.clk(~CLK),
		.rst(RST),
		.en(ID_Branch),
		.correction(ID_correction),
		.prediction(IF_prediction)
	);

	pc_selector #(.WIDTH(32)) pc_selector (
		.ID_Jump(ID_Jump),
		.ID_Branch(ID_Branch),
		.IF_Branch(IF_Branch),
		.PCSrc(ID_PCSrc),
		.ID_prediction(ID_prediction),
		.ID_correction(ID_correction),
		.IF_prediction(IF_prediction),
		.ID_pc(ID_pc),
		.ID_imm(ID_imm),
		.IF_pc(IF_pc),
		.IF_imm(IF_imm),
		.imm_pc(imm_pc),
		.indirect_pc(indirect_pc),
		.pc_in(pc_in)
	);



	// IF/ID Register
	register #(.BUS_WIDTH(2*32+1)) IF_ID_register (
		.rst(((ID_correction!=ID_prediction)&ID_Branch)|RST|ID_Jump), // Resets when there is a Branching, and the instructions in the IF/ID register must be thrown out
		.en(~(MemStall)), // Since PC is one instruction ahead of the stalled one, we also need to freeze this reg
		.clk(CLK),
		.d({IF_instr, IF_pc, IF_prediction}),
		.q({ID_instr, ID_pc, ID_prediction})
	);

	// -------------------------------------------- ID Stage -------------------------------------------------

	register_file register_file (
		.clk(CLK),
		.rs1(ID_rs1),
		.rs2(ID_rs2),
		.rd(WB_rd),
		.RegWrite(WB_RegWrite),
		.in(WB_wb_out),
		.out1(ID_reg_out1),
		.out2(ID_reg_out2)
	);

	ImmGen ImmGen (
		.instr(ID_instr),
		.imm(ID_imm)
	);

	mux4_1 FwdA_mux (
		.in0(ID_reg_out1),
		.in1(EX_alu_out),
		.in2(MEM_wb_out),
		.in3(WB_wb_out),
		.sel(FwdA),
		.out(ID_alu_in1)
	);

	mux4_1 FwdB_mux (
		.in0(ID_reg_out2),
		.in1(EX_alu_out),
		.in2(MEM_wb_out),
		.in3(WB_wb_out),
		.sel(FwdB),
		.out(ID_alu_in2)
	);

	adder #(.WIDTH(WIDTH)) immediate_pc_adder (
		.a(ID_pc),
		.b(ID_imm),
		.out(imm_pc)
	);

	adder #(.WIDTH(WIDTH)) indirect_pc_adder (
		.a(ID_imm),
		.b(ID_alu_in1),
		.out(indirect_pc)
	);

	comparison_unit #(.WIDTH(WIDTH)) comparison_unit (
		.a(ID_alu_in1),
		.b(ID_alu_in2),
		.sel(ID_FlagSel),
		.flag(ID_CompFlag)
	);

	control #(.WIDTH(WIDTH), .SIGNAL_LEN(23)) control_unit (
		.instr(ID_instr),
		.signals(ID_preflush)
	);

	flush_unit #(.WIDTH(23)) ID_flush_unit (
		.in(ID_preflush),
		.sel(ID_Flush),
		.out(ID_signals)
	);

	// ID-EX Register
	register #(.BUS_WIDTH(4*32+23+5)) ID_EX_register (
		.rst(RST),
		.en(1'b1), // THIS MIGHT CHANGE
		.clk(CLK),
		.d({ID_pc, ID_imm, ID_alu_in1, ID_alu_in2, ID_rd, ID_signals}),
		.q({EX_pc, EX_imm, EX_alu_in1, EX_alu_in2, EX_rd, EX_signals})
	);

	// --------------------------------------- EX Stage -----------------------------------------------------------


	// First Input for the ALU
	mux4_1 #(.DEPTH(WIDTH)) alu_muxA (
		.in0(EX_alu_in1),
		.in1(EX_pc),
		.in2(32'b0),
		.in3(32'b0),
		.sel(EX_ALUSrc[2:1]),
		.out(alu_in1)
	);

	// Second Input for the ALU
	mux4_1 #(.DEPTH(WIDTH)) alu_muxB (
		.in0(EX_alu_in2),
		.in1(EX_imm),
		.in2(32'd4),
		.in3(EX_imm),
		.sel(EX_ALUSrc[1:0]),
		.out(alu_in2)
	);

	// ALU
	alu #(.WIDTH(WIDTH)) alu (
		.a(alu_in1),
		.b(alu_in2),
		.ALUOp(EX_ALUOp),
		.out(EX_alu_out)
	);

	// EX-MEM Register
	register #(.BUS_WIDTH(3*32+23+5)) EX_MEM_register (
		.rst(RST),
		.en(1'b1), // THIS MIGHT CHANGE
		.clk(CLK),
		.d({EX_pc, EX_alu_out, EX_alu_in2, EX_rd, EX_signals}),
		.q({MEM_pc, MEM_alu_out, MEM_mem_in, MEM_rd, MEM_signals})
	);

	// --------------------------------------------- MEM Stage ------------------------------------------------

	// Select between Register Operation or Memory
	mux2_1 #(.DEPTH(WIDTH)) mem_mux (
		.in0(MEM_alu_out),
		.in1(MEM_mem_out),
		.sel(MEM_MemRead),
		.out(MEM_wb_out)
	);

	// MEM-WB Register
	register #(.BUS_WIDTH(32+23+5)) MEM_WB_register (
		.rst(RST),
		.en(1'b1),
		.clk(CLK),
		.d({MEM_wb_out, MEM_signals, MEM_rd}),
		.q({WB_wb_out, WB_signals, WB_rd})
	);

	// ----------------------------------------------- WB Stage --------------------------------------------------


	// -------------------------------------------------- Hazards --------------------------------------------

	forwarding_unit #(.WIDTH(WIDTH)) forwarding_unit (
		.ID_FwdRisk(ID_FwdRisk),
		.EX_FwdRisk(EX_FwdRisk),
		.MEM_FwdRisk(MEM_FwdRisk),
		.WB_FwdRisk(WB_FwdRisk),
		.ID_rs1(ID_rs1),
		.ID_rs2(ID_rs2),
		.EX_rd(EX_rd),
		.MEM_rd(MEM_rd),
		.WB_rd(WB_rd),
		.FwdA(FwdA),
		.FwdB(FwdB)
	);

	stalling_unit stalling_unit (
		.EX_MemRead(EX_MemRead),
		.EX_rd(EX_rd),
		.ID_rs1(ID_rs1),
		.ID_rs2(ID_rs2),
		.MemStall(MemStall)
	);

	assign ID_Flush = MemStall;


endmodule
