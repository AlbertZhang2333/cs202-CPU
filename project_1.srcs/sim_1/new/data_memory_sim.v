`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/18 22:23:22
// Design Name: 
// Module Name: data_memory_sim
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


module data_memory_sim(  );
reg clock = 1'b0;
reg memWrite = 1'b0;
reg [31:0] addr = 32'h0000_0010;
reg [31:0] writeData = 32'h1000_0000;
wire [31:0] readData;
data_memory uram
(clock,memWrite,addr,writeData,readData);
always #50 clock = ~clock;
initial begin
addr = 32'h0000_0020;
#100 addr = 32'h0000_0024;
#100 addr = 32'h0000_0028;
#100 addr = 32'h0000_002c;
#100 addr = 32'h0000_0030;
#100 addr = 32'h0000_0034;
#100 memWrite = 1'b1;
addr = 32'h0000_0048;
#200 memWrite = 1'b0;
end 
endmodule
