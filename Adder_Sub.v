module Adder_Sub #(parameter WIDTH = 18)
(
	input wire  [WIDTH-1:0] operand1,
	input wire  [WIDTH-1:0] operand2,
	input wire 			    sel,
	input wire 				cin,
	output wire [WIDTH-1:0] result,
	output wire 			cout
);

	assign {cout, result} = (~sel) ? (operand1+operand2+cin) : (operand1-(operand2+cin)) ;
endmodule