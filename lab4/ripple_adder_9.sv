module ripple_adder_9
(
	input  [7:0] A, B,
	input         fn, cin,		// function select, decides if we add or subtract
	output logic [7:0] S, //technically dont need 9th bit since it's just 8th bit again
);

    /* TODO
     *
     * Insert code here to implement a ripple adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	logic c1, c2, c3, c4, c5, c6, c7, c8;
	logic [7:0] B_fn;
	
	always_comb
	begin 
		unique case (fn)
			1'b1 : B_fn = B ^ fn; //fn = 1
			1'b0 : B_fn = B; //for fn = 0
		endcase
	end 

	full_adder FA0(.x(A[0]), .y(B_fn[0]), .z(cin), .s(S[0]), .c(c1));
	full_adder FA1(.x(A[1]), .y(B_fn[1]), .z(c1), .s(S[1]), .c(c2));
	full_adder FA2(.x(A[2]), .y(B_fn[2]), .z(c2), .s(S[2]), .c(c3));
	full_adder FA3(.x(A[3]), .y(B_fn[3]), .z(c3), .s(S[3]), .c(c4));
	full_adder FA4(.x(A[4]), .y(B_fn[4]), .z(c4), .s(S[4]), .c(c5));
	full_adder FA5(.x(A[5]), .y(B_fn[5]), .z(c5), .s(S[5]), .c(c6));
	full_adder FA6(.x(A[6]), .y(B_fn[6]), .z(c6), .s(S[6]), .c(c7));
	full_adder FA7(.x(A[7]), .y(B_fn[7]), .z(c7), .s(S[7]), .c(c8));
	//full_adder FA8(.x(A[7]), .y(B_fn[7]), .z(c7), .s(X), .c());

endmodule
