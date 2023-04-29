module spritedraft_palette (
	input logic [3:0] index,
	output logic [3:0] red, green, blue
);

localparam [0:15][11:0] palette = {
	{4'hF, 4'hC, 4'h6}, //0
	{4'h7, 4'h3, 4'h4}, //1
	{4'h0, 4'h0, 4'h0}, //2
	{4'hB, 4'hA, 4'hD}, //3
	{4'hF, 4'h6, 4'h4}, //4
	{4'h3, 4'h3, 4'h7}, //5
	{4'hB, 4'h3, 4'h3}, //6
	{4'hD, 4'h9, 4'h6}, //7
	{4'hE, 4'hE, 4'hF}, //8
	{4'h7, 4'h9, 4'hB}, //9
	{4'h6, 4'h2, 4'h2}, //10
	{4'hF, 4'hB, 4'h9}, //11
	{4'hA, 4'h7, 4'h3}, //12
	{4'hF, 4'hC, 4'h6}, //13
	{4'hF, 4'h6, 4'h4}, //14
	{4'h0, 4'h0, 4'h0} //15
};

assign {red, green, blue} = palette[index];

endmodule
