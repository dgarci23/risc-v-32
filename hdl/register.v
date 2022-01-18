module register 
	
		#(parameter BUS_WIDTH = 32)
		
		(
			input									rst,
			input									clk,
			input									en,
			input			[BUS_WIDTH-1:0]	d,
			output reg	[BUS_WIDTH-1:0]	q
		);
		
		initial begin q <= 0; end
		
		always @(negedge clk)
			if (rst)
				q <= 0;
			else
				if (en)
					q <= d;
	
endmodule
				
	