module data_mem

	#(parameter WIDTH = 256, parameter DEPTH = 8)

	(
		input										clk,
		input			[4*DEPTH - 1:0]		in,
		input			[$clog2(WIDTH)-1:0]	addr,
		input			[2:0]						MemLen,
		input										MemRead,
		input										MemWrite,
		input										CE,
		output reg	[4*DEPTH - 1:0]		out
	);

	reg [DEPTH-1:0] data0 [WIDTH-1:0];
	reg [DEPTH-1:0] data1 [WIDTH-1:0];
	reg [DEPTH-1:0] data2 [WIDTH-1:0];
	reg [DEPTH-1:0] data3 [WIDTH-1:0];

	integer i;
	initial begin for (i = 0; i < WIDTH; i = i + 1) begin
		data0[i] = i[7:0]*4;
		data1[i] = i[7:0]*4+1;
		data2[i] = i[7:0]*4+2;
		data3[i] = i[7:0]*4+3;
		end
	end

	always @(posedge clk)
		if (MemRead&&CE)
			case (MemLen)
				0: begin
					case (addr[1:0])
						0: out = {{24{data0[addr[$clog2(WIDTH)-1:2]][DEPTH-1]}}, data0[addr[$clog2(WIDTH)-1:2]]};
						1: out = {{24{data1[addr[$clog2(WIDTH)-1:2]][DEPTH-1]}}, data1[addr[$clog2(WIDTH)-1:2]]};
						2: out = {{24{data2[addr[$clog2(WIDTH)-1:2]][DEPTH-1]}}, data2[addr[$clog2(WIDTH)-1:2]]};
						3: out = {{24{data3[addr[$clog2(WIDTH)-1:2]][DEPTH-1]}}, data3[addr[$clog2(WIDTH)-1:2]]};
						default: out = 0;
					endcase
				end
				1: begin
					case (addr[1:0])
						0: out = {{16{data1[addr[$clog2(WIDTH)-1:2]][DEPTH-1]}}, data1[addr[$clog2(WIDTH)-1:2]], data0[addr[$clog2(WIDTH)-1:2]]};
						1: out = {{16{data2[addr[$clog2(WIDTH)-1:2]][DEPTH-1]}}, data2[addr[$clog2(WIDTH)-1:2]], data1[addr[$clog2(WIDTH)-1:2]]};
						2: out = {{16{data3[addr[$clog2(WIDTH)-1:2]][DEPTH-1]}}, data3[addr[$clog2(WIDTH)-1:2]], data2[addr[$clog2(WIDTH)-1:2]]};
						3: out = {{16{data0[addr[$clog2(WIDTH)-1:2]+1][DEPTH-1]}}, data0[addr[$clog2(WIDTH)-1:2]+1], data3[addr[$clog2(WIDTH)-1:2]]};
						default: out = 0;
					endcase
				end
				3: begin
					case (addr[1:0])
						0: out = {24'b0, data0[addr[$clog2(WIDTH)-1:2]]};
						1: out = {24'b0, data1[addr[$clog2(WIDTH)-1:2]]};
						2: out = {24'b0, data2[addr[$clog2(WIDTH)-1:2]]};
						3: out = {24'b0, data3[addr[$clog2(WIDTH)-1:2]]};
						default: out = 0;
					endcase
				end
				4: begin
					case (addr[1:0])
						0: out = {16'b0, data1[addr[$clog2(WIDTH)-1:2]], data0[addr[$clog2(WIDTH)-1:2]]};
						1: out = {16'b0, data2[addr[$clog2(WIDTH)-1:2]], data1[addr[$clog2(WIDTH)-1:2]]};
						2: out = {16'b0, data3[addr[$clog2(WIDTH)-1:2]], data2[addr[$clog2(WIDTH)-1:2]]};
						3: out = {16'b0, data0[addr[$clog2(WIDTH)-1:2]+1], data3[addr[$clog2(WIDTH)-1:2]]};
						default: out = 0;
					endcase
				end
				2: begin
					case (addr[1:0])
						0: out = {data3[addr[$clog2(WIDTH)-1:2]], data2[addr[$clog2(WIDTH)-1:2]], data1[addr[$clog2(WIDTH)-1:2]], data0[addr[$clog2(WIDTH)-1:2]]};
						1: out = {data0[addr[$clog2(WIDTH)-1:2]+1], data3[addr[$clog2(WIDTH)-1:2]], data2[addr[$clog2(WIDTH)-1:2]], data1[addr[$clog2(WIDTH)-1:2]]};
						2: out = {data1[addr[$clog2(WIDTH)-1:2]+1], data0[addr[$clog2(WIDTH)-1:2]+1], data3[addr[$clog2(WIDTH)-1:2]], data2[addr[$clog2(WIDTH)-1:2]]};
						3: out = {data2[addr[$clog2(WIDTH)-1:2]+1], data1[addr[$clog2(WIDTH)-1:2]+1], data0[addr[$clog2(WIDTH)-1:2]+1], data3[addr[$clog2(WIDTH)-1:2]]};
					endcase
				end
				default: begin end

			endcase






	always @(posedge clk)
		if (MemWrite&&CE)
			case (MemLen)
				0: begin
					case (addr[1:0])
						0: data0[addr[$clog2(WIDTH)-1:2]] <= in[7:0];
						1: data1[addr[$clog2(WIDTH)-1:2]] <= in[7:0];
						2: data2[addr[$clog2(WIDTH)-1:2]] <= in[7:0];
						3: data3[addr[$clog2(WIDTH)-1:2]] <= in[7:0];
					endcase
				end
				1: begin
					case (addr[1:0])
						0: begin
							data0[addr[$clog2(WIDTH)-1:2]] <= in[7:0];
							data1[addr[$clog2(WIDTH)-1:2]] <= in[15:8];
						end
						1: begin
							data1[addr[$clog2(WIDTH)-1:2]] <= in[7:0];
							data2[addr[$clog2(WIDTH)-1:2]] <= in[15:8];
						end
						2: begin
							data2[addr[$clog2(WIDTH)-1:2]] <= in[7:0];
							data3[addr[$clog2(WIDTH)-1:2]] <= in[15:8];
						end
						3: begin
							data3[addr[$clog2(WIDTH)-1:2]] <= in[7:0];
							data1[addr[$clog2(WIDTH)-1:2]+1] <= in[15:8];
						end
					endcase
				end
				2: begin
					case (addr[1:0])
						0: begin
							data0[addr[$clog2(WIDTH)-1:2]] <= in[7:0];
							data1[addr[$clog2(WIDTH)-1:2]] <= in[15:8];
							data2[addr[$clog2(WIDTH)-1:2]] <= in[23:16];
							data3[addr[$clog2(WIDTH)-1:2]] <= in[31:24];
						end
						1: begin
							data1[addr[$clog2(WIDTH)-1:2]] <= in[7:0];
							data2[addr[$clog2(WIDTH)-1:2]] <= in[15:8];
							data3[addr[$clog2(WIDTH)-1:2]] <= in[23:16];
							data0[addr[$clog2(WIDTH)-1:2]+1] <= in[31:24];
						end
						2: begin
							data2[addr[$clog2(WIDTH)-1:2]] <= in[7:0];
							data3[addr[$clog2(WIDTH)-1:2]] <= in[15:8];
							data0[addr[$clog2(WIDTH)-1:2]+1] <= in[23:16];
							data1[addr[$clog2(WIDTH)-1:2]+1] <= in[31:24];
						end
						3: begin
							data3[addr[$clog2(WIDTH)-1:2]] <= in[7:0];
							data0[addr[$clog2(WIDTH)-1:2]+1] <= in[15:8];
							data1[addr[$clog2(WIDTH)-1:2]+1] <= in[23:16];
							data2[addr[$clog2(WIDTH)-1:2]+1] <= in[31:24];
						end
					endcase
				end



			endcase


endmodule
