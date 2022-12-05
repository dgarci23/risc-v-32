module clk_divider (
	input clk_in,
	input [10:0] divider,
	output clk_out
	);
	
	
	reg [27:0] counter;

	assign clk_out = (counter<divider[10:1])?1'b1:1'b0;

	always @(posedge clk_in)
	begin
		counter <= counter + 28'd1;
		if (counter>=(divider-1))
		  counter <= 28'd0;
	end
endmodule