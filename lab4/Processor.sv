module Processor (  input logic [7:0] SW,
                    input logic Clk, Reset_Load_Clear, Run,
                    output logic [6:0]  HEX0, HEX1, HEX2, HEX3
                    output logic [7:0] Aval, Bval
                    output logic Xval       ) 

logic syncRun, sycnReset, Clear, LoadA, LoadB, Shift, fn, X_in;
        LSB_A, M;
logic [7:0] A_in, SW_s;

//Synchronizers for buttons and switches
sync syncForRun(.Clk, .d(Run), .q(syncRun));
sync syncForReset(.Clk, .d(Reset_Load_Clear), .q(sycnReset)); 
sync syncForSwtiches[7:0] (.Clk, .d(SW), .q(SW_s));

//top level unit for this lab
control         fsm(.Clk, .Run(syncRun), .Reset_Load_Clear(syncReset),
                    .M(), .Clear, .LoadA, .LoadB, .Shift, .fn); 

reg_8           RegA(.Clk, .Reset(Clear), .Load(LoadA), 
                    .Shift_En(Shift), .Shift_In(X_out), .D(A_in)
                    .DatAval(Aval), .Shift_Out(LSB_A));
reg_8           RegB(.Clk, .Reset(Clear), .Load(LoadB), 
                    .Shift_En(Shift), .Shift_In(LSB_A), .D(SW_s)
                    .DatAval(Bval), .Shift_Out(M));
reg_1           RegX(.Clk, .Reset(Clear), .Load(LoadA), 
                    .Shift_En(Shift), .Shift_In(A_in[7]), .
                    .D(A_in[7]), .Data(Xval));

ripple_adder_9  adder(.A(Aval), .B(Bval), .fn(fn), .cin(fn), .S(A_in));

HexDriver       HexAU(.In0(A[7:4]), .Out0(HEX3));
HexDriver       HexAL(.In0(A[3:0]), .Out0(HEX2));
HexDriver       HexBU(.In0(B[7:4]), .Out0(HEX1));
HexDriver       HexBL(.In0(B[3:0]), .Out0(HEX0));

endmodule