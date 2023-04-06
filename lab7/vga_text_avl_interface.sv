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
`define NUM_REGS 601 //80*30 characters / 4 characters per register
`define CTRL_REG 600 //index of control register

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
logic [9:0] regNum;
logic codeX;
logic [10:0] addr;
logic [15:0] codeAddr; //, data;
logic [7:0] charData;
logic [31:0] vramData;
logic blank, pixel_clk, AVL_READ_CS, ALV_WRITE_CS;

//ram instiation for 7.2

vram ram(.address_a(AVL_ADDR), .address_b(regNum), .byteena_a(AVL_BYTE_EN), .clock(CLK), .data_a(AVL_WRITEDATA), .data_b(), .rden_a(AVL_READ & AVL_CS), .rden_b(1), .wren_a(AVL_WRITE & AVL_CS & !AVL_ADDR[11]), .wren_b(0), .q_a(AVL_READDATA), .q_b(vramData));

//16 registers of 16 bits, so that it is easier to find colors, no need for even/odd
logic [31:0] palette[8]; //palette registers
//Declare submodules..e.g. VGA controller, ROMS, etc

vga_controller VGA0(.Clk(CLK), .Reset(RESET), .hs, .vs, .pixel_clk, .blank(blank), .sync(), .DrawX(DrawX), .DrawY(DrawY));

font_rom font_rom0(.addr(addr), .data(charData));
   
// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff

always_ff @(posedge CLK) begin

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
		2'b0 : codeAddr = vramData[15:0];
		2'b1 : codeAddr = vramData[31:16];
		// 2'b10 : codeAddr = vramData[23:16];
		// 2'b11 : codeAddr = vramData[31:24];
	endcase
	//MSbyte, character, LSbyte, color
	charData = codeAddr[15:8];
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
				red <= 4'b1100;	// foreground 14
				green <= 4'b1100;	// foreground green
				blue <= 4'b1111;	// foreground blue
		end
		else begin	// data[7] = 0 default
				red <=  4'b0010;
				green <= 4'b0010;
				blue <= 4'b0010;
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
