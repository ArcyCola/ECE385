module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.
logic Clk = 0;
logic [9:0] SW;
logic Reset_Clear, Run_Accumulate;
logic [9:0] LED;
logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;


// To store expected results

// A counter to count the instances where simulation results
// do no match with expected results
integer ErrorCnt = 0;
		
// Instantiating the DUT
// Make sure the module and signal names match with those in your design
adder_toplevel processor0(.*);	

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
Run_Accumulate = 1; 
Reset_Clear = 0; 

#2 Reset_Clear = 1;
 
#10 SW = 10'b0110000001; //385

#10 Run_Accumulate = 0; 
   
	
#100 Run_Accumulate = 1;

#10 Run_Accumulate = 0; //add 385 again
end
endmodule
