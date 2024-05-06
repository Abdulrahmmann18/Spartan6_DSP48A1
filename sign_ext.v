module sign_ext #(parameter IN_WIDTH = 38, OUT_WIDTH = 48)
(
	input wire  [IN_WIDTH-1:0]  IN,
	output wire [OUT_WIDTH-1:0] OUT
);
	localparam EXT_WIDTH = OUT_WIDTH - IN_WIDTH;
	
	assign OUT = { {EXT_WIDTH{IN[IN_WIDTH-1]}}, IN} ;

endmodule