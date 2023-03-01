module register_file(   input   [15:0] D, IR,
                        input   [2:0] SR2 
                        input   Clk, Reset, LD_REG, SR1MUX, DRMUX,
                        output  [15:0] SR1_OUT, SR2_OUT);
// implementation of DRMUX
// takes DR as the channel select which chooses

logic [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
logic [2:0] DRMUXout, SR1MUXout;
logic [7:0] LoadEn;
// eight 16-bit registers
reg_16  R0(.Clk(Clk), .Reset(Reset), .Load(LoadEn[0]), .D, .Data_Out(R0));
reg_16  R1(.Clk(Clk), .Reset(Reset), .Load(LoadEn[1]), .D, .Data_Out(R1));
reg_16  R2(.Clk(Clk), .Reset(Reset), .Load(LoadEn[2]), .D, .Data_Out(R2));
reg_16  R3(.Clk(Clk), .Reset(Reset), .Load(LoadEn[3]), .D, .Data_Out(R3));
reg_16  R4(.Clk(Clk), .Reset(Reset), .Load(LoadEn[4]), .D, .Data_Out(R4));
reg_16  R5(.Clk(Clk), .Reset(Reset), .Load(LoadEn[5]), .D, .Data_Out(R5));
reg_16  R6(.Clk(Clk), .Reset(Reset), .Load(LoadEn[6]), .D, .Data_Out(R6));
reg_16  R7(.Clk(Clk), .Reset(Reset), .Load(LoadEn[7]), .D, .Data_Out(R7));

mux2_1 #(3) DR_MUX(.In0(IR[11:9]), .In1(3'b111), .s(DRMUX), .Out(DRMUXout)); //dr mux before going into reg file

// decoder for selecting which register to write to
if (LD_REG == 1'b1)
    begin
        unique case(DRmuxOut)
            3'b000  : LoadEn = 8'b00000001;
            3'b001  : LoadEn = 8'b00000010;
            3'b010  : LoadEn = 8'b00000100;
            3'b011  : LoadEn = 8'b00001000;
            3'b100  : LoadEn = 8'b00010000;
            3'b101  : LoadEn = 8'b00100000;
            3'b110  : LoadEn = 8'b01000000;
            3'b111  : LoadEn = 8'b10000000;
            default : LoadEn = 8'bX;
        endcase
    end
else //this should work, will check later with the TA
    begin   
        LoadEn = 8'b00000000;
end 

mux2_1 #(3) SR1_MUX(.In0(IR[8:6]), .In1(IR[11:9]), .s(SR1MUX), .Out(SR1MUXout));
//mux for SR1_OUT and SR2_OUT
always_comb
begin
    unique case(SR1MUXout)
        3'b000  : SR1_OUT = R0;
        3'b001  : SR1_OUT = R1;
        3'b010  : SR1_OUT = R2;
        3'b011  : SR1_OUT = R3;
        3'b100  : SR1_OUT = R4;
        3'b101  : SR1_OUT = R5;
        3'b110  : SR1_OUT = R6;
        3'b111  : SR1_OUT = R7;
        default : SR1_OUT = 16'bX;
    endcase
    unique case(SR2)
        3'b000  : SR2_OUT = R0;
        3'b001  : SR2_OUT = R1;
        3'b010  : SR2_OUT = R2;
        3'b011  : SR2_OUT = R3;
        3'b100  : SR2_OUT = R4;
        3'b101  : SR2_OUT = R5;
        3'b110  : SR2_OUT = R6;
        3'b111  : SR2_OUT = R7;
        default : SR2_OUT = 16'bX;
    endcase
end
endmodule