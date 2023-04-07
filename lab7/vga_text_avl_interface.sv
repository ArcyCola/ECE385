/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
//`define NUM_REGS 601 //80*30 characters / 4 characters per register
//`define CTRL_REG 600 //index of control register

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

//this is the unpacked thing of registers
//logic [31:0] LOCAL_REG       [`NUM_REGS]; // Registers
//LOCAL_REG[2][4:0] 

//unpacked dimension first
//perspective of hardware, packed is always 31 down to 0
//to split up by bytes
//                   LOCALREG[3:0][7:0]
//         choosing which addr^     ^choosing bits of data in register/"ram"

//put other local variables here
logic [9:0] DrawX, DrawY; 	// position of electron beam on screen
logic [6:0] charX;			// x coord of the glyph
logic [5:0] charY;			// y coord of the glyph
logic [11:0] charAddr;
logic [11:0] regNum;
logic codeX;
logic [10:0] addr;
logic [15:0] codeAddr; //, data;
logic [7:0] charData;
logic [31:0] vramData;
logic [31:0] avl_read_data_vram;
logic blank, pixel_clk;

//ram instiation for 7.2

vram ram(.address_a(AVL_ADDR), .address_b(regNum), .byteena_a(AVL_BYTE_EN), .clock(CLK), 
	.data_a(AVL_WRITEDATA), .data_b(), .rden_a(AVL_READ & AVL_CS & ~AVL_ADDR[11]), 
	.rden_b(1), .wren_a(AVL_WRITE & AVL_CS & ~AVL_ADDR[11]), .wren_b(0), .q_a(avl_read_data_vram), 
	.q_b(vramData));

//16 registers of 16 bits, so that it is easier to find colors, no need for even/odd
logic [31:0] palette[8]; //palette registers
//Declare submodules..e.g. VGA controller, ROMS, etc

vga_controller VGA0(.Clk(CLK), .Reset(RESET), .hs, .vs, .pixel_clk, .blank(blank), .sync(), .DrawX(DrawX), .DrawY(DrawY));

font_rom font_rom0(.addr(addr), .data(charData));
   
// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff

// assign AVL_READDATA = avl_read_data_vram;

always_ff @(posedge CLK) begin

	//writing to palette

	if (AVL_CS & AVL_ADDR[11] & AVL_WRITE) begin
		palette[AVL_ADDR[2:0]] <= AVL_WRITEDATA;
	end
	

//	
		

	//reading from palette
//	if (AVL_CS & AVL_ADDR[11] & AVL_READ) begin
//		AVL_READDATA <= palette[AVL_ADDR[2:0]];
//	end
//	


	//READ AND WRITE, (7.2)
	// if (AVL_CS) begin
	// 	AVL_READ_CS <= AVL_READ;
	// 	AVL_WRITE_CS <= AVL_WRITE & !AVL_ADDR[11];
	// end
	// else begin
	// 	AVL_READ_CS <= 1'b0;
	// 	AVL_WRITE_CS <= 1'b0;
	// end	


	//WRITE (7.1)

	// if (AVL_WRITE && AVL_CS) begin
	// 	if (AVL_BYTE_EN[0]) begin
	// 		LOCAL_REG[AVL_ADDR][7:0] <= AVL_WRITEDATA[7:0];
	// 	end
	// 	if (AVL_BYTE_EN[1]) begin
	// 		LOCAL_REG[AVL_ADDR][15:8] <= AVL_WRITEDATA[15:8];
	// 	end
	// 	if (AVL_BYTE_EN[2]) begin
	// 		LOCAL_REG[AVL_ADDR][23:16] <= AVL_WRITEDATA[23:16];
	// 	end
	// 	if (AVL_BYTE_EN[3]) begin
	// 		LOCAL_REG[AVL_ADDR][31:24] <= AVL_WRITEDATA[31:24];
	// 	end
	// end

	//READ (7.1)
	// if (AVL_READ && AVL_CS) begin
	// 	AVL_READDATA[31:0] <= LOCAL_REG[AVL_ADDR][31:0];
	// end

	

end


//handle drawing (may either be combinational or sequential - or both).
		
