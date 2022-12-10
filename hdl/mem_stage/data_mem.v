module data_mem

	#(parameter WIDTH = 32, parameter DEPTH = 8)

	(
		input										clk,
		input			[4*DEPTH - 1:0]		in,
		input			[$clog2(WIDTH)-1:0]	addr,
		input			[2:0]						MemLen,
		input										MemRead,
		input										MemWrite,
		input										CE,
		output 		 reg [4*DEPTH - 1:0]		out
	);

	reg [4*DEPTH-1:0] ram_in;
	wire [4*DEPTH-1:0] ram_out;
	reg [3:0] byteen;
	reg [7:0] sign_ex;


	ram2port text_mem (
		.byteena_a(byteen),
		.clock(clk),
		.data(ram_in),
		.rdaddress(addr[$clog2(WIDTH)-1:2]),
		.wraddress(addr[$clog2(WIDTH)-1:2]),
		.wren(MemWrite & CE),
		.q(ram_out)
  	);

	always @(*) begin
		out = ram_out;
		case (MemLen)
			3'b001: begin
				case (addr[1:0])
					2'b00: begin
						out = {24'd0, ram_out[7:0]};
					end
					2'b01: begin
						out = {24'd0, ram_out[15:8]};
					end
					2'b10: begin
						out = {24'd0, ram_out[23:16]};
					end
					2'b01: begin
						out = {24'd0, ram_out[31:24]};
					end
				endcase
			end	
			3'b010: begin
				out = {16'd0, ram_out[15:0]};
				if (addr[1]) begin
					out = {16'd0, ram_out[31:16]};
				end
			end
			3'b101: begin
				case (addr[1:0])
					2'b00: begin
						out = {{3{sign_ex}}, ram_out[7:0]};
					end
					2'b01: begin
						out = {{3{sign_ex}}, ram_out[15:8]};
					end
					2'b10: begin
						out = {{3{sign_ex}}, ram_out[23:16]};
					end
					2'b01: begin
						out = {{3{sign_ex}}, ram_out[31:24]};
					end
				endcase
			end
			3'b010: begin
				out = {{2{sign_ex}}, ram_out[15:0]};
				if (addr[1]) begin
					out = {{2{sign_ex}}, ram_out[31:16]};
				end
			end
			default: begin
				out = ram_out;
			end
		endcase
	end

	always @(*) begin
		ram_in = in;
		byteen = 4'b1111;
 		case (MemLen[1:0]) 
			2'b01: begin
				byteen = 4'b0001;
				if (addr[1:0]==2'b01) begin
					ram_in[15:8] = in[7:0];
					byteen = 4'b0010;
				end
				if (addr[1:0]==2'b10) begin
					ram_in[23:16] = in[7:0];
					byteen = 4'b0100;
				end
				if (addr[1:0]==2'b11) begin
					ram_in[31:24] = in[7:0];
					byteen = 4'b1000;
				end
			end
			2'b10: begin
				byteen = 4'b0011;
				if (addr[1]) begin
					ram_in[31:16] = in[15:0];
					byteen = 4'b1100;
				end
			end
			default: ram_in = in;
		endcase
	end

	always @(*) begin
		case (MemLen[1:0])
			2'b01: begin
				case (addr[1:0])
					2'b00: sign_ex = {8{ram_out[7]}};
					2'b01: sign_ex = {8{ram_out[15]}};
					2'b10: sign_ex = {8{ram_out[23]}};
					2'b11: sign_ex = {8{ram_out[31]}};
				endcase
			end	
			2'b10: begin
				if (addr[1]) begin
					sign_ex = {8{ram_out[31]}};
				end
				else begin
					sign_ex = {8{ram_out[15]}};
				end
			end
			default: sign_ex = 0;
		endcase
	end


endmodule
