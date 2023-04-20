`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/20 09:50:10
// Design Name: 
// Module Name: Decoder
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


module Decoder(
    input[31:0] instruction,
    input[31:0] MemData,
    input[31:0] ALU_result,
    input RegWrite,
    input MemtoReg,
    input RegDst,
    input clk,
    input reset,
    input jal,
    input[31:0] pc, //pc+4
    output[31:0] read_data1,
    output[31:0] read_data2,
    output reg[31:0] immediate
    );
    
    //read from registers
    reg[0:31] registers;
    assign read_data1 = registers[instruction[25:21]];
    assign read_data2 = registers[instruction[20:16]];
    
    //write data into registers
    reg[4:0] writeDst;
    reg[31:0] writeData;
    
    //determine write which register
    always @(posedge clk) begin
        if(RegWrite == 1'b1)begin
            if(jal == 1'b1) begin
                writeDst <= 5'b11111;
            end
            else if(RegDst == 1'b1) begin
                writeDst <= instruction[15:11]; //rd 
            end
            else begin
                writeDst <= instruction[20:16]; //rt
            end
        end
    end
    
    //determine the data to write
    always @(posedge clk) begin
        if(RegWrite == 1'b1) begin
            if(jal == 1'b1) begin
                writeData <= pc;
            end
            else if(MemtoReg == 1'b0)begin
                writeData <= ALU_result;
            end
            else if(MemtoReg == 1'b1) begin
                writeData <= MemData;
            end
        end
    end
    
    //write
    integer i;
    always @(negedge clk) begin
        if(reset == 1'b1)begin
            for(i = 0; i < 32; i = i + 1) registers[i] <= 0;
        end
        else begin
            if(RegWrite == 1'b1) begin
                registers[writeDst] <= writeData;
            end
        end
    end
    
    //the sign bit extend of the immediate
    wire sign;
    assign sign = instruction[15];
    wire[15:0] sign_extend;
    assign sign_extend = (sign == 1'b1)? 16'b1111_1111_1111_1111:16'b0000_0000_0000_0000;
    always @(posedge clk) begin
        if(instruction[31:26] == 6'b001101 || instruction[31:26] == 6'b001101) begin
            immediate <= {16'b0000_0000_0000_0000,immediate};
        end
        else begin
            immediate <= {sign_extend,instruction[15:0]};
        end
    end
endmodule
