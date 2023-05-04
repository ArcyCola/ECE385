module state_machine(	input logic Clk, Reset, enterECEB, playerDied, ZuofuDied,
                        input logic [7:0] keycode,
                        //output logic intro, map, battle
                        output logic battle, intro, map
                    );

    // start screen -> press space to go to map
    // map -> must be at certain location to go to battle

    enum logic [1:0] {  introScreen,
                        mapScreen, 
                        battleScreen, endScreen} State, Next_State;

    always_ff @ (posedge Clk)
    begin
        if (Reset) 
            //State <= introScreen;
            State <= introScreen;
        else 
            State <= Next_State;
    end

    always_comb
    begin 
        // Default next state is staying at current state
        Next_State = State;
        intro = 1'b0;
        map = 1'b0;
        battle = 1'b0;

        unique case (State)
            mapScreen:
            begin
                if(keycode == 8'h05 | enterECEB) 
                begin
                    Next_State = battleScreen;
                end
                else
                begin
                    Next_State = mapScreen;
                end
                // case (keycode)
                //     8'h2c :  Next_State = battleScreen;
                //     default : Next_State = mapScreen; 
                // endcase
            end
            battleScreen:
            begin
                if(keycode == 8'h29) // if escape is pressed go to next screen
                begin
                    Next_State = mapScreen;
                end
                else if (playerDied)
                begin
                    Next_State = introScreen;
                end
                else if (ZuofuDied)
                begin
                    Next_State = endScreen;
                end
                else
                begin
                    Next_State = battleScreen;
                end
                // case (keycode)
                //     8'h28 : Next_State = mapScreen;
                //     default : Next_State = battleScreen;
                // endcase
            end
            introScreen:
            begin
                if (keycode == 8'h2c) // if spacebar is pressed, go to next screen
                begin
                    Next_State = mapScreen;
                end
                else 
                begin
                    Next_State = introScreen;
                end
            end
            endScreen:
                if(keycode == 8'h28) // if escape is pressed go to next screen
                begin
                    Next_State = introScreen;
                end
                else
                begin
                    Next_State = endScreen;
                end
            //default : ; //Next_State = mapScreen;
        endcase

        case (State)
            mapScreen:
            begin
                battle = 1'b0;
                intro = 1'b0;
                map = 1'b1;
            end

            battleScreen:
            begin
                battle = 1'b1;
                intro = 1'b0;
                map = 1'b0;
            end

            introScreen:
            begin
                battle = 1'b0;
                intro = 1'b1;
                map = 1'b0;
            end

            endScreen:
            begin
                battle = 1'b0;
                intro = 1'b0;
                map = 1'b0;
            end   
            default ; //: battle = 1'b0;
        endcase
    end
endmodule

