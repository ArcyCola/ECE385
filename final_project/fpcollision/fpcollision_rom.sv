module fpcollision_rom (
	input logic clock,
	input logic [17:0] addrX, addrY,// addr3, addr4,
	output logic qX, qY//, q3, q4
);

logic memory [0:153599] /* synthesis ram_init_file = "./fpcollision/fpcollision.mif" */;

always_ff @ (posedge clock) begin
	qX <= {memory[addrX]};
	qY <= {memory[addrY]};
//	q3 <= {memory[addr3]};
//	q4 <= {memory[addr4]};
end

endmodule
