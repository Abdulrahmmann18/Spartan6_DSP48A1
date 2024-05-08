module Register_and_mux_pair #(parameter WIDTH = 18, REG_SEL = 0, RSTTYPE = "SYNC")
(
	input wire [WIDTH-1:0] D_IN,
	input wire 			   clk,
	input wire 			   rst,
	input wire			   CE,
	output reg [WIDTH-1:0] D_OUT
);


	generate 
		if (REG_SEL) begin
			// reg
			if (RSTTYPE == "SYNC") begin
				// sync rst type
				always @(posedge clk) begin
					if (rst)
						D_OUT <= 'b0;
					else if (CE) 
						D_OUT <= D_IN;
				end
			end
			else if (RSTTYPE == "ASYNC") begin
				// async rst type
				always @(posedge clk or posedge rst) begin
					if (rst) 
						D_OUT <= 'b0;
					else if (CE)
						D_OUT <= D_IN;
				end
			end
		end	
		else begin
			// comb
			always @(*) begin
				D_OUT = D_IN;
			end			
		end		
	endgenerate


endmodule
