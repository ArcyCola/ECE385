module reg_16 ( input				 Clk, Reset, Load, DR, SR1, LD_REG
				input					[15:0] D, IR,

				output logic 			[15:0] Data_Out);
					
		always_ff @ (posedge Clk)
		begin
				// Setting the output Q[16..0] of the register to zeros as Reset is pressed
				if(Reset) //notice that this is a synchronous reset
					Data_Out <= 16'b0000000000000000;
				// Loading D into register when load button is pressed (will eiher be switches or result of sum)
				else if(Load)
					Data_Out <= D;
		end
		
endmodule

module reg_3 ( input				 Clk, Reset, Load, //make sure to edit for Branch implementation
				input					[2:0] D, IR,
				output logic 			[2:0] Data_Out);
					
		always_ff @ (posedge Clk)
		begin
				// Setting the output Q[16..0] of the register to zeros as Reset is pressed
				if(Reset) //notice that this is a synchronous reset
					Data_Out <= 3'b000;
				// Loading D into register when load button is pressed (will eiher be switches or result of sum)
				else if(Load)
					Data_Out <= D;
		end
		
endmodule

module reg_1 ( 	input		Clk, Reset, Load, //for BEN enable
				input					 D,
				output logic 		 Data_Out);
					
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