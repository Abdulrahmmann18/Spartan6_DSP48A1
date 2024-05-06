module FourToOne_mux #(parameter WIDTH = 48)
(
	input wire [WIDTH-1:0] IN0, IN1, IN2, IN3,
	input wire [1:0]		sel,
	output reg [WIDTH-1:0]	MUX_OUT
);

	always @(*) begin
		case (sel)
			2'b00 : MUX_OUT = IN0;
			2'b01 : MUX_OUT = IN1;
			2'b10 : MUX_OUT = IN2;
			2'b11 : MUX_OUT = IN3;
		endcase
	end
endmodule