`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/20 09:50:10
// Design Name: 
// Module Name: decode32
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


module decode32(
    input clock,
    input reset,
    input[31:0] Instruction,
    input[31:0] mem_data,
    input[31:0] ALU_result,
    input RegWrite,
    input MemtoReg,
    input RegDst,
    input Jal,
    input[31:0] opcplus4, //pc+4
    output[31:0] read_data_1,
    output[31:0] read_data_2,
    output[31:0] Sign_extend
    );
     
     reg[31:0] register[0:31];
     
     wire[5:0] opcode; 
     wire[4:0] rs;
     wire[4:0] rt;
     reg[4:0] writeDst;
     reg[31:0] writeData;
     wire[4:0] rd;//
     assign opcode = Instruction[31:26];
     assign rs = Instruction[25:21];
     assign rt = Instruction[20:16];
     assign rd = Instruction[15:11];

     reg[31:0] Sign_extend_reg;
     assign Sign_extend = Sign_extend_reg;
     
     assign read_data_1 = register[rs];
     assign read_data_2 = register[rt];
     
     always@* begin
         if(opcode==6'b001101 || opcode == 6'b001100 || opcode == 6'b001110 || opcode == 6'b001011)begin
             Sign_extend_reg = {{16{1'b0}},Instruction[15:0]};
         end
         else begin
             Sign_extend_reg = {{16{Instruction[15]}},Instruction[15:0]};
         end
     end
     
     //determine the data to write
     always@* begin
         if(MemtoReg == 1'b0 && Jal == 1'b0) begin
             writeData <= ALU_result;
         end
         else if(Jal==1'b1)begin
             writeData <= opcplus4 ;
         end
         else begin
             writeData <= mem_data;
         end
     end
     
     //determine write which register
     always@* begin
         if(RegWrite == 1'b1)begin
             if(opcode == 6'b000011)begin
                 if(Jal == 1'b1)begin
                     writeDst <= 5'b11111;//jal
                 end
             end
             else if(RegDst==1'b1)begin
                 writeDst <= rd;
             end
             else begin
                 writeDst <= rt;
             end
         end
     end

    // write the data
    integer i;
    always@(posedge clock) begin
        if(reset==1'b1) begin
            for(i = 0; i < 32; i = i + 1) register[i] <= 0;
        end
        else if(RegWrite==1'b1 && writeDst!=5'd0)begin
            register[writeDst] <= writeData;
        end
    end
 
 endmodule