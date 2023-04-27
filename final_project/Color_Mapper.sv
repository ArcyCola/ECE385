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


module  color_mapper ( input        [9:0]  DrawX, DrawY, 
                       input               blank, vga_clk, Reset, frame_clk, ball_reset,
                       input        [15:0] keycode,
                       output logic [7:0]  Red, Green, Blue );
    
   
	 
    /*  New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
      this single line is quite powerful descriptively, it causes the synthesis tool to use up three
      of the 12 available multipliers on the chip!  Since the multiplicants are required to be signed,
	  we have to first cast them from logic to int (signed by default) before they are multiplied). */

	logic ball_on, GBAWindow, isBallCenter, isWinOnAnyEdge, isWinOnLeftEdge, isWinOnRightEdge, isWinOnTopEdge, isWinOnBottomEdge;  
	logic isWinOnTopLeftCorner, isWinOnTopRightCorner, isWinOnBottomLeftCorner, isWinOnBottomRightCorner, isWinOnAnyCorner;
    int DistX, DistY;
	

	// ------------------------------------------------
    // adding stuff for background fjdguidgnfdm

    logic signed [18:0] rom_address;
    logic [3:0] rom_q;

    logic [3:0] palette_red, palette_green, palette_blue;

    logic signed [10:0] GBADraw2X, GBADraw2Y;

    logic negedge_vga_clk;
    
    assign negedge_vga_clk = ~vga_clk;



    // ------------------------------------------------
	// copied from ball.sv

	logic [9:0] BallX, Ball_X_Motion, BallY, Ball_Y_Motion;
	 
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=100;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=539;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=100;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=379;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis

    assign BallS = 4;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   

   //--------------------------------------

    // following how ball moves, referencing ball.sv
    // "Screen" is the 160x140 window that is outputted to the screen.
    // location of top left corner of screen.
    int ScreenX, ScreenY;

    //setting min and max of top left pixel of screen, relative to map
    //map size of 480x320
	 int Screen_X_Min = -30;
    int Screen_Y_Min = -30;
    parameter [9:0] Screen_X_Max = 269;
    parameter [9:0] Screen_Y_Max = 189;

	// creating constants for map when it is at a wall
	parameter [9:0] MapXover4 = 119;
	parameter [9:0] MapX3over4 = 359;
	parameter [9:0] MapYover4 = 79;
	parameter [9:0] MapY3over4 = 239;
    // idk if like we have to follow how ball does it, how
    // each case for keycode defines X/Y motion, then changing 
    // it outside of the huge if/else statement.
    logic [9:0] Screen_X_Motion, Screen_Y_Motion;

    //  not sure if we need step, used for bouncing off screen
    //  for ball.
    parameter [9:0] Screen_X_Step = 1; 
    parameter [9:0] Screen_Y_Step = 1; 
	 
	 assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;

	 logic GBADraw2XBound, GBADraw2YBound;
	 //comment this out when u use the always_ff 
	 // ahhhhh read read
	  assign BallY = Ball_Y_Center;
	  assign BallX = Ball_X_Center;
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
        
		isBallCenter = (BallX == Ball_X_Center) & (BallY == Ball_Y_Center);

		GBADraw2XBound = (0 <= GBADraw2X) & (GBADraw2X < 960);
		GBADraw2YBound = (0 <= GBADraw2Y) & (GBADraw2Y < 640);
		
		// logic for determining if screen window is on edge of map
		isWinOnLeftEdge = (ScreenX <= Screen_X_Min); 
		isWinOnRightEdge = (ScreenX >= Screen_X_Max);
		isWinOnTopEdge = (ScreenY <= Screen_Y_Min);
		isWinOnBottomEdge = (ScreenY >= Screen_Y_Max);
		// logic for determining if screen window is on a specific corner edge of map
		isWinOnTopLeftCorner = isWinOnTopEdge & isWinOnLeftEdge;
		isWinOnTopRightCorner = isWinOnTopEdge & isWinOnRightEdge;
		isWinOnBottomLeftCorner = isWinOnBottomEdge & isWinOnLeftEdge;
		isWinOnBottomRightCorner = isWinOnBottomEdge & isWinOnRightEdge;
		// logic for determining if screen window is on a corner
		isWinOnAnyCorner = isWinOnTopLeftCorner | isWinOnTopRightCorner | isWinOnBottomLeftCorner | isWinOnBottomRightCorner;
		//all inclusive case sdjigfdjosjbfjdoisjg
		isWinOnAnyEdge = isWinOnLeftEdge | isWinOnRightEdge | isWinOnTopEdge | isWinOnBottomEdge;  

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
				if (ScreenX < Screen_X_Min) begin
                ScreenX <= Screen_X_Min;
            end
            else if (ScreenX > Screen_X_Max) begin
                ScreenX <= Screen_X_Max;
            end
            // if ScreenX is at max
				else if (ScreenY < Screen_Y_Min) begin
					ScreenY <= Screen_Y_Min;
				end
				else if (ScreenY > Screen_Y_Max) begin
					ScreenY <= Screen_Y_Max;
				end
            //might be able to combine the min/max checks into one if thing
            	else 
				begin
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

    //ball/sprite logic
