module adder4
(
	input  [3:0] A, B,
	input         cin,
	output [3:0] S,
	output        cout
);

	logic c1, c2, c3;
	
	full_adder FA0(.x(A[0]), .y(B[0]), .z(cin), .s(S[0]), .c(c1));
	full_adder FA1(.x(A[1]), .y(B[1]), .z(c1), .s(S[1]), .c(c2));
	full_adder FA2(.x(A[2]), .y(B[2]), .z(c2), .s(S[2]), .c(c3));
	full_adder FA3(.x(A[3]), .y(B[3]), .z(c3), .s(S[3]), .c(cout));

endmodule

module select_adder (
	input  [15:0] A, B,
	input         cin,
	output [15:0] S,
	output        cout
);

    /* TODO
     *
     * Insert code here to implement a CSA adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */

    logic c3, c70, c71, c7f, c7and, c110, c111, c11f, c11and, c150, c151, c15and;
	logic [3:0] s740, s741, s1180, s1181, s15120, s15121;

    adder4 FA30(.A(A[3:0]), .B(B[3:0]), .cin(cin), .S(S[3:0]), .cout(c3));
	//S[3:0] FA
	adder4 FA740(.A(A[7:4]), .B(B[7:4]), .cin(0), .S(s740), .cout(c70)); //if c3 = 0 for s7-4
	adder4 FA741(.A(A[7:4]), .B(B[7:4]), .cin(1), .S(s741), .cout(c71)); //if c3 = 1 for s7-4
	assign c7and = c3&c71; 
	assign c7f = c7and | c70; //logic for c7 
	adder4 FA1180(.A(A[11:8]), .B(B[11:8]), .cin(0), .S(s1180), .cout(c110)); //if c7 = 0 s11-8
	adder4 FA1181(.A(A[11:8]), .B(B[11:8]), .cin(1), .S(s1181), .cout(c111)); //if c7 = 1 s11-8
	assign c11and = c7f & c111;
	assign c11f = c110 | c11and;
	adder4 FA15120(.A(A[15:12]), .B(B[15:12]), .cin(0), .S(s15120), .cout(c150)); //if c12 = 0 s15-11
	adder4 FA15121(.A(A[15:12]), .B(B[15:12]), .cin(1), .S(s15121), .cout(c151)); //if c12 = 1 s15-11
	assign c15and = c11f & c151;
	assign cout = c15and | c150;
	always_comb 
	begin 
		unique case(c3)
				1'b0    :   S[7:4] <= s740;
				1'b1    :   S[7:4] <= s741;
		endcase
		unique case(c7f)
				1'b0    :   S[11:8] <= s1180;
				1'b1    :   S[11:8] <= s1181;
		endcase
		unique case(c11f)
				1'b0    :   S[15:12] <= s15120;
				1'b1    :   S[15:12] <= s15121;
		endcase
	end

endmodule
