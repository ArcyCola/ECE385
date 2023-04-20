module mapfullscale_rom (
	input logic clock,
	input logic [19:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:614399] /* synthesis ram_init_file = "./mapfullscale/mapfullscale.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
