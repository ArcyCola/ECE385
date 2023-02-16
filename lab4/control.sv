module control (input logic Clk, Run, Reset_Load_Clear
                output logic Clr_Ld, Shift, Add, Sub )  
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


endmodule