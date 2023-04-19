`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/18 22:14:16
// Design Name: 
// Module Name: data_memory
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
module data_memory(
    input clock,
    input memWrite,
    input[31:0] address,
    input[31:0] writeData,
    input[31:0]readData
    );
wire clk;
RAM data_memory(
    .clka(clk), 
    .wea(memWrite), 
    .addra(address[15:2]),
    .dina(writeData),
    .douta(readData)
    );
assign clk = !clock;
endmodule