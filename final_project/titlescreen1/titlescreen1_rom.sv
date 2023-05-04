module titlescreen1_rom (
	input logic clock,
	input logic [15:0] address,
	output logic [0:0] q
);

logic [0:0] memory [0:38399] /* synthesis ram_init_file = "./titlescreen1/titlescreen1.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
