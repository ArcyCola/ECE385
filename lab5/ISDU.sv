//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Lab 6 Given Code - Incomplete ISDU
// Module Name:    ISDU - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//------------------------------------------------------------------------------


module ISDU (   input logic         Clk, 
									Reset,
									Run,
									Continue,
									
				input logic[3:0]    Opcode, 
				input logic         IR_5,
				input logic         IR_11,
				input logic         BEN,
				  
				output logic        LD_MAR,
									LD_MDR,
									LD_IR,
									LD_BEN,
									LD_CC,
									LD_REG,
									LD_PC,
									LD_LED, // for PAUSE instruction
									
				output logic        GatePC,
									GateMDR,
									GateALU,
									GateMARMUX,
									
				output logic [1:0]  PCMUX,
				output logic        DRMUX,
									SR1MUX,
									SR2MUX,
									ADDR1MUX,
				output logic [1:0]  ADDR2MUX,
									ALUK,
				  
				output logic        Mem_OE, // read enable
									Mem_WE	// write enable
				);

	enum logic [3:0] {  Halted, 
						PauseIR1, 
						PauseIR2, 
						S_18, 
						S_33_1, 
						S_33_2,
						S_33_3,
						S_33_4, //remember to remove these during lab 5.2
						S_35, 
						S_32, 
						S_01,
						S_05,
						S_09,
						S_06,
						S_25_1,
						S_25_2,
						S_25_3,
						S_27,
						S_07,
						S_32,
						S_16_1,
						S_16_2,
						S_16_3,
						S_01,
						S_22,
						S_12,
						S_4,
						S_00, //idk what else to call it
						S_21}   State, Next_state;   // Internal state logic
		
	always_ff @ (posedge Clk)
	begin
		if (Reset) 
			State <= Halted;
		else 
			State <= Next_state;
	end
   
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = State;
		
		// Default controls signal values
		LD_MAR = 1'b0;
		LD_MDR = 1'b0;
		LD_IR = 1'b0;
		LD_BEN = 1'b0;
		LD_CC = 1'b0;
		LD_REG = 1'b0;
		LD_PC = 1'b0;
		LD_LED = 1'b0;
		 
		GatePC = 1'b0;
		GateMDR = 1'b0;
		GateALU = 1'b0;
		GateMARMUX = 1'b0;
		 
		ALUK = 2'b00;
		 
		PCMUX = 2'b00;
		DRMUX = 1'b0;
		SR1MUX = 1'b0;
		SR2MUX = 1'b0;
		ADDR1MUX = 1'b0;
		ADDR2MUX = 2'b00;
		 
		Mem_OE = 1'b0;
		Mem_WE = 1'b0;
	
		// Assign next state
		unique case (State)
			Halted : 
				if (Run) 
					Next_state = S_18;                      
			S_18 : 
				Next_state = S_33_1;
			// Any states involving SRAM require more than one clock cycles.
			// The exact number will be discussed in lecture.
			S_33_1 : 
				Next_state = S_33_2;
			S_33_2 : 
				Next_state = S_33_3; //added for 3 wait states
			S_33_3 : 
				Next_state = S_33_4; //added for 3 wait states
			S_33_4 : 
				Next_state = S_35;
			S_35 : 
				Next_state = PauseIR1;
			// PauseIR1 and PauseIR2 are only for Week 1 such that TAs can see 
			// the values in IR.
			PauseIR1 : 
				if (~Continue) 
					Next_state = PauseIR1;
				else 
					Next_state = PauseIR2;
			PauseIR2 : 
				if (Continue) 
					Next_state = PauseIR2;
				else 
					Next_state = S_18;
			S_32 : 
				case (Opcode)
					4'b0001 : Next_state = S_01;     //ADD & ADDi

					// You need to finish the rest of opcodes.....
					4'b0000 : Next_state = S_00;      //BR
					4'b0101 : Next_state = S_05;     //AND & ANDi
					4'b1001 : Next_state = S_09;     //NOT
					4'b1100 : Next_state = S_12;     //JMP
					4'b0100 : Next_state = S_04;     //JSR
					4'b0110 : Next_state = S_06;     //LDR
					4'b0111 : Next_state = S_07;     //STR
					4'b1101 : Next_state = PauseIR1; //pause
					default : 
						Next_state = S_18;
				endcase
			//ADD
			S_01 :      Next_state = S_18; //ADD state to PC 
			
			// You need to finish the rest of states.....

			//AND
			S_05 : Next_state = S_18; //AND to PC

			//NOT
			S_09 : Next_state = S_18; //NOT to PC

			//LDR
			S_06   : Next_state = S_25_1; //(MAR <- B + off6) to (MDR <- M[MAR])
			S_25_1 : Next_state = S_25_2;
			S_25_2 : Next_state = S_25_3;
			S_25_3 : Next_state = S_27; //(MDR <- M[MAR]) to (DR <- MDR, set CC)
			S_27   : Next_state = S_18 //(DR <- MDR, set CC) to PC

			//STR
			S_07   : Next_state = S_23;
			S_23   : Next_state = S_16_1;
			S_16_1 : Next_state = S_16_2; //wait states
			S_16_2 : Next_state = S_16_3;
			S_16_3 : Next_state = s_18;

			//BR
			S_00 : //state case 0 ohhhhh
				case (BEN)
					1'b0 : Next_state = S_18;
					1'b1 : Next_state = S_22;
				endcase
			S_22 : Next_state = S_18;

			//JMP
			S_12 : Next_state = S_18;

			//JSR
			S_04 : Next_state = S_18;
			
			default :   Next_state = S_18; //dont know if this is accurate or not

		endcase
		
		// Assign control signals based on current state
		case (State)
			Halted: ; //do we need this?
			S_18 : 
				begin 
					GatePC = 1'b1; //implemented
					LD_MAR = 1'b1;
					PCMUX = 2'b00;
					LD_PC = 1'b1;
				end
			S_33_1 : 
				Mem_OE = 1'b1;
			S_33_2 : 
				begin 
					Mem_OE = 1'b1;
					//LD_MDR = 1'b1; //for waiting state
				end
			S_33_3 : 
				Mem_OE = 1'b1; //CHANGE STATE MACHINE
			S_33_4 : 
				begin
					Mem_OE = 1'b1;
					LD_MDR = 1'b1; //do we still need the waiting state 
				end
			S_35 : 
				begin 
					GateMDR = 1'b1;
					LD_IR = 1'b1;
				end
			PauseIR1: ;
			PauseIR2: ;
			S_32 : 
				LD_BEN = 1'b1;

			// ADD	
			S_01 : 		
				begin 
					SR2MUX = IR_5;		// SR2MUX is 1 bit select input for the SR2_MUX we implemented
					ALUK = 2'b00;		// select for ALU, ALUK = 00 means ADD
					GateALU = 1'b1;		// output of ALU goes onto databus
					LD_REG = 1'b1;		// signals we load into reg file
					// incomplete...
					LD_CC = 1'b1;		// i think this is correct?	
					Mem_WE = 1'b1;		// high bc writing to register file?
					//uhh idk if we need anything else here
				end

			// You need to finish the rest of states.....
			
			// AND
			S_05 :		
				begin
					SR2MUX = IR_5;
					ALUK = 2'b01;
					GateALU = 1'b1;
					LD_REG = 1'b1;
					LD_CC = 1'b1;
					Mem_We = 1'b1;
				end
				
			// NOT
			S_09 :		
				begin
					LD_REG = 1'b1;
					GateALU = 1'b1;
					ALUK = 2'b10;
					LD_CC = 1'b1;
				end
				
			// LDR
			S_06 :
				begin //honestly dont know what im doing
					LD_MAR = 1'b1;
					GateALU = 1'b1;
					ALUK = 2'b00;
					SR1MUX = 1'b0;
					SR2MUX = 1'b1;
				end
			S_25_1 :
				begin
					Mem_OE = 1'b1;
				end
			S_25_2 :
				begin
					Mem_OE = 1'b1;
				end
			S_25_3 :
				begin
					Mem_OE = 1'b1;
					LD_MDR = 1'b1;
				end
			S_27 :
				begin //DR <- MDR, set CC
					LD_CC = 1'b1; //for branch
					LD_REG = 1'b1; //to load stuff into SR/DR
					GateMDR = 1'b1;
					DRMUX = 1'b0; 
				end
			
			// STR
			S_07 :
				begin //MAR <- B + off6
					LD_MAR = 1'b1;
					SR1MUX = 1'b1;
					GateMARMUX = 1'b1;
					ADDR1MUX = 1'b0;
					ADDR2MUX = 2'b01;
 				end
			S_23 :
				begin //MDR <- SR
					LD_MDR = 1'b1;
					SR1MUX = 1'b1;
					MIO_EN = 1'b0;
					GateMARMUX = 1'b1;
					LD_REG = 1'b1;
				end
			S_16_1 :
				begin
				end
			S_16_2 :
				begin
				end
			S_16_3 :
				begin
				end

			// JSR
			S_04 :
				begin
				end
			S_21 :
				begin
				end

			// JMP
			S_12 :
				begin
				end
			
			// BR
			S_00 :

			
			default : ;
		endcase
	end 

	
endmodule
