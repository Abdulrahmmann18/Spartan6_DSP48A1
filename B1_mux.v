module B1_mux #(parameter WIDTH = 18)
(
	input wire  [WIDTH-1:0] pre_adder_result,
	input wire  [WIDTH-1:0] BOUT,
	input wire 			    sel,
	output wire [WIDTH-1:0] B1
);

	assign B1 = (~sel) ? BOUT : pre_adder_result ;
endmodule