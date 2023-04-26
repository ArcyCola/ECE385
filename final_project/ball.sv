//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input Reset, frame_clk,
					input [15:0] keycode,
               output [9:0]  BallX, BallY, BallS );
    
    logic [9:0] BallX, Ball_X_Motion, BallY, Ball_Y_Motion, BallS;
	 
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=100;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=539;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=100;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=379;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis

    assign BallS = 4;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
			Ball_X_Motion <= 10'd0; //Ball_X_Step;
			BallY <= Ball_Y_Center;
			BallX <= Ball_X_Center;
        end
           
        else 
        begin 
				 if ( (BallY + BallS) >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
					  Ball_Y_Motion <= (~ (Ball_Y_Step) + 1'b1);  // 2's complement.
					  
				 else if ( (BallY - BallS) <= Ball_Y_Min )  // Ball is at the top edge, BOUNCE!
					  Ball_Y_Motion <= Ball_Y_Step;
					  
				  else if ( (BallX + BallS) >= Ball_X_Max )  // Ball is at the Right edge, BOUNCE!
					  Ball_X_Motion <= (~ (Ball_X_Step) + 1'b1);  // 2's complement.
					  
				 else if ( (BallX - BallS) <= Ball_X_Min )  // Ball is at the Left edge, BOUNCE!
					  Ball_X_Motion <= Ball_X_Step;
					  
				 else begin
					  Ball_Y_Motion <= Ball_Y_Motion;  // Ball is somewhere in the middle, don't bounce, just keep moving
						
				 case(keycode)
					// two key press
					16'h041A : begin	// A and W
							Ball_Y_Motion <= -1; //W
							Ball_X_Motion <= -1; // A
							 end
					16'h1A04 : begin	// W and A
							Ball_Y_Motion <= -1; // W
							Ball_X_Motion <= -1; // A
							 end
					16'h071A : begin // D and W
					        Ball_X_Motion <= 1;//D
							Ball_Y_Motion <= -1; // W
							  end		 
					16'h1A07 : begin // W and S
					        Ball_X_Motion <= 1;//D
							Ball_Y_Motion <= -1; // W
							  end
					16'h1607 : begin // S and D
					        Ball_X_Motion <= 1;
							Ball_Y_Motion <= 1;
							  end
					16'h0716 : begin // D and S
					        Ball_X_Motion <= 1;
							Ball_Y_Motion <= 1;
							  end
					16'h1604 : begin //S and A
								Ball_X_Motion <= -1;
								Ball_Y_Motion<= 1;
							  end
					16'h0416 : begin //A and S
								Ball_X_Motion <= -1;
								Ball_Y_Motion<= 1;
							  end
				 	// one key press
				 	16'h0004 : begin //A
								Ball_X_Motion <= -1;
								//Ball_Y_Motion<= 0;
							  end
					16'h0400 : begin //A
								Ball_X_Motion <= -1;
								//Ball_Y_Motion<= 0;
							  end
					16'h0007 : begin // D
					        Ball_X_Motion <= 1;
							  //Ball_Y_Motion <= 0;
							  end
					16'h0700 : begin // D
					        Ball_X_Motion <= 1;
							  //Ball_Y_Motion <= 0;
							  end
					16'h0016 : begin //S
					        Ball_Y_Motion <= 1;
							  //Ball_X_Motion <= 0;
							 end
					16'h1600 : begin //S
					        Ball_Y_Motion <= 1;
							  //Ball_X_Motion <= 0;
							 end
					16'h001A : begin //W
					        Ball_Y_Motion <= -1;
							  //Ball_X_Motion <= 0;
							 end
					16'h1A00 : begin //W
					        Ball_Y_Motion <= -1;
							  //Ball_X_Motion <= 0;
							 end

            		default: ;
				 endcase
// 				 case (keycode[7:0])
// 					8'h04 : begin //A
							
// 								Ball_X_Motion <= -1;
// 								//Ball_Y_Motion<= 0;
// 							  end
					        
// 					8'h07 : begin
								
// 					        Ball_X_Motion <= 1;//D
// 							  //Ball_Y_Motion <= 0;
// 							  end

							  
// 					8'h16 : begin

// 					        Ball_Y_Motion <= 1;//S
// 							  //Ball_X_Motion <= 0;
// 							 end
							  
// 					8'h1A : begin
// 					        Ball_Y_Motion <= -1;//W
// 							  //Ball_X_Motion <= 0;
// 							 end	  
// 					default: ;
// 					endcase
					
// 					case (keycode[15:8])
// 					8'h04 : begin //A
							
// 								Ball_X_Motion <= -1;
// 								//Ball_Y_Motion<= 0;
// 							  end
					        
// 					8'h07 : begin
								
// 					        Ball_X_Motion <= 1;//D
// 							  //Ball_Y_Motion <= 0;
// 							  end

							  
// 					8'h16 : begin

// 					        Ball_Y_Motion <= 1;//S
// 							  //Ball_X_Motion <= 0;
// 							 end
							  
// 					8'h1A : begin
// 					        Ball_Y_Motion <= -1;//W
// 							  //Ball_X_Motion <= 0;
// 							 end	  
// 					default: ;

// //				if (keycode == 8'h04) begin //A
// //						Ball_X_Motion <= -1;
// //				end
// //				if (keycode == 8'h07) begin //D
// //						Ball_X_Motion <= 1;
// //				end
// //				if (keycode == 8'h16) begin //S
// //						Ball_Y_Motion <= 1;
// //				end
// //				if (keycode == 8'h1A) begin //W
// //						Ball_Y_Motion <= -1;
// //				end
				
// 			   endcase
				end 
				 BallY <= (BallY + Ball_Y_Motion);  // Update ball position
				 BallX <= (BallX + Ball_X_Motion);
			
			
	  /**************************************************************************************
	    ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
		 Hidden Question #2/2:
          Note that Ball_Y_Motion in the above statement may have been changed at the same clock edge
          that is causing the assignment of BallY.  Will the new value of Ball_Y_Motion be used,
          or the old?  How will this impact behavior of the ball during a bounce, and how might that 
          interact with a response to a keypress?  Can you fix it?  Give an answer in your Post-Lab.
      **************************************************************************************/
      
			
		end  
    end
    

endmodule
