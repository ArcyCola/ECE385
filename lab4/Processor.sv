module Processor (  input logic [7:0] SW,
                    input logic Clk, Reset_Load_Clear, Run,
                    output logic [6:0]  HEX0, HEX1, HEX2, HEX3
                    output logic [7:0] Aval, Bval
                    output logic Xval       ) 

logic syncRun, sycnReset, Clear, LoadA, LoadB, Shift, fn, X_in, X_out,
        LSB_A, M;
logic [7:0] A_in, A_out, Data_B_in, B_out, SW_s;
//Synchronizers for buttons and switches
sync syncForRun(.Clk, .d(Run), .q(syncRun));
sync syncForReset(.Clk, .d(Reset_Load_Clear), .q(sycnReset)); 
sync syncForSwtiches[7:0] (.Clk, .d(SW), .q(SW_s));

//top level unit for this lab
control         fsm(.Clk, .Run(syncRun), .Reset_Load_Clear(syncReset),
                    .M(), .Clear, .LoadA, .LoadB, .Shift, .fn); 
reg_8           RegA(.Clk, .Reset(Clear), .Load(LoadA), 
                    .Shift_En(Shift), .Shift_In(X_out), .D(A_in)
                    .Data_Out(A_out), .Shift_Out(LSB_A) 
);
reg_8           RegB(.Clk, .Reset(Clear), .Load(LoadB), 
                    .Shift_En(Shift), .Shift_In(LSB_A), .D(SW_s)
                    .Data_Out(B_out), .Shift_Out(M)
                );
reg_1           RegX(.Clk, .Reset(Clear), .Load(LoadA), 
                    .Shift_En(Shift), .Shift_In(A_in[7]), .
                    .D(A_in[7]), .Data(X_out));



HexDriver       HexBU();
HexDriver       HexBL();
HexDriver       HexAU();
HexDriver       HexAL();
endmodule