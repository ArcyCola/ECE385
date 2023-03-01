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