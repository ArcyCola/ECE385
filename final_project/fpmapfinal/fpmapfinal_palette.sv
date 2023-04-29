module fpmapfinal_palette (
	input logic [3:0] index,
	output logic [3:0] red, green, blue
);

localparam [0:15][11:0] palette = {
	{4'h6, 4'hD, 4'h8},
	{4'hE, 4'hD, 4'hB},
	{4'h9, 4'h9, 4'h9},
	{4'h0, 4'h8, 4'h2},
	{4'h5, 4'hC, 4'hF},
	{4'hE, 4'h8, 4'h5},
	{4'h8, 4'hB, 4'h9},
	{4'h3, 4'hB, 4'h5},
	{4'h8, 4'h6, 4'h2},
	{4'h0, 4'h6, 4'h8},
	{4'hF, 4'hF, 4'hF},
	{4'hF, 4'hE, 4'h0},
	{4'h5, 4'h3, 4'h0},
	{4'hF, 4'hB, 4'h6},
	{4'h0, 4'h0, 4'h0},
	{4'h8, 4'hB, 4'h9}
};

assign {red, green, blue} = palette[index];

endmodule