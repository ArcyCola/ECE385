module state_machine(	input logic Clk, Reset,
                        input logic [15:0] keycode,
                        //output logic intro, map, battle
                        output logic battle
                    );

    // start screen -> press space to go to map
    // map -> must be at certain location to go to battle

    enum logic [1:0] {  //introScreen,
                        mapScreen, 
                        battleScreen} State, Next_State;

    always_ff @ (posedge Clk)
    begin
        if (Reset) 
            //State <= introScreen;
            State <= mapScreen;
        else 
            State <= Next_State;
    end

    always_comb
    begin 
        // Default next state is staying at current state
        Next_State = State;
        // intro = 1'b0;
        // map = 1'b0;
        battle = 1'b0;

        unique case (State)
            mapScreen:
                if(keycode == 16'h002c) // if spacebar is pressed, go to next screen
                Next_State = battleScreen;

            battleScreen:
                if(keycode == 16'h0028)
                Next_State = mapScreen;
            default : Next_State = mapScreen;
        endcase

        case (State)
            mapScreen:
            begin
                battle = 1'b0;
            end

            battleScreen:
            begin
                battle = 1'b1;
            end
            default : battle = 1'b0;
        endcase
    end
endmodule
