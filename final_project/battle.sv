module battle (input [15:0] keycode,
               input frame_clk,
               output [7:0] AEHealth, ZuofuHealth)

    logic move;

    //move is to determine who's move, 0 = player, 1 = zuofu
    assign move = 0;

    assign AEHealth = 100;
    assign ZuofuHealth = 100;


always_ff @ (posedge frame_clk) 
begin
    
end






endmodule