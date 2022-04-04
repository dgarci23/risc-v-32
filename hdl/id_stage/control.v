module control

	#(parameter WIDTH = 32, parameter SIGNAL_LEN = 23)

	(
		input			[WIDTH-1:0]			instr,
		output		[SIGNAL_LEN-1:0]	signals
	);
	
	wire [6:0] opcode = instr[6:0];
	wire [2:0] func3 = instr[14:12];
	wire [6:0] func7 = instr[31:25];
	
	// wire assignments for each instruction (or instruction type)
	wire BRANCH = (opcode == 7'b1100011);
	wire BEQ = BRANCH&(func3 == 0);
	wire BNE = BRANCH&(func3 == 3'b001);
	wire BLT = BRANCH&(func3 == 3'b100);
	wire BGE = BRANCH&(func3 == 3'b101);
	wire BLTU = BRANCH&(func3 == 3'b110);
	wire BGEU = BRANCH&(func3 == 3'b111);
	wire JALR = (opcode == 7'b1100111)&(func3 == 0);
	wire JAL = (opcode == 7'b1101111);
	wire LUI = (opcode == 7'b0110111);
	wire AUIPC = (opcode == 7'b0010111);
	wire ARITH_IMM = (opcode == 7'b0010011);
	wire ADDI = ARITH_IMM&(func3 == 0);
	wire SLLI = ARITH_IMM&(func3 == 3'b001);
	wire SLTI = ARITH_IMM&(func3 == 3'b010);
	wire SLTIU = ARITH_IMM&(func3 == 3'b011);
	wire XORI = ARITH_IMM&(func3 == 3'b100);
	wire SRLI = ARITH_IMM&(func3 == 3'b101)&(func7 == 7'b0000000);
	wire SRAI = ARITH_IMM&(func3 == 3'b101)&(func7 == 7'b0100000);
	wire ORI = ARITH_IMM&(func3 == 3'b110);
	wire ANDI = ARITH_IMM&(func3 == 3'b111);
	wire ARITH = (opcode == 7'b0110011);
	wire ADD = ARITH&(func3 == 0)&(func7 == 0);
	wire SUB = ARITH&(func3 == 0)&(func7 == 7'b0100000);
	wire SLL = ARITH&(func3 == 3'b001);
	wire SLT = ARITH&(func3 == 3'b010);
	wire SLTU = ARITH&(func3 == 3'b011);
	wire XOR = ARITH&(func3 == 3'b100);
	wire SRL = ARITH&(func3 == 3'b101)&(func7 == 0);
	wire SRA = ARITH&(func3 == 3'b101)&(func7 == 7'b0100000);
	wire OR = ARITH&(func3 == 3'b110);
	wire AND = ARITH&(func3 == 3'b111);
	wire LOAD = (opcode == 7'b0000011);
	wire LB = LOAD&(func3 == 0);
	wire LH = LOAD&(func3 == 3'b001);
	wire LW = LOAD&(func3 == 3'b010);
	wire LBU = LOAD&(func3 == 3'b100);
	wire LHU = LOAD&(func3 == 3'b101);
	wire STORE = (opcode == 7'b0100011);
	wire SB = STORE&(func3 == 0);
	wire SH = STORE&(func3 == 3'b001);
	wire SW = STORE&(func3 == 3'b010);
	
	wire RegWrite = JALR|JAL|LUI|AUIPC|ARITH_IMM|ARITH|LOAD;
	wire MemWrite = STORE;
	wire MemRead = LOAD;
	wire [1:0] PCSrc = BRANCH|JAL ? 2'd1 : (JALR ? 2'd2 : 2'd0);
	wire [2:0] ALUSrc = JALR|JAL ? 3'd2 : (LUI ? 3'd5 : (AUIPC ? 3'd3 : (ARITH_IMM|LOAD|STORE ? 3'd1 : (ARITH ? 3'd0 : 3'd0))));
	wire [3:0] ALUOp = (JALR|JAL|LUI|AUIPC|ADDI|ADD|LOAD|STORE) ? 4'b0010 : (SLLI|SLL ? 4'b0101 : (SLTI|SLT ? 4'b1000 : (SLTIU|SLTU ? 4'b1001 : (XORI|XOR ? 4'b0100 : (SRLI|SRL ? 4'b0110 : (SRAI|SRA ? 4'b0111 : (ORI|OR ? 4'b0001 : (ANDI|AND ? 4'b0 : (SUB ? 4'b0011 : 4'b0)))))))));
	wire [2:0] FlagSel = BEQ ? 3'd0 : (BNE ? 3'd1 : (BLT ? 3'd2 : (BGE ? 3'd4 : (BLTU ? 3'd3 : (BGEU ? 3'd5 : 3'd5)))));
	wire [2:0] MemLen = LB|SB ? 3'd0 : (LH|SH ? 3'b001 : (LW|SW ? 3'b010 : (LBU ? 3'b011 : (LHU ? 3'b100 : 3'b100))));
	wire [2:0] FwdRisk = JALR|ARITH_IMM|LOAD ? 3'b101 : (JAL|LUI|AUIPC ? 3'b001 : (ARITH ? 3'b111 : (STORE ? 3'b110 : (BRANCH ? 3'b011 : 3'b0))));
	wire Branch = BRANCH;
	wire Jump = JALR|JAL;
	
	assign signals = {RegWrite, MemWrite, MemRead, PCSrc, ALUSrc, ALUOp, FlagSel, MemLen, FwdRisk, Branch, Jump}; 
	
endmodule
