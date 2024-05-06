module Spartan6_DSP48A1 #(parameter A0REG = 0, B0REG = 0, A1REG = 1, B1REG = 1, CREG = 1, DREG = 1, MREG = 1, PREG = 1, CARRYINREG = 1, CARRYOUTREG = 1, OPMODEREG = 1,
							CARRYINSEL = "OPMODE5", B_INPUT = "DIRECT", RSTTYPE = "ASYNC")
(
	input wire  [17:0] A, 
	input wire  [17:0] B,
	input wire  [17:0] D,
	input wire  [47:0] C,
	input wire		   clk,
	input wire 		   CARRYIN,
	input wire  [7:0]  OPMODE,
	input wire  [17:0] BCIN,
	input wire		   RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE,
	input wire  	   CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE,
	input wire  [47:0] PCIN,
	output wire [17:0] BCOUT,
	output wire [47:0] PCOUT,
	output wire [47:0] P,
	output wire [35:0] M,
	output wire 	   CARRYOUT,
	output wire 	   CARRYOUTF	 
);
	// wires 
	wire [7:0] OPMODE_OUT;
	wire [17:0] D_OUT, A0_OUT, B_PORT, B0_OUT, PRE_ADDER_RESULT, B1_IN, A1_OUT;
	wire [47:0] C_OUT, sign_extended_M, X_MUX_OUT, Z_MUX_OUT, POST_ADDER_RESULT;
	wire CY1_IN, CY1_OUT, PRE_ADDER_CARRYOUT, POST_ADDER_CARRYOUT;
	wire [35:0] Multplier_OUT;

	/* **************************************************************************** */
	// first stage 
	Register_and_mux_pair #(.WIDTH(8), .REG_SEL(OPMODEREG), .RSTTYPE(RSTTYPE)) OPMODE_PAIR 
	(
		.D_IN(OPMODE), .clk(clk), .rst(RSTOPMODE), .CE(CEOPMODE), .D_OUT(OPMODE_OUT)
	);
	Register_and_mux_pair #(.WIDTH(18), .REG_SEL(DREG), .RSTTYPE(RSTTYPE)) D_PAIR 
	(
		.D_IN(D), .clk(clk), .rst(RSTD), .CE(CED), .D_OUT(D_OUT)
	);
	Register_and_mux_pair #(.WIDTH(18), .REG_SEL(A0REG), .RSTTYPE(RSTTYPE)) A0_PAIR 
	(
		.D_IN(A), .clk(clk), .rst(RSTA), .CE(CEA), .D_OUT(A0_OUT)
	);
	Register_and_mux_pair #(.WIDTH(48), .REG_SEL(CREG), .RSTTYPE(RSTTYPE)) C_PAIR 
	(
		.D_IN(C), .clk(clk), .rst(RSTC), .CE(CEC), .D_OUT(C_OUT)
	);
	B0_mux #(.WIDTH(18) , .B_INPUT(B_INPUT)) b0mux
	(
		.B(B), .BCIN(BCIN), .BOUT(B_PORT) 
	);
	Register_and_mux_pair #(.WIDTH(18), .REG_SEL(B0REG), .RSTTYPE(RSTTYPE)) B0_PAIR 
	(
		.D_IN(B_PORT), .clk(clk), .rst(RSTB), .CE(CEB), .D_OUT(B0_OUT)
	);
	/* **************************************************************************** */

	/* **************************************************************************** */
	// second stage
	// pre adder-sub
	Adder_Sub #(.WIDTH(18)) pre_adder_sub
	(
		.operand1(D_OUT), .operand2(B0_OUT), .sel(OPMODE_OUT[6]), .cin(1'b0), .result(PRE_ADDER_RESULT), .cout(PRE_ADDER_CARRYOUT)
	);
	// B1MUX
	B1_mux #(.WIDTH(18)) b1mux
	(
		.pre_adder_result(PRE_ADDER_RESULT), .BOUT(B0_OUT), .sel(OPMODE_OUT[4]), .B1(B1_IN)
	);
	Register_and_mux_pair #(.WIDTH(18), .REG_SEL(A1REG), .RSTTYPE(RSTTYPE)) A1_PAIR 
	(
		.D_IN(A0_OUT), .clk(clk), .rst(RSTA), .CE(CEA), .D_OUT(A1_OUT)
	);
	Register_and_mux_pair #(.WIDTH(18), .REG_SEL(B1REG), .RSTTYPE(RSTTYPE)) B1_PAIR 
	(
		.D_IN(B1_IN), .clk(clk), .rst(RSTB), .CE(CEB), .D_OUT(BCOUT)
	);
	/* **************************************************************************** */

	/* **************************************************************************** */
	// third stage
	multplier #(.IN_WIDTH(18), .OUT_WIDTH(36)) mul
	(
		.IN1(BCOUT), .IN2(A1_OUT), .MUL_OUT(Multplier_OUT)
	);
	Register_and_mux_pair #(.WIDTH(36), .REG_SEL(MREG), .RSTTYPE(RSTTYPE)) M_PAIR 
	(
		.D_IN(Multplier_OUT), .clk(clk), .rst(RSTM), .CE(CEM), .D_OUT(M)
	);
	// carryin select
	Carryin_mux #(.WIDTH(1) , .CARRYINSEL(CARRYINSEL)) carryin_mux
	(
		.OPMODE5_IN(OPMODE_OUT[5]), .CARRYIN(CARRYIN), .MUX_OUT(CY1_IN) 
	);
	Register_and_mux_pair #(.WIDTH(1), .REG_SEL(CARRYINREG), .RSTTYPE(RSTTYPE)) CY1 
	(
		.D_IN(CY1_IN), .clk(clk), .rst(RSTCARRYIN), .CE(CECARRYIN), .D_OUT(CY1_OUT)
	);
	/* **************************************************************************** */

	/* **************************************************************************** */
	// fourth stage
	// sign extension for M
	sign_ext #(.IN_WIDTH(36), .OUT_WIDTH(48)) sign_ext
	(
		.IN(M), .OUT(sign_extended_M)
	);
	// Z_MUX & X_MUX
	FourToOne_mux #(.WIDTH(48)) XMUX
	(
		.IN0(48'b0), .IN1(sign_extended_M), .IN2(P), .IN3({D_OUT[11:0], A1_OUT, BCOUT}), .sel(OPMODE_OUT[1:0]), .MUX_OUT(X_MUX_OUT)
	);
	FourToOne_mux #(.WIDTH(48)) ZMUX
	(
		.IN0(48'b0), .IN1(PCIN), .IN2(P), .IN3(C_OUT), .sel(OPMODE_OUT[3:2]), .MUX_OUT(Z_MUX_OUT)
	);
	// post adder-sub
	Adder_Sub #(.WIDTH(48)) post_adder_sub
	(
		.operand1(Z_MUX_OUT), .operand2(X_MUX_OUT), .sel(OPMODE_OUT[7]), .cin(CY1_OUT), .result(POST_ADDER_RESULT), .cout(POST_ADDER_CARRYOUT)
	);
	Register_and_mux_pair #(.WIDTH(1), .REG_SEL(CARRYOUTREG), .RSTTYPE(RSTTYPE)) CY0 
	(
		.D_IN(POST_ADDER_CARRYOUT), .clk(clk), .rst(RSTCARRYIN), .CE(CECARRYIN), .D_OUT(CARRYOUT)
	);	
	Register_and_mux_pair #(.WIDTH(48), .REG_SEL(PREG), .RSTTYPE(RSTTYPE)) P_PAIR 
	(
		.D_IN(POST_ADDER_RESULT), .clk(clk), .rst(RSTP), .CE(CEP), .D_OUT(P)
	);
	assign PCOUT = P ;
	assign CARRYOUTF = CARRYOUT ;
	/* **************************************************************************** */

endmodule

