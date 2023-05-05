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
                       input               blank, vga_clk, Reset, frame_clk, debug, battle, intro, map,
                       input        [15:0] keycode,
					   output logic        enterECEB, playerDied, ZuofuDied,
                       output logic [7:0]  Red, Green, Blue );
    
   
	 
    /*  New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
      this single line is quite powerful descriptively, it causes the synthesis tool to use up three
      of the 12 available multipliers on the chip!  Since the multiplicants are required to be signed,
	  we have to first cast them from logic to int (signed by default) before they are multiplied). */

	logic sprite_on, GBAWindow;
	//, isBallCenter, isWinOnAnyEdge, isWinOnLeftEdge, isWinOnRightEdge, isWinOnTopEdge, isWinOnBottomEdge;  
	//logic isWinOnTopLeftCorner, isWinOnTopRightCorner, isWinOnBottomLeftCorner, isWinOnBottomRightCorner, isWinOnAnyCorner;
    int DistX, DistY;
	
	//logic playerDied, ZuofuDied; 

	// ------------------------------------------------
    // adding stuff for background fjdguidgnfdm

    logic [17:0] rom_address;
    logic [3:0] rom_q;

    logic [3:0] palette_red, palette_green, palette_blue;

    logic signed [10:0] GBADraw2X, GBADraw2Y, GBADraw2X0, GBADraw2Y0;

    logic negedge_vga_clk;
    
	// logic fake_ram_q;
	
	logic qX, qY;

    assign negedge_vga_clk = ~vga_clk;

	// ------------------------------------------------
    // collision
	logic [17:0] collision_rom_addr_X, collision_rom_addr_Y; //_up, collision_rom_addr_down, collision_rom_addr_left, collision_rom_addr_right;
	logic collisionX, collisionY; //collision_up, collision_down, collision_left, collision_right; // 0 = PINK, 1 = WHITE. white is walkable
	//logic q1, q2, q3, q4;
	// logic [3:0]	collision_red, collision_blue, collision_green;
	logic [10:0] collisionXCenter, collisionYCenter;
	// white = R/G/B = 4h'F, 4h'F, 4'hF WALKABLE AREAS
	// pink = R/G/B = 4h'F, 4h'0, 4'h8 NONWALKABLE AREAS	

	// ------------------------------------------------
    // title screen
	logic [17:0] titlescreen1_rom_address;
	logic titlescreen1_rom_q;
	logic [3:0] titlescreen1_red, titlescreen1_green, titlescreen1_blue;
    // ------------------------------------------------
	// copied from ball.sv

	logic [9:0] SpriteX, SpriteY, Sprite_Y_Motion;
	//logic [9:0] Sprite_X_Motion, Sprite_Y_Motion;
	 
    parameter [9:0] Sprite_X_Center=320;  // Center position on the X axis
    parameter [9:0] Sprite_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Sprite_X_Min=100;       // Leftmost point on the X axis
    parameter [9:0] Sprite_X_Max=539;     // Rightmost point on the X axis
    parameter [9:0] Sprite_Y_Min=100;       // Topmost point on the Y axis
    parameter [9:0] Sprite_Y_Max=379;     // Bottommost point on the Y axis
    parameter [9:0] Sprite_X_Step=1;      // Step size on the X axis
    parameter [9:0] Sprite_Y_Step=1;      // Step size on the Y axis

     // sprite drawing logic
    logic [3:0] sprite_red, sprite_blue, sprite_green, sprite_rom_q;
	logic [10:0] sprite_rom_addr;
	logic spriteIgnore;
	int SpriteDrawX, SpriteDrawY; 
   //--------------------------------------
	//shit cuz we have 2 roms now
	logic [3:0] red_map, blue_map, green_map, red_battle, blue_battle, green_battle, rom_q_map, rom_q_battle;
	logic [3:0] red_end, blue_end, green_end;

    // following how ball moves, referencing ball.sv
    // "Screen" is the 160x140 window that is outputted to the screen.
    // location of top left corner of screen.
    int ScreenX, ScreenY;
	
    //setting min and max of top left pixel of screen, relative to map
    //map size of 480x320

    int Screen_X_Min = -110;
    int Screen_Y_Min = -70;
    int Screen_X_Max = 350;
    int Screen_Y_Max = 230;


	// creating constants for map when it is at a wall
	parameter [9:0] MapXover4 = 119;
	parameter [9:0] MapX3over4 = 359;
	parameter [9:0] MapYover4 = 79;
	parameter [9:0] MapY3over4 = 239;
    // idk if like we have to follow how ball does it, how
    // each case for keycode defines X/Y motion, then changing 
    // it outside of the huge if/else statement.
    int Screen_X_Motion, Screen_Y_Motion;

    //  not sure if we need step, used for bouncing off screen
    //  for ball.
    parameter [9:0] Screen_X_Step = 1; 
    parameter [9:0] Screen_Y_Step = 1; 
	 
	 assign DistX = DrawX - SpriteX; 	// x distance from center of sprite
    assign DistY = DrawY - SpriteY;		// y distance from center of sprite


	logic GBADraw2XBound, GBADraw2YBound;
	//logic enterECEB;

	 //comment this out when u use the always_ff 
	 // ahhhhh read read
