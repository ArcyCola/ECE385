module sprite4dir2_rom (
	input logic clock,
	input logic [10:0] address,
	output logic [2:0] q
);

logic [2:0] memory [0:1063] /* synthesis ram_init_file = "./sprite4dir2/sprite4dir2.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
