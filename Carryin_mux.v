module Carryin_mux #(parameter WIDTH = 1, CARRYINSEL = "OPMODE5")
(
	input wire [WIDTH-1:0] OPMODE5_IN,
	input wire [WIDTH-1:0] CARRYIN,
	output wire [WIDTH-1:0] MUX_OUT 
);

	generate
		if (CARRYINSEL == "OPMODE5")
			assign MUX_OUT = OPMODE5_IN;
		else if (CARRYINSEL == "CARRYIN")
			assign MUX_OUT = CARRYIN;
		else 
			assign MUX_OUT = 'b0;
	endgenerate


endmodule