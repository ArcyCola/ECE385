module ripple_adder_9
(
	input  [8:0] A, B,
	input         fn,		// function select, decides if we add or subtract
	output [8:0] S
);

    /* TODO
     *
     * Insert code here to implement a ripple adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	logic c1, c2, c3, c4, c5, c6, c7, c8;
	
	full_adder FA0(.x(A[0]), .y(B[0]), .z(fn), .s(S[0]));
	full_adder FA1(.x(A[1]), .y(B[1]), .z(fn), .s(S[1]));
	full_adder FA2(.x(A[2]), .y(B[2]), .z(fn), .s(S[2]));
	full_adder FA3(.x(A[3]), .y(B[3]), .z(fn), .s(S[3]));
	full_adder FA4(.x(A[4]), .y(B[4]), .z(fn), .s(S[4]));
	full_adder FA5(.x(A[5]), .y(B[5]), .z(fn), .s(S[5]));
	full_adder FA6(.x(A[6]), .y(B[6]), .z(fn), .s(S[6]));
	full_adder FA7(.x(A[7]), .y(B[7]), .z(fn), .s(S[7]));
	full_adder FA8(.x(A[8]), .y(B[8]), .z(fn), .s(S[8]));
	
endmodule
