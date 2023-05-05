module titlescreen_palette (
	input logic [0:0] indexIntro, indexEnd, 
	output logic [3:0] redIntro, greenIntro, blueIntro,
	output logic [3:0] redEnd, greenEnd, blueEnd
);

localparam [0:1][11:0] palette = {
	{4'hF, 4'hF, 4'hF},
	{4'h9, 4'h5, 4'h1}
};

assign {redIntro, greenIntro, blueIntro} = palette[indexIntro];
assign {redEnd, greenEnd, blueEnd} = palette[~indexEnd];

endmodule
