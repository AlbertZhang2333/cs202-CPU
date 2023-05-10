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
input[5:0] function_code,
output RegDst,
output Branch, //beq与ALU输出的zero混合判断
output nBranch,//bne
output MemRead,
output MemtoReg,
output[1:0] ALUOp,
output MemWrite,
output ALUSrc,
output RegWrite,
output Jump,
output Jal,
output Jr,
output I_format
    );
    //op[5] & op[4] & op[3] & op[2] & op[1] & op[0]
    assign RegDst = ~op[5] & ~op[4] & ~op[3] & ~op[1] & ~op[0];
    assign ALUSrc = op[5] & ~op[4] & ~op[2] & op[1] & op[0];
    assign MemtoReg = op[5] & ~op[4] & ~op[2] & op[1] & op[0];
    assign RegWrite = ~op[5] & ~op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0] | op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];
    assign MemRead = op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];
    assign MemWrite = op[5] & ~op[4] & op[3] & ~op[2] & op[1] & op[0];
    assign Branch = ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & ~op[0];
    assign nBranch = ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & op[0];
    assign ALUOp[1] = ~op[5] & ~op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0];
    assign ALUOp[0] = ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & ~op[0];
    assign Jump = ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & ~op[0];
    assign Jal = ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];
    assign Jr = ~function_code[5] & ~function_code[4] & function_code[3] & ~function_code[2] & ~function_code[1] & ~function_code[0] & ~op[5] & ~op[4] & ~op[3] & ~op[1] & ~op[0];
    assign I_format = ~function_code[5] & ~function_code[4] & function_code[3];
endmodule
