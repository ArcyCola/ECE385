module control (input logic Clk, Run, Reset_Load_Clear, M,
                output logic Clr_Ld, Shift, fn )  
        //module for the FSM of the multiplier
    enum logic [3:0] {A, B, C, D, E, F, G, H, I, J} curr_state, next_state;
    
    //copied from lab 2.2 vv
    always_ff @ (posedge Clk)
    begin
        if (Reset)
            curr_state <= A;
        else 
            curr_state <= next_state;
    end

    always_comb
    begin

        next_state  = curr_state;	//required because I haven't enumerated all possibilities below
        unique case (curr_state) 

            A :    if (Execute)
                        next_state = B;
            B :      next_state = C;
            C :      next_state = D;
            D :      next_state = E;
            E :      next_state = F;
            F : 	 next_state = G;		// added for the 4 additional states
            G : 	 next_state = H;
            H : 	 next_state = I;
            I : 	 next_state = J;
            J :    if (~Execute) 
                    next_state = A;
                            
        endcase
        //assign outputs based on state
        case (curr_state)   
            A: 
                begin  
                    Clr_Ld = Reset_Load_Clear;
                    Shift = 1'b0;
                end
            J: 
                begin
                    if (M)
                        fn = 1'b1;
                    else   
                        fn = 1'b0;
                end
            default: //default case 
                begin
                        fn = 1'b0;
                        Clr_Ld = 1'b0;



                end
        endcase

    end 
endmodule



    