module fpcollision_palette (
	input logic [0:0] index,
	output logic [3:0] red, green, blue
);

localparam [0:1][11:0] palette = {
	{4'hF, 4'h0, 4'h8},		// index = 0 PINK
	{4'hF, 4'hF, 4'hF}		// index = 1 WHITE
};

assign {red, green, blue} = palette[index];

endmodule
