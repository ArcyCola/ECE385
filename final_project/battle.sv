module battle (input [7:0] keycode,
               input vga_clk,
               input logic signed [10:0] GBADraw2X, GBADraw2Y,
               output [3:0] Red, Green, Blue);

    logic move;

    logic [17:0] rom_address;
    logic [3:0] rom_q;

    logic [3:0] red_battle, blue_battle, green_battle;

    logic negedge_vga_clk;

    // read from ROM on negedge, set pixel on posedge
    assign negedge_vga_clk = ~vga_clk;

    assign rom_address = (GBADraw2X) + ((GBADraw2Y) * 480);

    //move is to determine who's move, 0 = player, 1 = zuofu
    assign move = 0;

    //since width of the bar is 94,,, might as well just so its simpler.
    int AEHealth = 94, ZuofuHealth = 94;

    logic AEHealthBar, ZuofuHealthBar;

    always_comb 
    begin
        ZuofuHealthBar = (105 <= GBADraw2X) & (GBADraw2X <= 199) & (67 <= GBADraw2Y) & (GBADraw2Y <= 71);

        AEHealthBar = (349 <= GBADraw2X) & (GBADraw2X <= 443) & (181 <= GBADraw2Y) & (GBADraw2Y <= 184);
    end

    always_ff (posedge keycode)
    begin:battling????????

    end

    //dont know if we need keycode here
    always_ff @ (posedge vga_clk or posedge keycode) 
    begin:Drawing
            Red <= red_battle;
            Green <= green_battle;
            Blue <= blue_battle;
        if (ZuofuHealthBar) 
        begin

        end
        else if (AEHealthBar)
        begin

        end
    end

battledraft3_rom battledraft_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address),
	.q       (rom_q)
);

battledraft3_palette battledraft_palette (
	.index (rom_q),
	.red   (red_battle),
	.green (green_battle),
	.blue  (blue_battle)
);


endmodule