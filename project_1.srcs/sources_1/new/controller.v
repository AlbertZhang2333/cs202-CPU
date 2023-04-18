`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/17 14:05:28
// Design Name: 
// Module Name: controller
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


module controller(
input[5:0] op,
output RegDst,
output Branch,
output MemRead,
output MemtoReg,
output[1:0] ALUOp,
output MemWrite,
output ALUSrc,
output RegWrite,
output Jump
    );
    //op[5] & op[4] & op[3] & op[2] & op[1] & op[0]
    assign RegDst = ~op[5] & ~op[4] & ~op[3] & ~op[1] & ~op[0];
    assign ALUSrc = op[5] & ~op[4] & ~op[2] & op[1] & op[0];
    assign MemtoReg = op[5] & ~op[4] & ~op[2] & op[1] & op[0];
    assign RegWrite = ~op[5] & ~op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0] | op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];
    assign MemRead = op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];
    assign MemWrite = op[5] & ~op[4] & op[3] & ~op[2] & op[1] & op[0];
    assign Branch = ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & ~op[0];
    assign ALUOp[1] = ~op[5] & ~op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0];
    assign ALUOp[0] = ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & ~op[0];
    assign Jump = ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & ~op[0];
endmodule
