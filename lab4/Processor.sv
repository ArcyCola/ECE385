module Processor (  input logic [7:0] SW,
                    input logic Clk, Reset_Load_Clear, Run,
                    output logic [6:0]  HEX0, HEX1, HEX2, HEX3
                    output logic [7:0] Aval, Bval
                    output logic Xval       ) 

//top level unit for this lab

reg_8           RegA(.Clk(Clk),
                    .Reset(Reset_Load_Clear),

);

HexDriver       HexB0();
HexDriver       HexB1();
HexDriver       HexA0();
HexDriver       HexA1();
endmodule