module sprite4dir_rom (
	input logic clock,
	input logic [11:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:2047] /* synthesis ram_init_file = "./sprite4dir/sprite4dir.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
