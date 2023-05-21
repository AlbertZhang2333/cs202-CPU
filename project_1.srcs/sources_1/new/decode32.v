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
    output reg[31:0] Sign_extend
    );
    
    //read from registers
    reg[0:31] registers;
    assign read_data_1 = registers[Instruction[25:21]];
    assign read_data_2 = registers[Instruction[20:16]];
    
    //write data into registers
    reg[4:0] writeDst;
    reg[31:0] writeData;
    
    //determine write which register
    always @(posedge clock) begin
        if(RegWrite == 1'b1)begin
            if(Jal == 1'b1) begin
                writeDst <= 5'b11111;
            end
            else if(RegDst == 1'b1) begin
                writeDst <= Instruction[15:11]; //rd 
            end
            else begin
                writeDst <= Instruction[20:16]; //rt
            end
        end
    end
    
    //determine the data to write
    always @(posedge clock) begin
        if(RegWrite == 1'b1) begin
            if(Jal == 1'b1) begin
                writeData <= opcplus4;
            end
            else if(MemtoReg == 1'b0)begin
                writeData <= ALU_result;
            end
            else if(MemtoReg == 1'b1) begin
                writeData <= mem_data;
            end
        end
    end
    
    //write
    integer i;
    always @(negedge clock) begin
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
    assign sign = Instruction[15];
    wire[15:0] sign_extend;
    assign sign_extend = (sign == 1'b1)? 16'b1111_1111_1111_1111:16'b0000_0000_0000_0000;
    always @(posedge clock) begin
        if(Instruction[31:26] == 6'b001101 || Instruction[31:26] == 6'b001101) begin
            Sign_extend <= {16'b0000_0000_0000_0000,Sign_extend};
        end
        else begin
            Sign_extend <= {sign_extend,Instruction[15:0]};
        end
    end
endmodule
