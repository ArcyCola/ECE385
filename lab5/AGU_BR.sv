module AGU( input   [15:0]      IR, PC, SR1_OUT,        // SR1_OUT is from output of register_file
            input   [1:0]       ADDR2MUX,
            input               ADDR1MUX,
            output  [15:0]      AGU_OUT);

logic [15:0] IRimm6sext, IRimm9sext, IRimm11sext, ADDR1MUXout, ADDR2MUXout;

always_comb
begin    
    unique case(IR[5]) //for LDR and STR
        1'b1 : IRimm6sext = {10'b1111111111, IR[5:0]};
        1'b0 : IRimm6sext = {10'b0000000000, IR[5:0]};
    endcase
    unique case(IR[8]) //for BR
        1'b1 : IRimm9sext = {7'b1111111, IR[8:0]};
        1'b0 : IRimm9sext = {7'b0000000, IR[8:0]};
    endcase
    unique case(IR[10]) //for JSR
        1'b1 : IRimm11sext = {5'b11111, IR[10:0]};
        1'b0 : IRimm11sext = {5'b00000, IR[10:0]};
    endcase
end

mux2_1  ADDR1_MUX(.In0(PC), .In1(SR1_OUT), .s(ADDR1MUX), .Out(ADDR1MUXout));

mux4_1  ADDR2_MUX(.In0(16'b0), .In1(IRimm6sext), .In2(IRimm9sext), .In3(IRimm11sext), .s(ADDR2MUX), .Out(ADDR2MUXout));

// add the outputs of ADDR1_MUX and ADDR2_MUX
assign AGU_OUT = ADDR1MUXout + ADDR2MUXout;
endmodule

//change states in BEN is 1 or 0
module BR(  input   [15:0] IR, D, 
            input   LD_BEN, LD_CC, Clk,
            output  BEN_Out);

logic [2:0] nzpIn, nzpOut; 
logic BEN_In, BEN_Out;

always_comb 
begin
    if (D[15]) begin //negative
        nzp = 3'b100;
    end
    else if (D == 16'b0) begin //zero
        nzp = 3'b010;
    end
    else begin //positive
        nzp = 3'b001;
    end
end
    //idk what to put reset yet
reg_3 NZP(.Clk, .Reset(), .Load(LD_CC), .D(nzp), .DataOut(nzpOut));
 
//logic for S_32
//BEN <- (IR[11] & N + IR[10] & Z + IR[9] & P)
assign BEN_In = (IR[11] & nzp[2]) + (IR[10] & nzp[1]) + (IR[9] & nzp[0]);

reg_1 BEN_reg(.Clk .Reset(), .Load(LD_BEN), .D(BEN_In) .DataOut(BEN_Out)); 
//havent put logic for BEN, its the logic in state 32.

endmodule