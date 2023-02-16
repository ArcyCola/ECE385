module Processor (  input logic [7:0] SW,
                    input logic Clk, Reset_Load_Clear, Run,
                    output logic [6:0]  HEX0, HEX1, HEX2, HEX3,
                    output logic [7:0] Aval, Bval,
                    output logic Xval       );

logic syncRun, syncReset, Clear, LoadA, LoadB, Shift, fn, X_in, LSB_A, M;
logic [7:0] A_in, SW_s;

//Synchronizers for buttons and switches
sync syncForRun(.Clk, .d(Run), .q(syncRun));
sync syncForReset(.Clk, .d(Reset_Load_Clear), .q(syncReset)); 
sync syncForSwtiches[7:0] (.Clk, .d(SW), .q(SW_s));

//top level unit for this lab
control         fsm(.Clk(Clk), .Run(syncRun), .Reset_Load_Clear(syncReset),
                    .M(), .Clear, .LoadA, .LoadB, .Shift, .fn); 

reg_8           RegA(.Clk(Clk), .Reset(Clear), .Load(LoadA), 
                    .Shift_En(Shift), .Shift_In(Xval), .D(A_in),
                    .Data_Out(Aval), .Shift_Out(LSB_A));
reg_8           RegB(.Clk(Clk), .Reset(Clear), .Load(LoadB), 
                    .Shift_En(Shift), .Shift_In(LSB_A), .D(SW_s),
                    .Data_Out(Bval), .Shift_Out(M));
reg_1           RegX(.Clk(Clk), .Reset(Clear), .Load(LoadA), 
                    .Shift_En(Shift), .Shift_In(A_in[7]),
                    .D(A_in[7]), .Data(Xval));

ripple_adder_9  adder(.A(Aval), .B(Bval), .fn(fn), .cin(fn), .S(A_in));

HexDriver       HexAU(.In0(Aval[7:4]), .Out0(HEX3));
HexDriver       HexAL(.In0(Aval[3:0]), .Out0(HEX2));
HexDriver       HexBU(.In0(Bval[7:4]), .Out0(HEX1));
HexDriver       HexBL(.In0(Bval[3:0]), .Out0(HEX0));

endmodule