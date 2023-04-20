module map480pt2_rom (
	input logic clock,
	input logic [17:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:153599] /* synthesis ram_init_file = "./map480pt2/map480pt2.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
