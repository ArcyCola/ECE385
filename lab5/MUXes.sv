module mux2_1
    #(parameter width = 16)
    (input logic [width-1:0] In0, In1,
     input logic s,
     output logic [width-1:0] Out);

     always_comb 
     begin 
        if (s)
            Out = In1;
        else   
            Out = In0;

     end  
endmodule

module mux4_1
    #(parameter width = 16)
    (input logic [width-1:0] In0, In1, In2, In3,
     input logic [1:0] s,
     output logic [width-1:0] Out);

     always_comb 
     begin 
        unique case(s)
            2'b00   :   Out = In0;
            2'b01   :   Out = In1;
            2'b10   :   Out = In2;
            2'b11   :   Out = In3;
            default :   Out = 16'bX;
        endcase
     end  
endmodule