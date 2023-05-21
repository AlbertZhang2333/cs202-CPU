`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/21 13:45:27
// Design Name: 
// Module Name: decoder_sim
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


module decoder_sim();
reg clock = 1'b0;
always #20 clock = ~clock;
reg[31:0] instruction;
reg[31:0] mem_data;
wire[31:0] ALU_result;
reg Jal;
reg RegWrite;
reg MemtoReg;
reg RegDst;
wire reset;
wire[31:0] opcplus4;
wire[31:0] read_data_1;
wire[31:0] read_data_2;
wire[31:0] Sign_extend;
decode32 decoder1(clock, reset, instruction, mem_data, ALU_result, RegWrite, MemtoReg, RegDst, Jal, opcplus4, read_data_1, read_data_2, Sign_extend);
initial begin
    instruction = 32'b10001110001010000000000000100000;//lw t0
    #200 instruction = 32'b10001110001010010000000000100000;//lw t1
    #200 instruction = 32'b00000001001010000101000000100000;//add t2 t1 t0
    #200 instruction = 32'b00000001001010100101100000100000;//add t3 t1 t2
end

initial begin
    mem_data = 32'b00000000000000000000000000000001;
    #200 mem_data = 32'b00000000000000000000000000000010;
end

assign ALU_result = read_data_1 + read_data_2;
assign reset = 1'b0;
assign opcplus4 = 32'b00000000000000000000000000000000; 

initial begin
    {Jal, RegWrite, MemtoReg, RegDst} <= 4'b0110;
    #200 {Jal, RegWrite, MemtoReg, RegDst} <= 4'b0111;
end
endmodule