//	always_ff @ (posedge Reset or posedge frame_clk or posedge ball_reset)
//    begin: Move_Ball
//        if (Reset)  // Asynchronous Reset
//        begin 
//            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
//			Ball_X_Motion <= 10'd0; //Ball_X_Step;
//			BallY <= Ball_Y_Center;
//			BallX <= Ball_X_Center;
//        end
//		  else if (ball_reset)
//		  begin 
//			BallY <= Ball_Y_Center;
//			BallX <= Ball_X_Center;
//		  end
//        else 
//        begin 
//				 if (isWinOnAnyEdge)
//				 begin
//					  Ball_Y_Motion <= Ball_Y_Motion;  // Ball is somewhere in the middle, don't bounce, just keep moving
//					  Ball_X_Motion <= Ball_X_Motion;
//				 case(keycode)
//					// two key press
//					16'h041A : begin	// A and W
//							Ball_Y_Motion <= -1; //W
//							Ball_X_Motion <= -1; // A
//							 end
//					16'h1A04 : begin	// W and A
//							Ball_Y_Motion <= -1; // W
//							Ball_X_Motion <= -1; // A
//							 end
//					16'h071A : begin // D and W
//					        Ball_X_Motion <= 1;//D
//							Ball_Y_Motion <= -1; // W
//							  end		 
//					16'h1A07 : begin // W and S
//					        Ball_X_Motion <= 1;//D
//							Ball_Y_Motion <= -1; // W
//							  end
//					16'h1607 : begin // S and D
//					        Ball_X_Motion <= 1;
//							Ball_Y_Motion <= 1;
//							  end
//					16'h0716 : begin // D and S
//					        Ball_X_Motion <= 1;
//							Ball_Y_Motion <= 1;
//							  end
//					16'h1604 : begin //S and A
//								Ball_X_Motion <= -1;
//								Ball_Y_Motion<= 1;
//							  end
//					16'h0416 : begin //A and S
//								Ball_X_Motion <= -1;
//								Ball_Y_Motion<= 1;
//							  end
//				 	// one key press
//				 	16'h0004 : begin //A
//								if(((isWinOnLeftEdge) & (BallX > Ball_X_Min)) | ((isWinOnRightEdge) & (BallX < Ball_X_Max)))
//									Ball_X_Motion <= -1;
//									//Ball_Y_Motion<= 0;
//								else if(BallX == Ball_X_Center)
//									Ball_X_Motion <= 0;
//								else 
//									Ball_X_Motion <= 0;
//							  end
//					16'h0007 : begin // D
//								if(((isWinOnRightEdge) & (BallX < Ball_X_Max)) | ((isWinOnLeftEdge) & (BallX > Ball_X_Min)))
//									Ball_X_Motion <= 1;
//									//Ball_Y_Motion <= 0;
//								else if(BallX == Ball_X_Center)
//									Ball_X_Motion <= 0;
//								else 
//									Ball_X_Motion <= 0;
//							  end
//					16'h0016 : begin //S
//							if((isWinOnBottomEdge) & (BallY < Ball_Y_Max))
//								Ball_Y_Motion <= 1;
//								//Ball_X_Motion <= 0;
//							end
//					16'h001A : begin //W
//					        Ball_Y_Motion <= -1;
//							  //Ball_X_Motion <= 0;
//							 end
//            		default: begin
//						Ball_X_Motion <= 0;
//						Ball_Y_Motion <= 0;
//					end
//				 endcase
//				end 
//				else if ( (BallY) > Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
//				 begin
//					  BallY <= Ball_Y_Max;  // 2's complement.
//					  Ball_Y_Motion <= 0;
//				  end
//				 else if ( (BallY) < Ball_Y_Min )  // Ball is at the top edge, BOUNCE!
//				 begin
//					  BallY <= Ball_Y_Min;
//					  Ball_Y_Motion <= 0;
//				  end
//				  else if ( (BallX) > Ball_X_Max )  // Ball is at the Right edge, BOUNCE!
//				  begin
//					  BallX <= Ball_X_Max;  // 2's complement.
//					  Ball_X_Motion <= 0;
//				  end
//				 else if ( (BallX) < Ball_X_Min )  // Ball is at the Left edge, BOUNCE!
//				 begin
//					  BallX <= Ball_X_Min;
//					  Ball_X_Motion <= 0;
//				 end
//				 else 
//				 begin
//						Ball_X_Motion <= 0;
//						Ball_Y_Motion <= 0;
//				 end
//				 BallY <= (BallY + Ball_Y_Motion);  // Update ball position
//				 BallX <= (BallX + Ball_X_Motion);
//		end  
//    end

	//drawing on screen
    always_ff @ (posedge vga_clk)
    begin:RGB_Display
		if (blank) begin
			  if ((ball_on == 1'b1)) 
			  begin  // drawing ball
					Red <= 8'hff;
					Green <= 8'h55;
					Blue <= 8'h00;
			  end
			  else if (GBAWindow & (GBADraw2XBound & GBADraw2YBound ))
			  begin // drawing background
					Red <= {palette_red, 4'b0};
					Green <= {palette_green, 4'b0};
					Blue <= {palette_blue, 4'b0};
			  end
//			  else if (!(GBADraw2XBound & GBADraw2YBound ))
//			  begin
//				 Red <= 8'hFF;
//					Green <= 8'h00;
//					Blue <= 8'h00;
//			  end
              else begin
                    Red <= 8'h00;
					Green <= 8'h00;
					Blue <= 8'h00;
              end
		 end
			
    end 

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
