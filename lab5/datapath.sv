module datapath(input GatePC, GateMARMUX, GateALU, GateMDR, 
            Clk, LD_PC, MIO_EN, LD_MDR, LD_MAR, LD_IR, Reset, LD_REG, SR1MUX,
            DRMUX, ADDR1MUX, LD_BEN, LD_CC, SR2MUX,
                input [1:0] ADDR2MUX, PCMUX, ALUK,
					 input [15:0] MDR_In,
                output logic BEN,
                output logic [15:0] IR, MDR, MAR);        // IR will go to hex displays for 5.1

    logic [15:0] PC, ALU, databus, AGU_OUT, SR1_OUT, SR2_OUT; //to be assigned to databus output w mux


    PCmod       pc(.AGU_OUT, .Reset(Reset), .PCMUX, .LD_PC(LD_PC), .Clk(Clk), .PC(PC), .databus(databus)); 


    //need to find shit for PCadder, Reset, inDP later, will do later
    MAR_MDR_mod mar_mdr(.Clk(Clk), .LD_MAR(LD_MAR), .LD_MDR(LD_MDR), .LD_IR(LD_IR), 
                        .MIO_EN(MIO_EN), .databus(databus), .Data_to_CPU(MDR_In), 
                        .MAR(MAR), .MDR(MDR)); 

    logic [3:0] bus_select; //= {GateMARMUX, GatePC, GateALU, GateMDR}; // one hot encoder

    always_comb
    begin
	 bus_select[3] = GateMARMUX;
	 bus_select[2] = GatePC;
	 bus_select[1] = GateALU;
	 bus_select[0] = GateMDR;
        unique case(bus_select)
            4'b1000    : databus <= AGU_OUT; //will be done in 5.2
            4'b0100    : databus <= PC;
            4'b0010    : databus <= ALU;
            4'b0001    : databus <= MDR;
            default    : databus <= 16'bX;
        endcase
    end
    
    //IR register will be instatinated here because needs that 4:1 MUX output
    reg_16          IRreg(.Clk(Clk), .Reset(Reset), .Load(LD_IR), .D(databus), .Data_Out(IR));    //reset???, uhh data_out should be displayed in reg
    
    //assign logic [15:0] IR; 
    register_file   reg_file_mod(.Clk, .D(databus), .IR, .Reset, .SR2(IR[2:0]), .LD_REG, .SR1MUX, .DRMUX, .SR1_OUT, .SR2_OUT);
    AGU             agu_mod     (.IR, .PC, .SR1_OUT, .ADDR2MUX, .ADDR1MUX, .AGU_OUT);
    BR              br_mod      (.IR, .databus, .LD_BEN, .Clk, .LD_CC, .BEN_Out(BEN), .Reset);
    ALU             alu_mod     (.SR1_OUT, .SR2_OUT, .IR, .ALUK, .SR2MUX, .ALU_OUT(ALU));

endmodule


//PC sub-module, handles PCreg and nearby logic
module PCmod(input [15:0] AGU_OUT, databus,
             input [1:0] PCMUX, 
             input LD_PC, Clk, Reset,
             output logic [15:0] PC);

    logic [15:0] PC_next;
    //remember to connect reset to something, not implemented just yet
    reg_16 PCreg(.Clk(Clk), .Reset(Reset), .Load(LD_PC), .D(PC_next), .Data_Out(PC));   // RESET ??????

    always_comb // PCMUX implementation, 3?:1 MUX that goes back into PCreg
    begin  
        unique case (PCMUX)
            2'b00  :   PC_next <= PC + 1; //not sure if either <= or =, check if we can do " + 1"
            2'b01  :   PC_next <= databus;//havent thought of what we what for the select choosing,
            2'b10  :   PC_next <= AGU_OUT;
            default  : PC_next <= 16'bX; //dont know what to do just yet
        endcase
    end
endmodule


//MAR_MDR submodule, handles data in and out for receiving data from PC
module MAR_MDR_mod(input Clk, LD_MAR, LD_MDR, LD_IR, MIO_EN, Reset,
                 input [15:0] databus, 
                 input [15:0] Data_to_CPU, 
                 output [15:0] MAR, MDR);                
    reg_16 MARreg(.Clk(Clk), .Reset(Reset), .Load(LD_MAR), .D(databus), .Data_Out(MAR));    // RESET ??????

    logic [15:0] MDR_next;
    reg_16 MDRreg(.Clk(Clk), .Reset(Reset), .Load(LD_MDR), .D(MDR_next), .Data_Out(MDR));   // RESET???????
    always_comb // MDRMUX implementation, 2:1 mux. output
    begin
        unique case (MIO_EN) //2:1 MUX connected to 
            1'b1    :   MDR_next <= Data_to_CPU; 
            1'b0    :   MDR_next <= databus;
            //default   : MDR_next <= 16'bX;
        endcase
    end
endmodule
