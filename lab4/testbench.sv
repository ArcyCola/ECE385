module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.
logic Clk = 0;
logic [7:0] SW;
logic Reset_Load_Clear, Run;
logic [6:0]  HEX0, HEX1, HEX2, HEX3;
logic [7:0] Aval, Bval;
logic Xval;

// To store expected results

				
// A counter to count the instances where simulation results
// do no match with expected results
integer ErrorCnt = 0;
		
// Instantiating the DUT
// Make sure the module and signal names match with those in your design
Processor processor0(.*);	

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
// testing 7 * (-59) = -413
Run = 1; 
Reset_Load_Clear = 0; 

#2 Reset_Load_Clear = 1;
 
#10 SW = 8'b11000101;	// b = -59

#2 Reset_Load_Clear = 0; 

#10 Reset_Load_Clear = 1; 

#2 SW = 8'd7; 	// Switches = 7

#10 Run = 0; 
   
	
// testing -7 * 59 = -413
#100 Run = 1;

#2 Reset_Load_Clear = 0; 

#2 Reset_Load_Clear = 1;
 
#10 SW = 8'b00111011;		// b = 59

#2 Reset_Load_Clear = 0; 

#10 Reset_Load_Clear = 1; 

#2 SW = 8'b11111001; 		// switches = -7

#10 Run = 0; 


// testing 7*59 = 413

#100 Run = 1;

#2 Reset_Load_Clear = 0; 

#2 Reset_Load_Clear = 1;
 
#10 SW = 8'b00111011;		// b = 59

#2 Reset_Load_Clear = 0; 

#10 Reset_Load_Clear = 1; 

#2 SW = 8'd7; 		// switches = 7

#50 Run = 0; 


// testing -7 * -59

#100 Run = 1;

#2 Reset_Load_Clear = 0; 

#2 Reset_Load_Clear = 1;
 
#10 SW = 8'b11000101;		// b = -59

#2 Reset_Load_Clear = 0; 

#10 Reset_Load_Clear = 1; 

#2 SW = 8'b11111001; 		// switches = -7

#50 Run = 0; 


//test H74 * 74
#100 Run = 1;

#2 Reset_Load_Clear = 0; 

#2 Reset_Load_Clear = 1;
 
#10 SW = 8'b01110100;		// b = H74

#2 Reset_Load_Clear = 0; 

#10 Reset_Load_Clear = 1; 


#50 Run = 0; 


//test H8c*8c
#100 Run = 1;

#2 Reset_Load_Clear = 0; 

#2 Reset_Load_Clear = 1;
 
#10 SW = 8'b10001100;		// b = H74

#2 Reset_Load_Clear = 0; 

#10 Reset_Load_Clear = 1; 


#50 Run = 0; 

// testing -7 * -59

#100 Run = 1;

#2 Reset_Load_Clear = 0; 

#2 Reset_Load_Clear = 1;
 
#10 SW = 8'b10001100;		// 8c

#2 Reset_Load_Clear = 0; 

#10 Reset_Load_Clear = 1; 

#2 SW = 8'b01110100; 		// switches = -7

#50 Run = 0;

// testing -59 * 7
#200 Run = 1;

#2 Reset_Load_Clear = 0; 

#2 Reset_Load_Clear = 1;
 
#2 SW = 8'd7; 	// Switches = 7

#2 Reset_Load_Clear = 0; 

#10 Reset_Load_Clear = 1; 

#10 SW = 8'b11000101;	// b = -59

#10 Run = 0; 


end
endmodule
