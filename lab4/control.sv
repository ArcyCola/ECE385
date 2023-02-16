module control (input logic Clk, Run, Reset_Load_Clear, M
                output logic Clr_Ld, Shift, fn )  
        //module for the FSM of the multiplier
    enum logic [4:0] {Start, L1, S1, L2, S2, L3, S3, L4, S4, L5, S5, L6, S6, L7, S7, L8, S8, Comp} curr_state, next_state;
    
    //copied from lab 2.2 vv
    always_ff @ (posedge Clk)
    begin
        if (Reset_Load_Clear)
            curr_state <= Start;
        else 
            curr_state <= next_state;
    end

    always_comb
    begin

        next_state  = curr_state;	//required because S4 haven't enumerated all possibilities below
        unique case (curr_state) 

            Start :    if (Run) //1
                    next_state = CAX; // clear registers A and X
            CAX:    next_state = L1;
            L1 :     next_state = S1; //LOAD
            S1 :     next_state = L2; //SHIFT
            L2 :     next_state = S2;
            S2 :     next_state = L3;
            L3 : 	 next_state = S3;
            S3 : 	 next_state = L4;
            L4 : 	 next_state = S4;
            S4 : 	 next_state = L5;
            L5 :     next_state = S5;
            S5 :     next_state = L6;
            L6 :     next_state = S6;
            S6 :     next_state = L7;
            L7 :     next_state = S7;
            S7 :     next_state = L8;
            L8 :     next_state = S8;
            S8 :     next_state = Comp;
            Comp :    if (~Run) 
                    next_state = Start;
                            
        endcase
        //assign outputs based on state
        case (curr_state)   
            Start: //start state
                begin  
                    Clr_Ld = Reset_Load_Clear; //output = input
                    Shift = 1'b0;
                    fn = 1'b0;
                end
            CAX: //clear a and x
                begin 
                    Clr_Ld = 1'b1;
                    Shift = 1'b0;
                    fn = 1'b0;
                end
            L1, L2, L3, L4, L5, L6, L7: 
                begin
                    Clr_Ld = 1'b1;
                    Shift = 1'b0;
                    fn = 1'b0;
                end
            S1, S2, S3, S4, S5, S6, S7, S8:
                begin
                    Clr_Ld = 1'b0;
                    Shift = 1'b1;
                    fn = 1'b0;
                end
            L8:  // only different load/add state
                begin
                    Clr_Ld = 1'b0;
                    Shift = 1'b0;
                    if (M)
                        fn = 1'b1;
                    else   
                        fn = 1'b0;
                end
            Comp: //end state, stops everything
                begin
                        fn = 1'b0;
                        Clr_Ld = 1'b0;
                        Shift = 1'b0;
                end
        endcase
    end 
endmodule



    