//	 assign SpriteY = Sprite_Y_Center;
//	 assign SpriteX = Sprite_X_Center;

    //intializing ScreenX/Y to top left corner of map, can change later.
    // assign ScreenX = 1'b0;
    // assign ScreenY = 1'b0; 


	// reg [38399:0] endregister; // endscreen: 240x160

	// initial begin
	// 	reg [38399:0] mem_data;
  	// 	$readmemb("binary_image.bin", mem_data);

	// 	// Transfer contents of memory to registers
	// 	for (int i = 0; i < 68400; i++) begin
	// 		endregister[i] = mem_data[i];
	// 	end
	// end
	
	// logic title_end_rom_q;

    always_comb
    begin:sprite_on_proc
        if ( ((-7 <= DistX) & (DistX <= 6) & ((-10 <= DistY) & (DistY <= 8))) & map) 
            sprite_on = 1'b1; // sprite: 14x19
        else 
            sprite_on = 1'b0;

		GBAWindow = (80 <= DrawX) & (DrawX < 560) & (80 <= DrawY) & (DrawY < 400); // X: [80-559] Y: [80-399]

		//drawing sprite
		SpriteDrawX = DistX + 7;
		SpriteDrawY = DistY + 10;

		
			if (keycode[7:0] == 8'h04) //if A is pressed, draw left sprite
			begin
				sprite_rom_addr = (SpriteDrawX) + ((SpriteDrawY + 19) * 28);
			end
			else if (keycode[7:0] == 8'h07) //if D is pressed, draw right sprite
			begin
				sprite_rom_addr = (SpriteDrawX + 14) + ((SpriteDrawY + 19) * 28);
			end
			else if (keycode[7:0] == 8'h1A) //if W is pressed, draw up sprite
			begin
				sprite_rom_addr = (SpriteDrawX + 14) + (SpriteDrawY * 28);
			end
			else //if S is pressed, draw down sprite.
			begin 
				sprite_rom_addr = (SpriteDrawX) + (SpriteDrawY * 28);
			end

		spriteIgnore = (sprite_red == 4'hF) & (sprite_green == 4'hC) & (sprite_blue == 4'h6);
		//spriteIgnore = (sprite_red == 4'hF) & (sprite_green == 4'hB) & (sprite_blue == 4'hF);

		GBADraw2XBound = (0 <= GBADraw2X) & (GBADraw2X < 960); // [0-959]
		GBADraw2YBound = (0 <= GBADraw2Y) & (GBADraw2Y < 640); // [0-639]

        // //-----------------------------
        // //GBA screen implemenations
        // GBAWindow = (80 <= DrawX) & (DrawX < 560) & (80 <= DrawY) & (DrawY < 400);
        
		// isBallCenter = (SpriteX == Sprite_X_Center) & (SpriteY == Sprite_Y_Center);

		// // logic for determining if screen window is on edge of map
		// isWinOnLeftEdge = (ScreenX <= Screen_X_Min); 
		// isWinOnRightEdge = (ScreenX >= Screen_X_Max);
		// isWinOnTopEdge = (ScreenY <= Screen_Y_Min);
		// isWinOnBottomEdge = (ScreenY >= Screen_Y_Max);
		// // logic for determining if screen window is on a specific corner edge of map
		// isWinOnTopLeftCorner = isWinOnTopEdge & isWinOnLeftEdge;
		// isWinOnTopRightCorner = isWinOnTopEdge & isWinOnRightEdge;
		// isWinOnBottomLeftCorner = isWinOnBottomEdge & isWinOnLeftEdge;
		// isWinOnBottomRightCorner = isWinOnBottomEdge & isWinOnRightEdge;
		// // logic for determining if screen window is on a corner
		// isWinOnAnyCorner = isWinOnTopLeftCorner | isWinOnTopRightCorner | isWinOnBottomLeftCorner | isWinOnBottomRightCorner;
		// //all inclusive case sdjigfdjosjbfjdoisjg
		// isWinOnAnyEdge = isWinOnLeftEdge | isWinOnRightEdge | isWinOnTopEdge | isWinOnBottomEdge;  

        //no scrolling, static background code
        // GBADraw2X = DrawX - 80; // GBADraw2X = [0, 480]
        // GBADraw2Y = DrawY - 80; // GBADraw2Y = [0, 320]

        //scrolling implemention
        GBADraw2X = DrawX - 80 + (ScreenX * 2);
        GBADraw2Y = DrawY - 80 + (ScreenY * 2);

		GBADraw2X0 = DrawX - 80;
		GBADraw2Y0 = DrawY - 80;

		// collision center pixel calculation
		collisionXCenter = Sprite_X_Center - 80 + (ScreenX * 2);
		collisionYCenter = Sprite_Y_Center + 8 - 80 + (ScreenY * 2);

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
		  
		  rom_address = (GBADraw2X / 2) + ((GBADraw2Y / 2) * 480); // calculating rom_address of map
			rom_q = rom_q_map;
		//collision_rom_addr = (GBADraw2X / 2) + ((GBADraw2Y / 2) * 480);	// calculating rom address of collision map
		//COLLISION CALLS TO ROM ---------------------


		
		titlescreen1_rom_address = (GBADraw2X0 / 2) + ((GBADraw2Y0 / 2) * 240);
		
		//when we tell the sprite is around the eceb door
		enterECEB = (ScreenX < -60) & (ScreenY < -30);


		collisionX = ~qX;
		collisionY = ~qY;
//		collision_down = ~q2;
//		collision_left = ~q3;
//		collision_right = ~q4;



		  if (battle)
		  begin
				// rom_address = (GBADraw2X) + ((GBADraw2Y) * 480);
				// rom_q = rom_q_battle;
				palette_red = red_battle;
				palette_green = green_battle;
				palette_blue = blue_battle;
		  end
		  else if (intro) 
		  begin
				//title_end_rom_q = titlescreen1_rom_q;
				palette_red = titlescreen1_red;
				palette_green = titlescreen1_green;
				palette_blue = titlescreen1_blue;
		  end
		  else if (map)
		  begin	
				
				palette_red = red_map;
				palette_green = green_map;
				palette_blue = blue_map;
		  end
		  else
			begin	
				//title_end_rom_q = endregister[titlescreen1_rom_address];
				palette_red = red_end;
				palette_green = green_end;
				palette_blue = blue_end;
		  end
//		  
		  //---------------------------
		  // res; 960 x 640, want to see top right 240x160 part
		  //rom_address = (GBADraw2X / 4) + ((GBADraw2Y/4) * 960);
        
    end 
	
    //need keycode and maybe Reset if we want to implement Reset to screen,
    // if we do implement Reset comment out lines 73-74 (the assign ScreenX/Y)
    always_ff @ (posedge frame_clk or posedge Reset or posedge battle or posedge intro)
    begin: Move_Screen
		//-----------------------------
        //GBA screen implemenations

//		isBallCenter = (SpriteX == Sprite_X_Center) & (SpriteY == Sprite_Y_Center);
//
//		// logic for determining if screen window is on edge of map
//		isWinOnLeftEdge = (ScreenX <= Screen_X_Min); 
//		isWinOnRightEdge = (ScreenX >= Screen_X_Max);
//		isWinOnTopEdge = (ScreenY <= Screen_Y_Min);
//		isWinOnBottomEdge = (ScreenY >= Screen_Y_Max);
//		// logic for determining if screen window is on a specific corner edge of map
//		isWinOnTopLeftCorner = isWinOnTopEdge & isWinOnLeftEdge;
//		isWinOnTopRightCorner = isWinOnTopEdge & isWinOnRightEdge;
//		isWinOnBottomLeftCorner = isWinOnBottomEdge & isWinOnLeftEdge;
//		isWinOnBottomRightCorner = isWinOnBottomEdge & isWinOnRightEdge;
//		// logic for determining if screen window is on a corner
//		isWinOnAnyCorner = isWinOnTopLeftCorner | isWinOnTopRightCorner | isWinOnBottomLeftCorner | isWinOnBottomRightCorner;
//		//all inclusive case sdjigfdjosjbfjdoisjg
//		isWinOnAnyEdge = isWinOnLeftEdge | isWinOnRightEdge | isWinOnTopEdge | isWinOnBottomEdge; 

        if (Reset | intro | battle) begin
		  // begin a
            ScreenX <= 10'b0000010000;
            ScreenY <= 10'b0;
			Screen_X_Motion <= 0;
			Screen_Y_Motion <= 0;
        end
		// else if (map) begin
		//   // begin a
        //     ScreenX <= 10'b0000010000;
        //     ScreenY <= 10'b0;
		// 	Screen_X_Motion <= 0;
		// 	Screen_Y_Motion <= 0;
        // end
        else 
		begin
				//checking if ScreenX is at min. (unsigned -1 == 10'bFFF)

				if ((ScreenX < Screen_X_Min)) begin
                ScreenX <= Screen_X_Min;
				end
				else if ((ScreenX > Screen_X_Max)) begin
					ScreenX <= Screen_X_Max;
				end
            // if ScreenX is at max
				else if ((ScreenY < Screen_Y_Min)) begin
					ScreenY <= Screen_Y_Min;
				end
				else if ((ScreenY > Screen_Y_Max)) begin
					ScreenY <= Screen_Y_Max;

				end
            //might be able to combine the min/max checks into one if thing
            	else 
				begin
		// // collision center pixel calculation
		// collisionXCenter = Sprite_X_Center - 80 + (ScreenX * 2);
		// collisionYCenter = Sprite_Y_Center + 10 - 80 + (ScreenY * 2);
					Screen_X_Motion <= Screen_X_Motion;
					Screen_Y_Motion <= Screen_Y_Motion;
                //adding all these if's in the cases might make all the if's above redundant
                	case (keycode)
						// A, going to the left
						16'h0004 : begin
							// calculate addr of left neighbor pixel
							collision_rom_addr_X = ((collisionXCenter-7)/2) + (((collisionYCenter)/2)*480);
							if ((ScreenX <= Screen_X_Min) | (collisionX)) begin
								Screen_X_Motion <= 0;
							end
							else begin
								Screen_X_Motion <= -1;
							end
						end
						// D, going right
						16'h0007 : begin
							// calculate addr of right neighbor pixel
							collision_rom_addr_X = ((collisionXCenter+6)/2) + (((collisionYCenter)/2)*480);
							if ((ScreenX >= Screen_X_Max) | (collisionX)) begin
								Screen_X_Motion <= 0;
							end
							else begin
								Screen_X_Motion <= 1;
							end
						end
							// W, up
						16'h001A : begin
							// calculate addr of top neighbor pixel
							collision_rom_addr_Y = ((collisionXCenter)/2) + (((collisionYCenter-8)/2)*480);
							if ((ScreenY <= Screen_Y_Min) | (collisionY)) begin
								Screen_Y_Motion <= 0;
							end
							else begin
								Screen_Y_Motion <= -1;
							end
						end
						// S, down
						16'h0016 : begin
							// calculate addr of bottom neighbor pixel
							collision_rom_addr_Y = ((collisionXCenter)/2) + (((collisionYCenter+8)/2)*480);
							if ((ScreenY >= Screen_Y_Max) | (collisionY)) begin
								Screen_Y_Motion <= 0;
							end
							else begin
								Screen_Y_Motion <= 1;
							end
						end		
						// 	// 2 key presses
					
						//   // W, A, up, left
						//   	16'h1A04 : begin
						// 		// calculate addr of left neighbor pixel
						// 		collision_rom_addr_X = ((collisionXCenter-7)/2) + (((collisionYCenter)/2)*480);
						// 		// calculate addr of top neighbor pixel
						// 		collision_rom_addr_Y = ((collisionXCenter-7)/2) + (((collisionYCenter-8)/2)*480);
						// 		if(((ScreenX <= Screen_X_Min) & (ScreenY <= Screen_Y_Min)) | (collisionX & collisionY)) begin
						// 			Screen_X_Motion <= 0;
						// 			Screen_Y_Motion <= 0;
						// 		end
						// 		if(((ScreenX <= Screen_X_Min) & !(ScreenY <= Screen_Y_Min)) | (collisionX & !collisionY)) begin
						// 			Screen_X_Motion <= 0;
						// 			Screen_Y_Motion <= -1;
						// 		end
						// 		if((!(ScreenX <= Screen_X_Min) & (ScreenY <= Screen_Y_Min)) | (!collisionX & collisionY)) begin
						// 			Screen_X_Motion <= -1;
						// 			Screen_Y_Motion <= 0;
						// 		end
						// 		else begin
						// 			Screen_X_Motion <= -1;
						// 			Screen_Y_Motion <= -1;
						// 		end
						// 	end
						// 	// A, W, left, up
						// 	16'h041A : begin
						// 		// calculate addr of left neighbor pixel
						// 		collision_rom_addr_X = ((collisionXCenter-7)/2) + (((collisionYCenter)/2)*480);
						// 		// calculate addr of top neighbor pixel
						// 		collision_rom_addr_Y = ((collisionXCenter-7)/2) + (((collisionYCenter-8)/2)*480);
						// 		if(((ScreenX <= Screen_X_Min) & (ScreenY <= Screen_Y_Min)) | (collisionX & collisionY)) begin
						// 			Screen_X_Motion <= 0;
						// 			Screen_Y_Motion <= 0;
						// 		end
						// 		if(((ScreenX <= Screen_X_Min) & !(ScreenY <= Screen_Y_Min)) | (collisionX & !collisionY)) begin
						// 			Screen_X_Motion <= 0;
						// 			Screen_Y_Motion <= -1;
						// 		end
						// 		if((!(ScreenX <= Screen_X_Min) & (ScreenY <= Screen_Y_Min)) | (!collisionX & collisionY)) begin
						// 			Screen_X_Motion <= -1;
						// 			Screen_Y_Motion <= 0;
						// 		end
						// 		else begin
						// 			Screen_X_Motion <= -1;
						// 			Screen_Y_Motion <= -1;
						// 		end
                    	// 	end
						//   // W, D, up, right
						//   	16'h1A07 : begin
						// 		if((ScreenX >= Screen_X_Max) & (ScreenY <= Screen_Y_Min)) begin
						// 			Screen_X_Motion <= 0;
						// 			Screen_Y_Motion <= 0;
						// 		end
						// 		if((ScreenX >= Screen_X_Max) & !(ScreenY <= Screen_Y_Min)) begin
						// 			Screen_X_Motion <= 0;
						// 			Screen_Y_Motion <= -1;
						// 		end
						// 		if(!(ScreenX >= Screen_X_Max) & (ScreenY <= Screen_Y_Min)) begin
						// 			Screen_X_Motion <= 1;
						// 			Screen_Y_Motion <= 0;
						// 		end
						// 		else begin
						// 			Screen_X_Motion <= 1;
						// 			Screen_Y_Motion <= -1;
						// 		end
						// 	end
						// 	// D,W, right, up
						//   	16'h071A : begin
						// 		if((ScreenX >= Screen_X_Max) & (ScreenY <= Screen_Y_Min)) begin
						// 			Screen_X_Motion <= 0;
						// 			Screen_Y_Motion <= 0;
						// 		end
						// 		if((ScreenX >= Screen_X_Max) & !(ScreenY <= Screen_Y_Min)) begin
						// 			Screen_X_Motion <= 0;
						// 			Screen_Y_Motion <= -1;
						// 		end
						// 		if(!(ScreenX >= Screen_X_Max) & (ScreenY <= Screen_Y_Min)) begin
						// 			Screen_X_Motion <= 1;
						// 			Screen_Y_Motion <= 0;
						// 		end
						// 		else begin
						// 			Screen_X_Motion <= 1;
						// 			Screen_Y_Motion <= -1;
						// 		end
						// 	end
							
						// 	// D, S, right, down
						// 	16'h0716 : begin
						// 		if((ScreenX >= Screen_X_Max) & (ScreenY >= Screen_Y_Max)) begin
						// 			Screen_X_Motion <= 0;
						// 			Screen_Y_Motion <= 0;
						// 		end
						// 		if((ScreenX >= Screen_X_Max) & !(ScreenY >= Screen_Y_Max)) begin
						// 			Screen_X_Motion <= 0;
						// 			Screen_Y_Motion <= 1;
						// 		end
						// 		if(!(ScreenX >= Screen_X_Max) & (ScreenY >= Screen_Y_Max)) begin
						// 			Screen_X_Motion <= 1;
						// 			Screen_Y_Motion <= 0;
						// 		end
						// 		else begin
						// 			Screen_X_Motion <= 1;
						// 			Screen_Y_Motion <= 1;
						// 		end
						// 	end
						// 	// S, D, down, right
						// 	16'h1607 : begin
						// 		if((ScreenX >= Screen_X_Max) & (ScreenY >= Screen_Y_Max)) begin
						// 			Screen_X_Motion <= 0;
						// 			Screen_Y_Motion <= 0;
						// 		end
						// 		if((ScreenX >= Screen_X_Max) & !(ScreenY >= Screen_Y_Max)) begin
						// 			Screen_X_Motion <= 0;
						// 			Screen_Y_Motion <= 1;
						// 		end
						// 		if(!(ScreenX >= Screen_X_Max) & (ScreenY >= Screen_Y_Max)) begin
						// 			Screen_X_Motion <= 1;
						// 			Screen_Y_Motion <= 0;
						// 		end
						// 		else begin
						// 			Screen_X_Motion <= 1;
						// 			Screen_Y_Motion <= 1;
						// 		end
						// 	end
						// 	// S, A, down, left
						// 	16'h1604 : begin
						// 		if((ScreenX <= Screen_X_Min) & (ScreenY >= Screen_Y_Max)) begin
						// 			Screen_X_Motion <= 0;
						// 			Screen_Y_Motion <= 0;
						// 		end
						// 		if((ScreenX <= Screen_X_Min) & !(ScreenY >= Screen_Y_Max)) begin
						// 			Screen_X_Motion <= 0;
						// 			Screen_Y_Motion <= 1;
						// 		end
						// 		if(!(ScreenX <= Screen_X_Min) & (ScreenY >= Screen_Y_Max)) begin
						// 			Screen_X_Motion <= -1;
						// 			Screen_Y_Motion <= 0;
						// 		end
						// 		else begin
						// 			Screen_X_Motion <= -1;
						// 			Screen_Y_Motion <= 1;
						// 		end
						// 	end
						// 	// A, S, left, down
						// 	16'h0416 : begin
						// 		if((ScreenX <= Screen_X_Min) & (ScreenY >= Screen_Y_Max)) begin
						// 			Screen_X_Motion <= 0;
						// 			Screen_Y_Motion <= 0;
						// 		end
						// 		if((ScreenX <= Screen_X_Min) & !(ScreenY >= Screen_Y_Max)) begin
						// 			Screen_X_Motion <= 0;
						// 			Screen_Y_Motion <= 1;
						// 		end
						// 		if(!(ScreenX <= Screen_X_Min) & (ScreenY >= Screen_Y_Max)) begin
						// 			Screen_X_Motion <= -1;
						// 			Screen_Y_Motion <= 0;
						// 		end
						// 		else begin
						// 			Screen_X_Motion <= -1;
						// 			Screen_Y_Motion <= 1;
						// 		end
						// 	end
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

    // //ball/sprite logic
	always_ff @ (posedge Reset or posedge frame_clk or posedge debug)
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
//			Sprite_Y_Motion <= 10'd0; //Sprite_Y_Step;
//			Sprite_X_Motion <= 10'd0; //Sprite_X_Step;
			SpriteY <= Sprite_Y_Center;
			SpriteX <= Sprite_X_Center;
        end
		  else if (debug)
		  begin 
			SpriteY <= Sprite_Y_Center;
			SpriteX <= Sprite_X_Center;
		  end
	end //remove when you do full always_ff
    //     else 
    //     begin 
	// 			 if (isWinOnAnyEdge)
	// 			 begin
	// 				  Sprite_Y_Motion <= Sprite_Y_Motion;  // Ball is somewhere in the middle, don't bounce, just keep moving
	// 				  Sprite_X_Motion <= Sprite_X_Motion;
	// 			 case(keycode)
	// 				// two key press
	// 				16'h041A : begin	// A and W
	// 						Sprite_Y_Motion <= -1; //W
	// 						Sprite_X_Motion <= -1; // A
	// 						 end
	// 				16'h1A04 : begin	// W and A
	// 						Sprite_Y_Motion <= -1; // W
	// 						Sprite_X_Motion <= -1; // A
	// 						 end
	// 				16'h071A : begin // D and W
	// 				        Sprite_X_Motion <= 1;//D
	// 						Sprite_Y_Motion <= -1; // W
	// 						  end		 
	// 				16'h1A07 : begin // W and S
	// 				        Sprite_X_Motion <= 1;//D
	// 						Sprite_Y_Motion <= -1; // W
	// 						  end
	// 				16'h1607 : begin // S and D
	// 				        Sprite_X_Motion <= 1;
	// 						Sprite_Y_Motion <= 1;
	// 						  end
	// 				16'h0716 : begin // D and S
	// 				        Sprite_X_Motion <= 1;
	// 						Sprite_Y_Motion <= 1;
	// 						  end
	// 				16'h1604 : begin //S and A
	// 							Sprite_X_Motion <= -1;
	// 							Sprite_Y_Motion<= 1;
	// 						  end
	// 				16'h0416 : begin //A and S
	// 							Sprite_X_Motion <= -1;
	// 							Sprite_Y_Motion<= 1;
	// 						  end
	// 			 	// one key press
	// 			 	16'h0004 : begin //A
	// 							if(((isWinOnLeftEdge) & (SpriteX > Sprite_X_Min) & (SpriteX <= Sprite_X_Center)) | ((isWinOnRightEdge) & (SpriteX < Sprite_X_Max) & (SpriteX > Sprite_X_Center+1)))
	// 								Sprite_X_Motion <= -1;
	// 								//Sprite_Y_Motion<= 0;
	// 							// else if(SpriteX == Sprite_X_Center)
	// 							// 	Sprite_X_Motion <= 0;
	// 							else 
	// 								Sprite_X_Motion <= 0;
	// 						  	end
	// 				16'h0007 : begin // D
	// 							if(((isWinOnRightEdge) & (SpriteX < Sprite_X_Max) & (SpriteX >= Sprite_X_Center)) | ((isWinOnLeftEdge) & (SpriteX > Sprite_X_Min) & (SpriteX < (Sprite_X_Center-1))))
	// 								Sprite_X_Motion <= 1;
	// 								//Sprite_Y_Motion <= 0;
	// 							// else if(SpriteX == Sprite_X_Center)
	// 							// 	Sprite_X_Motion <= 0;
	// 							else 
	// 								Sprite_X_Motion <= 0;
	// 						  	end
	// 				16'h0016 : begin //S
	// 							if(((isWinOnBottomEdge) & (SpriteY < Sprite_Y_Max) & (SpriteY >= Sprite_Y_Center)) | ((isWinOnTopEdge) & (SpriteY > Sprite_Y_Min) & (SpriteY < (Sprite_Y_Center-1))))
	// 								Sprite_Y_Motion <= 1;
	// 								//Sprite_X_Motion <= 0;
	// 							else
	// 								Sprite_Y_Motion <= 0;	
	// 							end
	// 				16'h001A : begin //W
	// 							if(((isWinOnTopEdge) & (SpriteY > Sprite_Y_Min) & (SpriteY <= Sprite_Y_Center)) | ((isWinOnBottomEdge) & (SpriteY < Sprite_Y_Max) & (SpriteY > Sprite_Y_Center+1)))
	// 								Sprite_Y_Motion <= -1;
	// 								// 	Sprite_X_Motion <= 0;
	// 							else 
	// 								Sprite_Y_Motion <= 0;
	// 						 	end
    //         		default: begin
	// 					Sprite_X_Motion <= 0;
	// 					Sprite_Y_Motion <= 0;
	// 				end
	// 			 endcase
	// 			end 
	// 			else if ( (SpriteY) > Sprite_Y_Max )  // Ball is at the bottom edge, BOUNCE!
	// 			 begin
	// 				  SpriteY <= Sprite_Y_Max;  // 2's complement.
	// 				  Sprite_Y_Motion <= 0;
	// 			  end
	// 			 else if ( (SpriteY) < Sprite_Y_Min )  // Ball is at the top edge, BOUNCE!
	// 			 begin
	// 				  SpriteY <= Sprite_Y_Min;
	// 				  Sprite_Y_Motion <= 0;
	// 			  end
	// 			  else if ( (SpriteX) > Sprite_X_Max )  // Ball is at the Right edge, BOUNCE!
	// 			  begin
	// 				  SpriteX <= Sprite_X_Max;  // 2's complement.
	// 				  Sprite_X_Motion <= 0;
	// 			  end
	// 			 else if ( (SpriteX) < Sprite_X_Min )  // Ball is at the Left edge, BOUNCE!
	// 			 begin
	// 				  SpriteX <= Sprite_X_Min;
	// 				  Sprite_X_Motion <= 0;
	// 			 end
	// 			 else 
	// 			 begin
	// 					Sprite_X_Motion <= 0;
	// 					Sprite_Y_Motion <= 0;
	// 			 end
	// 			 SpriteY <= (SpriteY + Sprite_Y_Motion);  // Update ball position
	// 			 SpriteX <= (SpriteX + Sprite_X_Motion);
	// 	end  
    // end


	//drawing on screen
    always_ff @ (posedge vga_clk)
    begin:RGB_Display
		if (blank) begin
			  if (GBAWindow & GBADraw2XBound & GBADraw2YBound)
			  //if its in the window, AND in the bounds of the map
			  begin // drawing background
					Red <= {palette_red, 4'b0};
                    Green <= {palette_green, 4'b0};
		            Blue <= {palette_blue, 4'b0};
					if (sprite_on & ~spriteIgnore) 
					//if it's on sprite, AND isn't the ignore color 
					begin  // drawing sprite
						Red <= {sprite_red, 4'b0};
						Green <= {sprite_green, 4'b0};
						Blue <= {sprite_blue, 4'b0};
					end
			  end
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
	.q       (rom_q_map)
);

fpmapfinal_palette map480_palette (
	.index (rom_q),
	.red   (red_map),
	.green (green_map),
	.blue  (blue_map)
);

// battledraft3_rom battledraft_rom (
// 	.clock   (negedge_vga_clk),
// 	.address (rom_address),
// 	.q       (rom_q_battle)
// );

// battledraft3_palette battledraft_palette (
// 	.index (rom_q),
// 	.red   (red_battle),
// 	.green (green_battle),
// 	.blue  (blue_battle)
// );

sprite4dir2_rom spritedraft_rom (
	.clock   (negedge_vga_clk),
	.address (sprite_rom_addr),
	.q       (sprite_rom_q)
);

sprite4dir2_palette spritedraft_palette (
	.index (sprite_rom_q),
	.red   (sprite_red),
	.green (sprite_green),
	.blue  (sprite_blue)
);

fpcollision_rom collision_rom (
	.clock		(negedge_vga_clk),
	.addrX 	(collision_rom_addr_X),
	.addrY 	(collision_rom_addr_Y),
//	.addr3 	(collision_rom_addr_left),
//	.addr4 	(collision_rom_addr_right),
	.qX			(qX),
	.qY			(qY)//,
//	.q3			(q3),
//	.q4			(q4)
);

// fpcollision_palette collision_palette (
// 	.index (collision_rom_q),
// 	.red   (collision_red),
// 	.green (collision_green),
// 	.blue  (collision_blue)
// );

titlescreen_rom titlescreen1_rom (
	.clock   (negedge_vga_clk),
	.address (titlescreen1_rom_address),
	.q       (titlescreen1_rom_q)
);

titlescreen_palette titlescreen1_palette (
	.indexIntro (titlescreen1_rom_q),
	.indexEnd	(fake_ram_q),
	.redIntro   (titlescreen1_red),
	.greenIntro (titlescreen1_green),
	.blueIntro  (titlescreen1_blue),
	.redEnd   	(red_end),
	.greenEnd 	(green_end),
	.blueEnd  	(blue_end)	
);

// endscreen_rom endscreen_rom (
// 	.clock   (negedge_vga_clk),
// 	.address (titlescreen1_rom_address),
// 	.q       (end_rom_q)
// );

// endscreen_palette endscreen_palette (
// 	.index (end_rom_q),
// 	.red   (red_end),
// 	.green (green_end),
// 	.blue  (blue_end)
// );
battle battle0(.keycode(keycode[7:0]), .vga_clk, .frame_clk, .GBADraw2X(GBADraw2X0), .GBADraw2Y(GBADraw2Y0),
				.Red(red_battle), .Green(green_battle), .Blue(blue_battle), .blank, .debug, .Reset, .battle, .intro, 
				.playerDied, .ZuofuDied);

// fakeramlmao endScreenLoL(.clk(vga_clk), .n(titlescreen1_rom_address), .pixelout(fake_ram_q) );
endmodule