always_comb 
begin 

	//
	if (AVL_CS & AVL_ADDR[11] & AVL_READ) begin
			AVL_READDATA = palette[AVL_ADDR[2:0]];
		end
	else begin
		AVL_READDATA = avl_read_data_vram;
	end
	// 640 x 480 pixels = 80 columns x 30 rows
	// 0 -> 2400 character addresses

	// finding the character address, find x and y addresses first
	// charX = drawX / 8	(8 is width of glyph)
	// charY = drawY / 16	(16 is height of glyph)
	charX = DrawX[9:3]; // divding by 8, because theres 640 / 80 = 8 (this is shifting right 3 times)
	charY = DrawY[9:4]; // divding by 16 cuz 480 / 30 = 16 (this is shifting right 4 times)
	
	charAddr = charY * (80) + charX; // 80 is # of columns in a row/line

	// finding the register where character is contained at
	// 1 register = 4 glyphs
	regNum = charAddr / (2);		// divide by 2 bc 2 glyphs in 1 register
	// finding glyph we are at inside the register
	codeX = charAddr % (2);		
	
	// finding "adder" input for font_rom.sv
	//
	unique case(codeX) 
		1'b0 : codeAddr = vramData[15:0];
		1'b1 : codeAddr = vramData[31:16];
		// 2'b10 : codeAddr = vramData[23:16];
		// 2'b11 : codeAddr = vramData[31:24];
	endcase
	//MSbyte, character, LSbyte, color
	//charData = codeAddr[15:8];
	//
	addr = {codeAddr[14:8], DrawY[3:0]};	// addr is input to font_rom


	
	// check blank (active low)
	// if blank = 0 show black
	// if blank = 1 show color and....
	// check data[7] to see if invert or not
	// if data[7] = 1 invert fg/bg
	// if data[7] = 0 default	

// 	Control Register Format:
//  [[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
//  [[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]
end

always_ff @(posedge pixel_clk) begin
//this code, change it so that it calls the 
	if(blank) begin	// blank = 1 show color
		if (codeAddr[15] ^ charData[7-DrawX[2:0]]) begin // 7 - DrawX to get opposite side
				// 7.1 stuff
				// red <= 4'b1111;	// foreground red
				// green <= 4'b0000;	// foreground green
				// blue <= 4'b0000;	// foreground blue

				// 7.2:
				if(codeAddr[7:4] % 2 == 0) begin	// if FGD_IDX is even
//					red <= palette[(codeAddr[7:4]/2)][12:9];
//					green <= palette[(codeAddr[7:4]/2)][8:5];
//					blue <= palette[(codeAddr[7:4]/2)][4:1];


					red <= palette[(codeAddr[7:4]/2)][12:9];
					green <= palette[(codeAddr[7:4]/2)][8:5];
					blue <= palette[(codeAddr[7:4]/2)][4:1];
				end
				else begin						// FGD_IDX is odd
//					red <= palette[(codeAddr[7:4]/2)][24:21];
//					green <= palette[(codeAddr[7:4]/2)][20:17];
//					blue <= palette[(codeAddr[7:4]/2)][16:13];
					red <= palette[(codeAddr[7:4]/2)][24:21];
					green <= palette[(codeAddr[7:4]/2)][20:17];
					blue <= palette[(codeAddr[7:4]/2)][16:13];
				end
				// check if codeAddr[7:4] is even (mod2)
				// if even 
				// red = palette[(codeAddr[7:4]/2)][12:9]
				// if odd
				// red = palette[(codeAddr[7:4]/2)][24:21]
		end
		else begin	// data[7] = 0 default
				// red <=  4'b0101;
				// green <= 4'b1111;
				// blue <= 4'b1111;
				if (codeAddr[0] == 0) begin
					red <= palette[(codeAddr[3:0]/2)][12:9];
					green <= palette[(codeAddr[3:0]/2)][8:5];
					blue <= palette[(codeAddr[3:0]/2)][4:1];
				end
				else begin
					red <= palette[(codeAddr[3:0]/2)][24:21];
					green <= palette[(codeAddr[3:0]/2)][20:17];
					blue <= palette[(codeAddr[3:0]/2)][16:13];
				end
		end
	end
	else begin	// blank = 0 show black
		red <= 4'b0000;
		green <= 4'b0000;
		blue <= 4'b0000;
	end
// 	VRAM Format:
//  X->
//  [ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
//  [IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

	//font_rom, lower 4 bits denotes Y coordinate, 
	//          upper 7 denotes index of glyph

end

endmodule
