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
	input  logic [9:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

//this is the unpacked thing of registers
logic [31:0] LOCAL_REG       [`NUM_REGS]; // Registers
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
logic [1:0] codeX;
logic [10:0] addr;
logic [7:0] codeAddr, data;
logic blank, pixel_clk;
//Declare submodules..e.g. VGA controller, ROMS, etc

vga_controller VGA0(.Clk(CLK), .Reset(RESET), .hs, .vs, .pixel_clk, .blank(blank), .sync(), .DrawX(DrawX), .DrawY(DrawY));

font_rom font_rom0(.addr(addr), .data(data));
   
// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff
always_ff @(posedge CLK) begin
	// if (AVL_WRITE == 1'b0) begin //idk if we can assume write, read will be always low
	// 	unique case(AVL_BYTE_EN)
	// 		4'b1111 : LOCALREG[AVL_ADDR] <= AVL_WRITEDATA
	// 		4'b1100 : 
	// 		4'b0011 : 
	// 		4'b1000 : 
	// 		4'b0100 : 
	// 		4'b0010 : 
	// 		4'b0001 : 
	// 	endcase
	// end

	//LOCAL_REG[1:0], modulus 
	//to write, need to use CS, ADDR, BYTE_EN, WRITE, WRITEDATA, CLK, RESET

	//WRITE
	if (AVL_WRITE && AVL_CS) begin
		if (AVL_BYTE_EN[0]) begin
			LOCAL_REG[AVL_ADDR][7:0] <= AVL_WRITEDATA[7:0];
		end
		if (AVL_BYTE_EN[1]) begin
			LOCAL_REG[AVL_ADDR][15:8] <= AVL_WRITEDATA[15:8];
		end
		if (AVL_BYTE_EN[2]) begin
			LOCAL_REG[AVL_ADDR][23:16] <= AVL_WRITEDATA[23:16];
		end
		if (AVL_BYTE_EN[3]) begin
			LOCAL_REG[AVL_ADDR][31:24] <= AVL_WRITEDATA[31:24];
		end
	end

	//READ
	if (AVL_READ && AVL_CS) begin
		AVL_READDATA[31:0] <= LOCAL_REG[AVL_ADDR][31:0];
	end

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
	regNum = charAddr / (4);		// divide by 4 bc 4 glyphs in 1 register
	// finding glyph we are at inside the register
	codeX = charAddr % (4);		// 1 register = [code0][code1][code2][code3]
	
	// finding "adder" input for font_rom.sv
	unique case(codeX) 
		2'b00 : codeAddr = LOCAL_REG[regNum][7:0];
		2'b01 : codeAddr = LOCAL_REG[regNum][15:8];
		2'b10 : codeAddr = LOCAL_REG[regNum][23:16];
		2'b11 : codeAddr = LOCAL_REG[regNum][31:24];
	endcase
	addr = {codeAddr[6:0], DrawY[3:0]};

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
	if(blank) begin	// blank = 1 show color
		if (codeAddr[7] ^ data[7-DrawX[2:0]]) begin // 7 - DrawX to get opposite side
				red <= LOCAL_REG[600][24:21];	// foreground red
				blue <= LOCAL_REG[600][16:13];	// foreground blue
				green <= LOCAL_REG[600][20:17];	// foreground green
			
		end
		else begin	// data[7] = 0 default
				red <=  LOCAL_REG[600][12:9];
				green <= LOCAL_REG[600][8:5];
				blue <= LOCAL_REG[600][4:1];
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
