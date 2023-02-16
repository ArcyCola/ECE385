-module reg_8 ( input						Clk, Reset, Load, Shift_En, Shift_In,
					input						[7:0] D,
					output logic 			[7:0] Data_Out
					output logic               Shift_Out);
					
		always_ff @ (posedge Clk)
		begin
				// Setting the output Q[7..0] of the register to zeros as Reset is pressed
				if(Reset) //notice that this is a synchronous reset
					Data_Out <= 8'b00000000;
				// Loading D into register when load button is pressed (will eiher be switches or result of sum)
				else if(Load)
					Data_Out <= D;
				else if(Shift_En)
					Data_Out <= { Shift_In, Data_Out[7:1] };
				
		end
	assign Shift_Out = Data_Out[0];
		
endmodule

module reg_1 ( 	input		Clk, Reset, Load, Shift_En, Shift_In,
				input					 D,
				output logic 		 Data);
					
		always_ff @ (posedge Clk)
		begin
				// Setting the output Q[7..0] of the register to zeros as Reset is pressed
				if(Reset) //notice that this is a synchronous reset
					Data <= 1'b0;
				// Loading D into register when load button is pressed (will eiher be switches or result of sum)
				else if(Load)
					Data <= D;
				
	
		end

endmodule