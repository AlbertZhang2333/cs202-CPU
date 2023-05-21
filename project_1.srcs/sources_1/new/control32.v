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


module control32(
input[5:0] Opcode,
input[5:0] Function_opcode,
output RegDST,
output Branch, //beq
output nBranch,//bne
output MemRead,
output MemtoReg,
output[1:0] ALUOp,
output MemWrite,
output ALUSrc,
output RegWrite,
output Jmp,
output Jal,
output Jr,
output I_format,
output Sftmd,
input [21:0] ALU_result_high,
output IORead,
output IOWrite
    );

wire R_format = (Opcode==6'b000000) ? 1'b1 : 1'b0;
wire Lw,Sw;

assign Sw = (Opcode == 6'b101011) ? 1'b1:1'b0;
assign Lw = (Opcode == 6'b100011) ? 1'b1:1'b0;
assign RegDST = R_format;
assign Branch  = (Opcode == 6'b000100) ? 1'b1:1'b0;
assign nBranch = (Opcode == 6'b000101) ? 1'b1:1'b0;
assign ALUSrc = I_format || Lw || Sw;
assign Sftmd = (R_format==1'b1 && (Function_opcode==6'b000000 || Function_opcode==6'b000100 || 
Function_opcode==6'b000010 || Function_opcode==6'b000110 || Function_opcode==6'b000011 || 
Function_opcode==6'b000111))?1'b1:1'b0;//if shift,set 1
assign RegWrite = (R_format || Lw || Jal || I_format) && !(Jr) ;
assign I_format = (Opcode[5:3]==3'b001)? 1'b1:1'b0;
assign ALUOp = {(R_format||I_format),(Branch||nBranch)};

assign Jr = (Opcode == 6'b000000 && Function_opcode==6'b001000)?1'b1:1'b0;
assign Jmp = (Opcode == 6'b000010) ? 1'b1:1'b0;
assign Jal = (Opcode == 6'b000011) ? 1'b1:1'b0;

assign MemWrite = ((Sw==1) && (ALU_result_high != 22'h3FFFFF)) ? 1'b1:1'b0; 
assign MemRead = ((Lw==1) && (ALU_result_high != 22'h3FFFFF)) ? 1'b1:1'b0;
assign IORead = ((Lw==1) && (ALU_result_high == 22'h3FFFFF)) ? 1'b1:1'b0;
assign IOWrite = ((Sw==1) && (ALU_result_high == 22'h3FFFFF)) ? 1'b1:1'b0;

assign MemtoReg = IORead || MemRead;

endmodule