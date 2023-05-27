`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/26 16:35:26
// Design Name: 
// Module Name: top_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_sim(    );

reg                 clk,rst,spg,rx;
wire                tx,cpu,uart;
reg     [18:0]      sw;
wire    [31:0]      led;

top u1(
    .sys_clk(clk),
    .rst_in(rst),
    .switch(sw),
    .led(led),
    .start_pg(spg),
    .rx(rx),
    .tx(tx),
    .CPUMood(cpu),
    .UARTMood(uart)
);

initial begin
    clk = 1'b0;
    rst = 1'b1;
    spg = 1'b0;
    rx = 1'b1;
    sw = {2'b0,16'h0000};
    #5 rst = 1'b0;
end

always
    #1 clk = ~clk;

always @(negedge spg) begin
    if(spg)
        rx = 1'b1;
    else
        rx = 1'b0;
end
endmodule
