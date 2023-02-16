module control (input logic Clk, Run, Reset_Load_Clear, M
                output logic Clr_Ld, Shift, fn )  
        //module for the FSM of the multiplier
    enum logic [4:0] {Start, L1, S1, L2, S2, L3, S3, L4, S4, J} curr_state, next_state;
    
    //copied from lab 2.2 vv
    always_ff @ (posedge Clk)
    begin
        if (Reset)
            curr_state <= Start;
        else 
            curr_state <= next_state;
    end

    always_comb
    begin

        next_state  = curr_state;	//required because S4 haven't enumerated all possibilities below
        unique case (curr_state) 

            Start :    if (Run) //1
                    next_state = L1;
            L1 :      next_state = S1; //LOAD
            S1 :      next_state = L2; //SHIFT
            L2 :      next_state = S2;
            S2 :      next_state = L3;
            L3 : 	 next_state = S3;		// added for the 4 additional states
            S3 : 	 next_state = L4;
            L4 : 	 next_state = S4;
            S4 : 	 next_state = J;
            K :
            R :    if (~Run) 
                    next_state = Start;
                            
        endcase
        //assign outputs based on state
        case (curr_state)   
            Start: 
                begin  
                    Clr_Ld = Reset_Load_Clear; //output = input
                    Shift = 1'b0;
                end
            J:  //end state, not finalized to J
                begin
                    if (M)
                        fn = 1'b1;
                    else   
                        fn = 1'b0;
                end
            default: //default case, lets say b-before R
                begin
                        fn = 1'b0;
                        Clr_Ld = 1'b0;
                end
        endcase

    end 
endmodule



    