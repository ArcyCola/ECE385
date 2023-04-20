module pokemonfireredmap_example (
	input logic vga_clk,
	input logic [9:0] DrawX, DrawY,
	input logic blank,
	output logic [3:0] red, green, blue
);

logic [15:0] rom_address;
logic [3:0] rom_q;

logic [3:0] palette_red, palette_green, palette_blue;

logic [9:0] GBADraw2X, GBADraw2Y;

logic negedge_vga_clk;

// read from ROM on negedge, set pixel on posedge
assign negedge_vga_clk = ~vga_clk;

// address into the rom = (x*xDim)/480 + ((y*yDim)/320) * xDim
// this will stretch out the sprite across the entire screen
// assign rom_address = ((DrawX * 240) / 640) + (((DrawY * 160) / 480) * 240);


//this is scaling so that we start at the right spot for it ahhhhhh and call right pixels, and 2
//times scale 
always_comb begin
	if ((80 <= DrawX) & (DrawX < 560) & (80 <= DrawY) & (DrawY < 400)) begin
		GBADraw2X = DrawX - 80;
 		GBADraw2Y = DrawY - 80;
	end
	rom_address = ((GBADraw2X * 240) / 480) + (((GBADraw2Y * 160) / 320) * 240);
end

always_ff @ (posedge vga_clk) begin
	red <= 4'h0;
	green <= 4'h0;
	blue <= 4'h0;

	if (blank) begin
		red <= palette_red;
		green <= palette_green;
		blue <= palette_blue;
	end
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
