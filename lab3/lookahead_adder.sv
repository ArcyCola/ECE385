/*
module adder4
(
	input  [3:0] A, B,
	input         cin,
	output [3:0] S,
	output        cout
);

    /* TODO
     *
     * Insert code here to implement a ripple adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. 
	logic c1, c2, c3;
	
	full_adder FA0(.x(A[0]), .y(B[0]), .z(cin), .s(S[0]), .c(c1));
	full_adder FA1(.x(A[1]), .y(B[1]), .z(c1), .s(S[1]), .c(c2));
	full_adder FA2(.x(A[2]), .y(B[2]), .z(c2), .s(S[2]), .c(c3));
	full_adder FA3(.x(A[3]), .y(B[3]), .z(c3), .s(S[3]), .c(cout));
	
endmodule
*/

module lookahead4 ( input [3:0]  A, B,
					input        cin,
					output       Pg, Gg, 
					output [3:0] S );

		logic c_unused; //idk if i can leave it open
		adder4 FA(.A(A), .B(B), .cin(cin), .S(S), .cout(c_unused));
					

		assign Pg = (A[0]^B[0]) & (A[1]^B[1]) & (A[2]^B[2]) & (A[3]^B[3]);
		assign Gg = (A[3] & B[3]) | ((A[2] & B[2]) & (A[3]^B[3])) | ((A[1] & B[1]) & (A[3]^B[3]) & (A[2]^B[2])) | ((A[0]&B[0]) & (A[1]^B[1]) & (A[2]^B[2]) & (A[3]^B[3]));



endmodule

module lookahead_adder (
	input  [15:0] A, B,
	input         cin,
	output [15:0] S,
	output        cout
);
    /* TODO
     *
     * Insert code here to implement a CLA adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	logic pg0, gg0, pg4, gg4, pg8, gg8, pg12, gg12, c4, c8, c12, pg16, gg16;
	//logic [3:0] pg, gg, car;
	

	lookahead4 FA3(.A(A[3:0]), .B(B[3:0]), .cin(cin), .Pg(pg0), .Gg(gg0), .S(S[3:0]));
	assign c4 = gg0 | (cin & pg0);
	lookahead4 FA7(.A(A[7:4]), .B(B[7:4]), .cin(c4), .Pg(pg4), .Gg(gg4), .S(S[7:4]));
	assign c8 = gg4 | (gg0&pg4) | (cin&pg0&pg4);
	lookahead4 FA11(.A(A[11:8]), .B(B[11:8]), .cin(c8), .Pg(pg8), .Gg(gg8), .S(S[11:8]));
	assign c12 = gg8 | (gg4 & pg8) | (gg0 & pg8 & pg4) | (cin & pg8 & pg4 & pg0);
	lookahead4 FA15(.A(A[15:12]), .B(B[15:12]), .cin(c12), .Pg(pg12), .Gg(gg12), .S(S[15:12]));
	assign cout = gg12 | (gg8 & pg12) | (gg4 & pg12 & pg8) | (gg0 & pg12 & pg8 & pg4) | (cin & pg12 & pg8 & pg4 & pg0);
	
	//assign cout = car[3];
	/*
	assign pg[0] = pg0;
	assign gg[0] = gg0;
	assign pg[1] = pg4;
	assign gg[1] = gg4;
	assign pg[2] = pg8;
	assign gg[2] = gg8;
	assign pg[3] = pg12;
	assign gg[3] = gg12;
	*/
	//lookahead4 FA5(.A(pg), .B(gg), .cin(cin), .Pg(pg16), .Gg(gg16), .S(car));
	
endmodule
