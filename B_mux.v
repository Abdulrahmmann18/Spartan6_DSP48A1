module B0_mux #(parameter WIDTH = 18, B_INPUT = "DIRECT")
(
	input wire [WIDTH-1:0] B,
	input wire [WIDTH-1:0] BCIN,
	output reg [WIDTH-1:0] BOUT 
);

	generate
		if (B_INPUT == "DIRECT")
			BOUT = B;
		else if (B_INPUT == "CASCADE")
			BOUT = BCIN;
		else 
			BOUT = 'b0;
	endgenerate


endmodule