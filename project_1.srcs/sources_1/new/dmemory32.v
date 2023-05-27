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
module dmemory32(clock,memWrite,address,writeData,readData,kickOff,uart_clk,uart_write_en,uart_addr,uart_data, uart_rst, uart_done);
    input clock;
    input memWrite;
    input[31:0] address;
    input[31:0] writeData;
    output[31:0]readData;
    input kickOff;
    input uart_clk;
    input uart_write_en;
    input[13:0] uart_addr;
    input[31:0] uart_data;
    input uart_rst;
    input uart_done;
wire clk;
/* RAM data_memory(
    .clka(kickOff ? clk : uart_clk), 
    .wea(kickOff ? memWrite : uart_write_en), 
    .addra(kickOff ? address[15:2] : uart_addr),
    .dina(kickOff ? writeData : uart_data),
    .douta(readData)
    ); */

RAM data_memory(
    .clka(clk), 
    .wea(memWrite), 
    .addra(address[15:2]),
    .dina(writeData),
    .douta(readData)
    );
assign clk = !clock;
endmodule