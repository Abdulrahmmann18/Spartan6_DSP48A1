module B0_mux #(parameter WIDTH = 18, B_INPUT = "DIRECT")
(
	input wire [WIDTH-1:0] B,
	input wire [WIDTH-1:0] BCIN,
	output wire [WIDTH-1:0] BOUT 
);

	generate
		if (B_INPUT == "DIRECT")
			assign BOUT = B;
		else if (B_INPUT == "CASCADE")
			assign BOUT = BCIN;
		else 
			assign BOUT = 'b0;
	endgenerate


endmodule