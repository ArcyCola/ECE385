module battle (input [7:0] keycode,
               input vga_clk, frame_clk, blank, debug, Reset, battle, intro,
               input logic signed [10:0] GBADraw2X, GBADraw2Y,
               output [3:0] Red, Green, Blue);

    logic move;

    logic [17:0] rom_address;
    logic [3:0] rom_q;

    logic [3:0] red_battle, blue_battle, green_battle;

    logic negedge_vga_clk;

    // read from ROM on negedge, set pixel on posedge
    assign negedge_vga_clk = ~vga_clk;

    assign rom_address = (GBADraw2X) + ((GBADraw2Y) * 480);

    //move is to determine who's move, 0 = player, 1 = zuofu
//    assign move = 0;

    //since width of the bar is 94,,, might as well just so its simpler.
    //logic signed [10:0] AEHealth, ZuofuHealth, AEHealthBarStart, ZuofuHealthBarStart;
    int AEDamage, ZuofuDamage, AEHealth, ZuofuHealth;
    
    // assign AEHealth = 94;
//    assign ZuofuHealth = 94;
    // assign AEHealthBarStart = 349;
    // assign ZuofuHealthBarStart = w
    logic AEHealthBar, ZuofuHealthBar;


always_ff @ (posedge frame_clk or posedge Reset or posedge debug)
begin
	if (Reset)
    begin
		ZuofuHealth <= 94;
        AEHealth <= 94;
        move <= 0;
    end
	else if (debug)
		ZuofuHealth <= ZuofuHealth - 4;
	else if (move) //move == 1 = zuofu
    begin
        AEHealth <= AEHealth - 8;
        move <= 0;
    end
    else 
        if (~move) 
        begin
            if (keycode == 8'h18)
            begin
                ZuofuHealth <= ZuofuHealth - 20;
                move <= 1;
            end
            else if (keycode == 8'h0B )
            begin
                ZuofuHealth <= ZuofuHealth - 25;
                move <= 1;
            end
            else if (keycode == 8'h0D)
            begin
                ZuofuHealth <= ZuofuHealth - 8;
                move <= 1;
            end
            else if (keycode == 8'h0F)
            begin
                ZuofuHealth <= ZuofuHealth - 12;
                move <= 1;
            end
            else if (keycode == 8'h11)
            begin
                ZuofuHealth <= ZuofuHealth;
                move <= 1;
            end
            else
            begin
                move <= 0;
            end
        end
end

//     enum logic [3:0] {Zuofu, AE, notInBattle,
//                      ZuofuCalc, AECalc, AEWait} State, Next_State;

//     always_ff @ (posedge frame_clk)
//     begin
//         if (Reset | keycode == 8'h29)
// 			begin
//             //State <= introScreen;
//             State <= notInBattle;
//             AEHealth <= 94;
//             ZuofuHealth <= 94;
// 			end
//         else 
//             State <= Next_State;
//             // ZuofuHealth <= ZuofuHealth - ZuofuDamage;
//             // AEHealth <= AEHealth - AEDamage;   
//     end

// //	always_comb 
// //    begin
// //        AEHealth = AEHealth - AEDamage;
// //        ZuofuHealth = ZuofuHealth - ZuofuDamage;
// //    end

//     always_comb 
//     begin
//         //initializing numbers
//         Next_State = State; 
//        ZuofuDamage = 0;
//        AEDamage = 0;
// 			// 	AEHealth = 94;
// 			// ZuofuHealth = 94;

//         unique case (State)
//             notInBattle :
//                 if (battle)
//                     Next_State = AEWait;
//                 else
//                     Next_State = notInBattle;
//             AEWait:
//             begin
//                 if (~keycode) //if nothing from keycode,
//                     Next_State = AEWait;
//                 else
//                     Next_State = AE;
//             end
//             AE:
//             begin
//                 case (keycode)
//                     8'h18 : Next_State = ZuofuCalc; //U
//                     8'h0B : Next_State = ZuofuCalc; //H
//                     8'h0D : Next_State = ZuofuCalc; //J
//                     8'h0F : Next_State = ZuofuCalc; //F
//                     8'h11 : Next_State = ZuofuCalc; //N
//                     default : Next_State = AEWait;
//                 endcase
//             end
//             ZuofuCalc:
//             begin
//                 Next_State = Zuofu;
//             end
//             Zuofu:
//             begin
//                 Next_State = AECalc;
//             end
//             AECalc: 
//             begin
//                 Next_State = AEWait;
//             end
// 				default: Next_State = notInBattle;
//         endcase

//         case (State)
//             notInBattle: ;
//         //    begin 
// //                AEHealth = 94;
// //                ZuofuHealth = 94;
// 					//  ZuofuDamage = 0;
// 					//  AEDamage = 0;
//            // end
//             AEWait: ;
//             AE:
//             begin
//                 case (keycode)
//                     8'h18 : ZuofuDamage = 20; //U
//                     8'h0B : ZuofuDamage = 25; //H
//                     8'h0D : ZuofuDamage = 8; //J
//                     8'h0F : ZuofuDamage = 12; //F
//                     default : ZuofuDamage = 0;
//                     // 8'h18 : ZuofuHealth <= ZuofuHealth - 20; //U
//                     // 8'h0B : ZuofuHealth <= ZuofuHealth - 25; //H
//                     // 8'h0D : ZuofuHealth <= ZuofuHealth - 8; //J
//                     // 8'h0F : ZuofuHealth <= ZuofuHealth - 12; //F
//                     // default : ZuofuHealth <= ZuofuHealth;
                    
//                 endcase
//                 // if (keycode == 8'h18)
//                 // begin
//                 //     ZuofuHealth <= ZuofuHealth - 20;
//                 // end
//                 // else if (keycode == 8'h0B )
//                 // begin
//                 //     ZuofuHealth <= ZuofuHealth - 25;
//                 // end
//                 // else if (keycode == 8'h0D)
//                 // begin
//                 //     ZuofuHealth <= ZuofuHealth - 8;
//                 // end
//                 // else if (keycode == 8'h0F)
//                 // begin
//                 //     ZuofuHealth <= ZuofuHealth - 12;
//                 // end
//                 // else 
//                 // begin
//                 //     ZuofuHealth <= ZuofuHealth;
//                 // end
//             end
//             ZuofuCalc: //;
//             begin
//                 ZuofuHealth <= ZuofuHealth - ZuofuDamage;
//             end
//             Zuofu:
//             begin
//                 AEDamage = 10;
//                 //AEHealth <= AEHealth - 10;
//             end
//             AECalc: //;
//             begin
//                 AEHealth <= AEHealth - AEDamage;
//             end
//             default: ;
//             // begin
//             //     AEDamage = 0;
//             //     ZuofuDamage = 0;
//             // end
//         endcase
//     end

    // always_ff @ (posedge keycode)
    // begin:battling 
    //     if (~move)
    //     begin

    //     end
    // end

    always_comb
    begin
        ZuofuHealthBar = (105 <= GBADraw2X) & (GBADraw2X <= (105 + ZuofuHealth)) & (67 <= GBADraw2Y) & (GBADraw2Y <= 71);
        AEHealthBar = (349 <= GBADraw2X) & (GBADraw2X <= (349 + AEHealth)) & (181 <= GBADraw2Y) & (GBADraw2Y <= 184);
    end

    //dont know if we need keycode here
    always_ff @ (posedge vga_clk) 
    begin:Drawing
        if (blank)
        begin
            Red <= red_battle;
            Green <= green_battle;
            Blue <= blue_battle;
            if (ZuofuHealthBar) 
            begin
                Red <= 4'hF;
                Green <= 4'h6;
                Blue <= 4'h4;
            end
            else if (AEHealthBar)
            begin
                Red <= 4'hF;
                Green <= 4'h6;
                Blue <= 4'h4;
        end
        end
        else
        begin
            Red <= 4'h0;
            Green <= 4'h0;
            Blue <= 4'h0;
        end
    end
	 

// testing healthbar
// always_ff @ (posedge debug or posedge Reset)
// begin
// 	if (Reset)
// 		ZuofuHealth <= 94;
// 	else if (debug)
// 		ZuofuHealth <= ZuofuHealth - 4;
// 	else
// 		ZuofuHealth <= ZuofuHealth;
// end

battledraft5_rom battledraft_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address),
	.q       (rom_q)
);

battledraft5_palette battledraft_palette (
	.index (rom_q),
	.red   (red_battle),
	.green (green_battle),
	.blue  (blue_battle)
);


endmodule