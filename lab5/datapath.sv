module datapath(input gatePC, gateMARMUX, gateALU, gateMDR, 
            Clk, loadIR, LD_PC, MIO_EN, LD_MDR, LD_MAR, LD_IR, Reset,
					 input [15:0] MDR_In,
                output logic [15:0] IRout, MDR, MAR);        // IRout will go to hex displays for 5.1

    logic [15:0] PC, MARMUX, ALU, databus; //to be assigned to databus output w mux

    PCmod       pc(.PCadder(), .Reset(Reset), .inDP(), .PCMUXsel(2'b00), .loadPC(LD_PC), .Clk(Clk), .PC(PC), .databus(databus)); 


    //need to find shit for PCadder, Reset, inDP later, will do later
    MAR_MDR_mod mar_mdr(.Clk(Clk), .loadMAR(LD_MAR), .loadMDR(LD_MDR), .loadIR(LD_IR), 
                        .MIO_EN(MIO_EN), .databus(databus), .Data_to_CPU(MDR_In), 
                        .MAR(MAR), .MDR(MDR)); 

    logic [3:0] bus_select; //= {gateMARMUX, gatePC, gateALU, gateMDR}; // one hot encoder

    always_comb
    begin
	 bus_select[3] = gateMARMUX;
	 bus_select[2] = gatePC;
	 bus_select[1] = gateALU;
	 bus_select[0] = gateMDR;
        unique case(bus_select)
            4'b1000    : databus <= MARMUX; //will be done in 5.2
            4'b0100    : databus <= PC;
            4'b0010    : databus <= ALU;
            4'b0001    : databus <= MDR;
            default    : databus <= 16'bX;
        endcase
    end
    
    //IR register will be instatinated here because needs that 4:1 MUX output
    reg_16 IRreg(.Clk(Clk), .Reset(Reset), .Load(loadIR), .D(databus), .Data_Out(IRout));    //reset???, uhh data_out should be displayed in reg
    //assign logic [15:0] IRout; 

endmodule

module PCmod(input [15:0] PCadder, inDP, databus,
             input [1:0] PCMUXsel, 
             input loadPC, Clk, Reset,
             output logic [15:0] PC);

    logic [15:0] PC_next;
    //remember to connect reset to something, not implemented just yet
    reg_16 PCreg(.Clk(Clk), .Reset(Reset), .Load(loadPC), .D(PC_next), .Data_Out(PC));   // RESET ??????

    always_comb // PCMUX implementation, 3?:1 MUX that goes back into PCreg
    begin  
        unique case (PCMUXsel)
            2'b00  :   PC_next <= PC + 1; //not sure if either <= or =, check if we can do " + 1"
            2'b01  :   PC_next <= databus;//havent thought of what we what for the select choosing,
            //2'b10  : //either/or inDP or PCadder
            //2'b11  : //which one wont be implemented
            default  : PC_next <= 16'bX; //dont know what to do just yet
        endcase
    end
endmodule

module MAR_MDR_mod(input Clk, loadMAR, loadMDR, loadIR, MIO_EN, Reset,
                 input [15:0] databus, 
                 input [15:0] Data_to_CPU, 
                 output [15:0] MAR, MDR);                
    reg_16 MARreg(.Clk(Clk), .Reset(Reset), .Load(loadMAR), .D(databus), .Data_Out(MAR));    // RESET ??????

    logic [15:0] MDR_next;
    reg_16 MDRreg(.Clk(Clk), .Reset(Reset), .Load(loadMDR), .D(MDR_next), .Data_Out(MDR));   // RESET???????
    always_comb // MDRMUX implementation, 2:1 mux. output
    begin
        unique case (MIO_EN) //2:1 MUX connected to 
            1'b1    :   MDR_next <= Data_to_CPU; 
            1'b0    :   MDR_next <= databus;
            //default   : MDR_next <= 16'bX;
        endcase
    end
endmodule
