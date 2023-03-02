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
SW = 16'h0006;
Run = 0; //these are active low
Continue = 0;



#2 Run = 1;
	Continue = 1;

#2 Run = 1;

#2 Run = 0;

#2 Run = 1;
	 
#60 SW = 16'h0420;

#20 Continue = 0;

#5 Continue = 1;

end
endmodule
