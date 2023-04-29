module spritedraft_rom (
	input logic clock,
	input logic [8:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:265] /* synthesis ram_init_file = "./spritedraft/spritedraft.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
