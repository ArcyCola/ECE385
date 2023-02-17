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
Run = 0; 
Reset_Load_Clear = 1; 

#2 Reset_Load_Clear = 0;
 
#10 SW = 8'd7;

#2 Reset_Load_Clear = 1; 

#10 Reset_Load_Clear = 0; 


#2 SW = 8'd59; 

#10 Run = 1; 
   




end
endmodule
