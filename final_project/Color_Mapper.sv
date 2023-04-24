//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input        [9:0]  BallX, BallY, DrawX, DrawY, Ball_size,
                       input               blank, vga_clk, Reset, frame_clk,
                       input        [15:0] keycode,
                       output logic [7:0]  Red, Green, Blue );
    
   
	 
    /*  New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
      this single line is quite powerful descriptively, it causes the synthesis tool to use up three
      of the 12 available multipliers on the chip!  Since the multiplicants are required to be signed,
	  we have to first cast them from logic to int (signed by default) before they are multiplied). */

	logic ball_on, GBAWindow;  
    int DistX, DistY, Size;
	assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
    assign Size = Ball_size;
	// ------------------------------------------------
    // adding stuff for background fjdguidgnfdm

    logic [17:0] rom_address;
    logic [3:0] rom_q;

    logic [3:0] palette_red, palette_green, palette_blue;

    logic [9:0] GBADraw2X, GBADraw2Y;

    logic negedge_vga_clk;
    
    assign negedge_vga_clk = ~vga_clk;



    // ------------------------------------------------
    // following how ball moves, referencing ball.sv
    // "Screen" is the 160x140 window that is outputted to the screen.
    // location of top left corner of screen.
    logic signed [9:0] ScreenX, ScreenY;

    //setting min and max of top left pixel of screen, relative to map
    //map size of 480x320
    parameter [9:0] Screen_X_Min = 0;
    parameter [9:0] Screen_Y_Min = 0;
    parameter [9:0] Screen_X_Max = 239;
    parameter [9:0] Screen_Y_Max = 159;
    // idk if like we have to follow how ball does it, how
    // each case for keycode defines X/Y motion, then changing 
    // it outside of the huge if/else statement.
    logic [9:0] Screen_X_Motion, Screen_Y_Motion;

    //  not sure if we need step, used for bouncing off screen
    //  for ball.
    parameter [9:0] Screen_X_Step = 1; 
    parameter [9:0] Screen_Y_Step = 1; 

    //intializing ScreenX/Y to top left corner of map, can change later.
    // assign ScreenX = 1'b0;
    // assign ScreenY = 1'b0; 

    always_comb
    begin:Ball_on_proc
        if ( ((-6 <= DistX) & (DistX <= 6) & ((-10 <= DistY) & (DistY <= 10))  ) ) 
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;

        //-----------------------------
        //GBA screen implemenations
        GBAWindow = (80 <= DrawX) & (DrawX < 560) & (80 <= DrawY) & (DrawY < 400);
        
        //no scrolling, static background code
        // GBADraw2X = DrawX - 80; // GBADraw2X = [0, 480]
        // GBADraw2Y = DrawY - 80; // GBADraw2Y = [0, 320]

        //scrolling implemention
        GBADraw2X = DrawX - 80 + (ScreenX * 2);
        GBADraw2Y = DrawY - 80 + (ScreenY * 2);

        // address into the rom = (x* xDim ) / 480 + ((y * yDim) / 320) * xDim
        //rom = (GBADraw2x* ImageXDim ) / ScreenWidth + ((GBADraw2Y* ImageYDim) / ScreenHeight) * ScreenWidth

        // for the pokemon firered map 1x 
        //rom_address = ((GBADraw2X * 240) / 480) + (((GBADraw2Y * 160) / 320) * 240);
        // ---------------------------------------------
        // for the pokemon firered map 2x/northwquaddraft 
		  // Drawing full map on it
        //rom_address = GBADraw2X + (GBADraw2Y * 480);
		  
		  //---------------------------
		  // res; 480 x 320, want to see top right 240x160 part
		  rom_address = (GBADraw2X / 2) + ((GBADraw2Y/2) * 480);
		  
		  //---------------------------
		  // res; 960 x 640, want to see top right 240x160 part
		  //rom_address = (GBADraw2X / 4) + ((GBADraw2Y/4) * 960);
        
    end 


    //need keycode and maybe Reset if we want to implement Reset to screen,
    // if we do implement Reset comment out lines 73-74 (the assign ScreenX/Y)
    always_ff @ (posedge frame_clk or posedge Reset)
    begin: Move_Screen
        if (Reset) begin
		  // begin a
            ScreenX <= 10'b0;
            ScreenY <= 10'b0;
        end
        else begin
				//checking if ScreenX is at min. (unsigned -1 == 10'bFFF)
				if (ScreenX == 10'hFFF) begin
                ScreenX <= 0;
            end
            else if (ScreenX > Screen_X_Max) begin
                ScreenX <= 239;
            end
            // if ScreenX is at max
				else if (ScreenY == 10'hFFF) begin
					ScreenY <= 0;
				end
				else if (ScreenY > Screen_Y_Max) begin
					ScreenY <= 159;
				end
            //might be able to combine the min/max checks into one if thing
            else begin
                Screen_X_Motion <= Screen_X_Motion;

                //adding all these if's in the cases might make all the if's above redundant
                case (keycode)
                    // A, going to the left
                    16'h0004 : begin
                        if (ScreenX <= Screen_X_Min) begin
                            Screen_X_Motion <= 0;
                        end
                        else begin
                            Screen_X_Motion <= -1;
                        end
                    end
                    // D, going right
                    16'h0007 : begin
                        if (ScreenX >= Screen_X_Max) begin
                            Screen_X_Motion <= 0;
                        end
                        else begin
                            Screen_X_Motion <= 1;
                        end
                    end
						  // W, up
                    16'h001A : begin
                        if (ScreenY <= Screen_Y_Min) begin
                            Screen_Y_Motion <= 0;
                        end
                        else begin
                            Screen_Y_Motion <= -1;
                        end
                    end
                    // S, down
                    16'h0016 : begin
                        if (ScreenY >= Screen_Y_Max) begin
                            Screen_Y_Motion <= 0;
                        end
                        else begin
                            Screen_Y_Motion <= 1;
                        end
							end	
							
							// 2 key presses
							
						  // W, A, up, left
						  16'h1A04 : begin
								if((ScreenX <= Screen_X_Min) & (ScreenY <= Screen_Y_Min)) begin
									Screen_X_Motion <= 0;
									Screen_Y_Motion <= 0;
								end
								if((ScreenX <= Screen_X_Min) & (ScreenY <= Screen_Y_Min)) begin
									Screen_X_Motion <= 0;
									Screen_Y_Motion <= -1;
								end
								if(!(ScreenX <= Screen_X_Min) & (ScreenY <= Screen_Y_Min)) begin
									Screen_X_Motion <= -1;
									Screen_Y_Motion <= 0;
								end
								else begin
									Screen_X_Motion <= -1;
									Screen_Y_Motion <= -1;
								end
							end
							// A, W, left, up
							16'h041A : begin
								if((ScreenX <= Screen_X_Min) & (ScreenY <= Screen_Y_Min)) begin
									Screen_X_Motion <= 0;
									Screen_Y_Motion <= 0;
								end
								if((ScreenX <= Screen_X_Min) & !(ScreenY <= Screen_Y_Min)) begin
									Screen_X_Motion <= 0;
									Screen_Y_Motion <= -1;
								end
								if(!(ScreenX <= Screen_X_Min) & (ScreenY <= Screen_Y_Min)) begin
									Screen_X_Motion <= -1;
									Screen_Y_Motion <= 0;
								end
								else begin
									Screen_X_Motion <= -1;
									Screen_Y_Motion <= -1;
								end
                    end
						  // W, D, up, right
						  16'h1A07 : begin
								if((ScreenX >= Screen_X_Max) & (ScreenY <= Screen_Y_Min)) begin
									Screen_X_Motion <= 0;
									Screen_Y_Motion <= 0;
								end
								if((ScreenX >= Screen_X_Max) & !(ScreenY <= Screen_Y_Min)) begin
									Screen_X_Motion <= 0;
									Screen_Y_Motion <= -1;
								end
								if(!(ScreenX >= Screen_X_Max) & (ScreenY <= Screen_Y_Min)) begin
									Screen_X_Motion <= 1;
									Screen_Y_Motion <= 0;
								end
								else begin
									Screen_X_Motion <= 1;
									Screen_Y_Motion <= -1;
								end
							end
							// D,W, right, up
						  16'h071A : begin
								if((ScreenX >= Screen_X_Max) & (ScreenY <= Screen_Y_Min)) begin
									Screen_X_Motion <= 0;
									Screen_Y_Motion <= 0;
								end
								if((ScreenX >= Screen_X_Max) & !(ScreenY <= Screen_Y_Min)) begin
									Screen_X_Motion <= 0;
									Screen_Y_Motion <= -1;
								end
								if(!(ScreenX >= Screen_X_Max) & (ScreenY <= Screen_Y_Min)) begin
									Screen_X_Motion <= 1;
									Screen_Y_Motion <= 0;
								end
								else begin
									Screen_X_Motion <= 1;
									Screen_Y_Motion <= -1;
								end
							end
							
							// D, S, right, down
							16'h0716 : begin
								if((ScreenX >= Screen_X_Max) & (ScreenY >= Screen_Y_Max)) begin
									Screen_X_Motion <= 0;
									Screen_Y_Motion <= 0;
								end
								if((ScreenX >= Screen_X_Max) & !(ScreenY >= Screen_Y_Max)) begin
									Screen_X_Motion <= 0;
									Screen_Y_Motion <= 1;
								end
								if(!(ScreenX >= Screen_X_Max) & (ScreenY >= Screen_Y_Max)) begin
									Screen_X_Motion <= 1;
									Screen_Y_Motion <= 0;
								end
								else begin
									Screen_X_Motion <= 1;
									Screen_Y_Motion <= 1;
								end
							end
							// S, D, down, right
							16'h1607 : begin
								if((ScreenX >= Screen_X_Max) & (ScreenY >= Screen_Y_Max)) begin
									Screen_X_Motion <= 0;
									Screen_Y_Motion <= 0;
								end
								if((ScreenX >= Screen_X_Max) & !(ScreenY >= Screen_Y_Max)) begin
									Screen_X_Motion <= 0;
									Screen_Y_Motion <= 1;
								end
								if(!(ScreenX >= Screen_X_Max) & (ScreenY >= Screen_Y_Max)) begin
									Screen_X_Motion <= 1;
									Screen_Y_Motion <= 0;
								end
								else begin
									Screen_X_Motion <= 1;
									Screen_Y_Motion <= 1;
								end
							end
							// S, A, down, left
							16'h1604 : begin
								if((ScreenX <= Screen_X_Min) & (ScreenY >= Screen_Y_Max)) begin
									Screen_X_Motion <= 0;
									Screen_Y_Motion <= 0;
								end
								if((ScreenX <= Screen_X_Min) & !(ScreenY >= Screen_Y_Max)) begin
									Screen_X_Motion <= 0;
									Screen_Y_Motion <= 1;
								end
								if(!(ScreenX <= Screen_X_Min) & (ScreenY >= Screen_Y_Max)) begin
									Screen_X_Motion <= -1;
									Screen_Y_Motion <= 0;
								end
								else begin
									Screen_X_Motion <= -1;
									Screen_Y_Motion <= 1;
								end
							end
							// A, S, left, down
							16'h1604 : begin
								if((ScreenX <= Screen_X_Min) & (ScreenY >= Screen_Y_Max)) begin
									Screen_X_Motion <= 0;
									Screen_Y_Motion <= 0;
								end
								if((ScreenX <= Screen_X_Min) & !(ScreenY >= Screen_Y_Max)) begin
									Screen_X_Motion <= 0;
									Screen_Y_Motion <= 1;
								end
								if(!(ScreenX <= Screen_X_Min) & (ScreenY >= Screen_Y_Max)) begin
									Screen_X_Motion <= -1;
									Screen_Y_Motion <= 0;
								end
								else begin
									Screen_X_Motion <= -1;
									Screen_Y_Motion <= 1;
								end
							end
                    default: begin
                        Screen_X_Motion <= 0;
                        Screen_Y_Motion <= 0;   
                    end
                endcase
                ScreenX <= (ScreenX + Screen_X_Motion);
                ScreenY <= (ScreenY + Screen_Y_Motion);
            end
        end
    end
    

    always_ff @ (posedge vga_clk)
    begin:RGB_Display
		if (blank) begin
			  if ((ball_on == 1'b1)) 
			  begin  // drawing ball
					Red <= 8'hff;
					Green <= 8'h55;
					Blue <= 8'h00;
			  end
			  else if (GBAWindow)
			  begin // drawing background
					Red <= {palette_red, 4'b0};
                    Green <= {palette_green, 4'b0};
		            Blue <= {palette_blue, 4'b0};
			  end
              else begin
                    Red <= 8'h00;
					Green <= 8'h00;
					Blue <= 8'h00;
              end
//              if ( ((10'h4f) <= DrawX <= (10'h22f)) | ((10'h4f) <= DrawY <= (10'h18f)) ) begin
//                    Red = 8'h00; 
//						Green = 8'h00;
//						Blue = 8'h00;
//              end
		 end
		//  else
		//  begin
		// 	Red = 8'h00; 
		// 	Green = 8'h00;
		// 	Blue = 8'h00;
		//  end
			
    end 
    
// pokemonfireredmap_rom pokemonfireredmap_rom (
// 	.clock   (negedge_vga_clk),
// 	.address (rom_address),
// 	.q       (rom_q)
// );

// pokemonfireredmap_palette pokemonfireredmap_palette (
// 	.index (rom_q),
// 	.red   (palette_red),
// 	.green (palette_green),
// 	.blue  (palette_blue)
// );



//fpmapdraft2_rom northquaddraft_rom (
//	.clock   (negedge_vga_clk),
//	.address (rom_address),
//	.q       (rom_q)
//);
//
//fpmapdraft2_palette northquaddraft_palette (
//	.index (rom_q),
//	.red   (palette_red),
//	.green (palette_green),
//	.blue  (palette_blue)
//);

fpmapfinal_rom map480_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address),
	.q       (rom_q)
);

fpmapfinal_palette map480_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

endmodule
