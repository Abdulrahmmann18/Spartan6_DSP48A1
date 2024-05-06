module multplier #(parameter IN_WIDTH = 18, OUT_WIDTH = 36)
(
	input wire  [IN_WIDTH-1:0]  IN1, IN2,
	output wire [OUT_WIDTH-1:0] MUL_OUT
);

	assign MUL_OUT = IN1 * IN2 ;

endmodule