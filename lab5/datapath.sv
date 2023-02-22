module datapath(input gatePC, gateMARMUX, gateALU, gateMDR, Clk,
                output logic [15:0] MDR, PC, MARMUX, ALU); 
    
endmodule

module PCmod(input [15:0] PCadder, inDP, 
             input [1:0] PCMUXsel, 
             input loadPC, Clk,
             output logic [15:0] PC);

    logic [15:0] PC_next;
    //remember to connect reset to something, not implemented just yet
    reg_16 PC(.Clk(Clk), .Reset() .Load(loadPC), .D(PC_next), .Data_Out(PC));
    always_comb
    begin  
        unique case (PCMUXsel)
            2'b00  :   PC_next <= PC + 1; //not sure if either <= or =, check if we can do " + 1"
            //2'b01  : //havent thought of what we what for the select choosing,
            //2'b10  : //either/or inDP or PCadder
            //2'b11  : //which one wont be implemented
            default  : PC_next <= 16'bX; //dont know what to do just yet
        endcase
    end
endmodule

module 
