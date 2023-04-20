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


module  color_mapper ( input        [9:0] BallX, BallY, DrawX, DrawY, Ball_size,
								input blank, vga_clk,
                       output logic [7:0]  Red, Green, Blue );
    
    logic ball_on, GBAWindow;
	 
 /* Old Ball: Generated square box by checking if the current pixel is within a square of length
    2*Ball_Size, centered at (BallX, BallY).  Note that this requires unsigned comparisons.
	 
    if ((DrawX >= BallX - Ball_size) &&
       (DrawX <= BallX + Ball_size) &&
       (DrawY >= BallY - Ball_size) &&
       (DrawY <= BallY + Ball_size))

     New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
     this single line is quite powerful descriptively, it causes the synthesis tool to use up three
     of the 12 available multipliers on the chip!  Since the multiplicants are required to be signed,
	  we have to first cast them from logic to int (signed by default) before they are multiplied). */
	  
    int DistX, DistY, Size;
	 assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
    assign Size = Ball_size;
	// ------------------------------------------------
    // adding stuff for background fjdguidgnfdm

    logic [15:0] rom_address;
    logic [3:0] rom_q;

    logic [3:0] palette_red, palette_green, palette_blue;

    logic [9:0] GBADraw2X, GBADraw2Y;

    logic negedge_vga_clk;
    
    assign negedge_vga_clk = ~vga_clk;



    // ------------------------------------------------
    always_comb
    begin:Ball_on_proc
        GBAWindow = (80 <= DrawX) & (DrawX < 560) & (80 <= DrawY) & (DrawY < 400);
    
        if ( ( DistX*DistX + DistY*DistY) <= (Size * Size) ) 
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;


     end 
       

    always_comb begin
			GBADraw2X = DrawX - 80;
			GBADraw2Y = DrawY - 80;
        //negedge_vga_clk = ~vga_clk;
		

        // address into the rom = (x* xDim ) / 480 + ((y * yDim) / 320) * xDim
//rom = (GBADraw2x* ImageXDim ) / ScreenWidth + ((GBADraw2Y* ImageYDim) / ScreenHeight) * ScreenWidth

        // for the pokemon firered map 1x 
        rom_address = ((GBADraw2X * 240) / 480) + (((GBADraw2Y * 160) / 320) * 240);
        // ---------------------------------------------
        // for the pokemon firered map 2x 
        //rom_address = (GBADraw2X / 480) + (GBADraw2Y * 480);
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
    
pokemonfireredmap_rom pokemonfireredmap_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address),
	.q       (rom_q)
);

pokemonfireredmap_palette pokemonfireredmap_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);

endmodule
