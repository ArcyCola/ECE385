module fpcollision_rom (
	input logic clock,
	input logic [17:0] addr1,// addr2, addr3, addr4,
	output logic q1
	//, q2, q3, q4
);

logic memory [0:153599] /* synthesis ram_init_file = "./fpcollision/fpcollision.mif" */;

always_ff @ (posedge clock) begin
	q1 <= {memory[addr1]};
//	q2 <= {memory[addr2]};
//	q3 <= {memory[addr3]};
//	q4 <= {memory[addr4]};
end

endmodule
