module fpcollision_rom (
	input logic clock,
	input logic [17:0] address,
	output logic [0:0] q
);

logic [0:0] memory [0:153599] /* synthesis ram_init_file = "./fpcollision/fpcollision.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
