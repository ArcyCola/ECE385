module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.
logic Clk = 0;
logic [9:0] SW;
logic Run, Continue;
logic [6:0]  HEX0, HEX1, HEX2, HEX3;
logic [9:0] LED;
// logic [15:0] Data_from_SRAM;
// logic OE, WE;
// logic [6:0] HEX0, HEX1, HEX2, HEX3;
// logic [15:0] ADDR;
// logic [15:0] Data_to_SRAM;


// To store expected results

// logic [15:0] IRout;
// assign IRout = slc3_testtop0.IR;
				
// A counter to count the instances where simulation results
// do no match with expected results
integer ErrorCnt = 0;
		
// Instantiating the DUT
// Make sure the module and signal names match with those in your design
slc3_testtop slc3_testtop0(.*);	

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 

// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
//SW = 16'h009C;
Run = 0; //these are active low
Continue = 0;

// Basic I/O Test 1

// set switches to start of program (x0003)
// press run
// hex displays should display value of switches

/*
#2 SW = 16'h0003;	// set switches to x0003 (start of program)

#2 Run = 1;
	Continue = 1;

#2 Run = 1;

#2 Run = 0;

#2 Run = 1;	// hex displays should eventually display 0003

#200 SW = 16'h0001;	// set switches to x0001, hex displays should display 0001
*/

// Basic I/O Test 2

// set switches to start of program (x0006)
// press run
// program pauses and asks for input (led should display x01)
// load switches to diff value
// press continue
// hex displays should display value from switches only after continue was pressed
// for 2nd and subsequent pauses leds display x02
/*
#2 SW = 16'h0006;	// set switches to x0006 (start of program)

#2 Run = 1;
	Continue = 1;	// "clear"

#2 Run = 1;	

#2 Run = 0;	// starts program

#2 Run = 1;

#100 Continue = 0;	// hex displays should eventually display 0006

#2 Continue = 1;

#100 SW = 16'h0001;	// set switches to x0001

#2 Continue = 0;

#2 Continue = 1;		// hex displays should eventually display 0001
*/

// Test 3 - Self-Modifying Code Test
/*

#2 SW = 16'h000b;	// set switches to x000b (start of program)

#2 Run = 1;
	Continue = 1;	// "clear"

#2 Run = 1;	

#2 Run = 0;	// starts program, led = x01

#2 Run = 1;

#100 Continue = 0;	// hex displays should eventually display 000b, led = x02

#2 Continue = 1;

#125 Continue = 0;

#2 Continue = 1;		// led is incremented

#125 Continue = 0;

#2 Continue = 1;

#125 Continue = 0;

#2 Continue = 1;
*/


// TEST 4 - COUNTER

/*
#2 SW = 16'h009C;

#2 Run = 1;
	Continue = 1;

#2 Run = 1;

#2 Run = 0;

#2 Run = 1;
*/


//TEST 5 - XOR

/*
#2 SW = 16'h0014;	// program start addresss

#2 Run = 1;
	Continue = 1;	// clear

#2 Run = 1;

#2 Run = 0;	// run is pressed

#2 Run = 1;

#100 SW = 16'hFFFF;	// input 1 = x3fff bc switches is only 10 bits

#10 Continue = 0;		// continue is pressed

#5 Continue = 1;

//#10 Continue = 0;		// continue is pressed again
//
//#5 Continue = 1;

#100 SW = 16'h0001;	// input 2 = x0001

#10 Continue = 0;		// continue is pressed

#5 Continue = 1;		// result should be x03fe
*/

//TEST 5 - Multiplication (Lab 4 in software)
/*

#2 SW = 16'h0031;	// start address

#2 Run = 1;
	Continue = 1;

#2 Run = 1;

#2 Run = 0;		// press run

#2 Run = 1;		// led = x01

#200 SW = 16'h0003;		// input 1 = 3

#10 Continue = 0;

#5 Continue = 1;

#100 SW = 16'h0002;

#10 Continue = 0;

#5 Continue = 1;
*/

//TEST 7 - SORT

#2 SW = 16'h005A;

#2 Run = 1;
	Continue = 1;

#2 Run = 1;

#2 Run = 0;

#2 Run = 1;

#200 SW = 16'h0002;

#2 Continue = 0;

#2 Continue = 1;

#30000 SW = 15'h0003;

#2 Continue = 0;		// index 0

#2 Continue = 1;

#3000 Continue = 0;	// index 1

#2 Continue = 1;

#3000 Continue = 0;	// index 2

#2 Continue = 1;

#3000 Continue = 0;	// index 3

#2 Continue = 1;

#3000 Continue = 0;	// index 4

#2 Continue = 1;

#3000 Continue = 0;	// index 5

#2 Continue = 1;

#3000 Continue = 0;	// index 6

#2 Continue = 1;

#3000 Continue = 0;	// index 7

#2 Continue = 1;

#3000 Continue = 0;	// index 8

#2 Continue = 1;

#3000 Continue = 0;	// index 9

#2 Continue = 1;

#3000 Continue = 0;	// index A

#2 Continue = 1;

#3000 Continue = 0;	// index B

#2 Continue = 1;

#3000 Continue = 0;	// index C

#2 Continue = 1;

#3000 Continue = 0;	// index D

#2 Continue = 1;

#3000 Continue = 0;	// index E

#2 Continue = 1;

#3000 Continue = 0;	// index F

#2 Continue = 1;

#3000 Continue = 0;	

#2 Continue = 1;

end

endmodule
