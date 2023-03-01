module ALU(     input   [15:0]      SR1_OUT, SR2_OUT, IR
                //input   [4:0]       IRimm5,
                input   [1:0]       ALUK,   // comes from control, should be top 2 bits of opcode(?)
                output  [15:0]      ALU_OUT);

logic [15:0] SR2MUX_OUT, IRimm5sext;

// takes in IR[4:0] (least significant 5 bits of IR) and sign extends to 16 bits
if (IR[4]) begin    // if IR[4]=1
    IRimm5sext = {11'b11111111111, IR[4:0]};
end
else begin          // when IR[4]=0
    IRimm5sext = {11'b00000000000, IR[4:0]};
end

mux2_1  SR2_MUX(.In0(SR2_OUT), .In1(IRimm5sext), .s(IR[5]), .Out(SR2MUX_OUT));

// opcodes (ALUK)
// ADD: 00
// AND: 01
// NOT: 10

always_comb
begin
    unique case(ALUK)
        2'b00   : ALU_OUT = SR1_OUT + SR2MUX_OUT;
        2'b01   : ALU_OUT = SR1_OUT & SR2MUX_OUT;
        2'b10   : ALU_OUT = !SR1OUT;
        default : ALU_OUT = 16'bX;
    endcase
end

endmodule