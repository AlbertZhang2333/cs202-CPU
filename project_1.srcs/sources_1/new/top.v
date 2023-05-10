`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/18 22:22:41
// Design Name: 
// Module Name: top
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


module top(
    input clk, //系统时钟
    input rst,
    input[23:0] switch,
    output[23:0] led
    );
    wire RegDst, RegWrite, MemRead, MemtoReg, MemWrite, ALUSrc, I_format, zero, Branch, nBranch, Jump, Jal, Jr;//控制信号
    wire [31:0] read_data1, read_data2;//寄存器的值， jr可能用($ra) read_data1
    wire immediate; //immediate extend
    wire [31:0] ALU_addr_res; // for Branch 见IFetch.v ALU_res
    wire [31:0] instruction;
    wire [31:0] branch_base_addr;// PC + 4
    wire [31:0] link_addr;// for jal 给$ra寄存器保存的指令
    wire [31:0] pc;
    wire clock; //circle
    wire[1:0] ALUOp;
    wire[31:0] MemData; //Data read from Memory(or IO ?)
    wire[31:0]ALU_result;
    wire[31:0] data_address;
    cpuclk clock1(
        .clk_in1(clk),
        .clk_out1(clock)
    );
    IFetch Ifetch(
        .clock(clock),
        .reset(rst),
        .ALU_res(ALU_addr_res),
        .zero(zero),
        .read_data1(read_data1),
        .Branch(Branch),
        .nBranch(nBranch),
        .Jump(Jump),
        .Jal(Jal),
        .Jr(Jr),
        .instruction(instruction)
    );
    
    controller con(
        .op(instruction[31:26]),
        .function_code(instruction[5:0]),
        .RegDst(RegDst),
        .Branch(Branch),
        .nBranch(nBranch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jump(Jump),
        .Jal(Jal),
        .Jr(Jr),
        .I_format(I_format)
    );
    
    Decoder decoder(
        .clk(clock),
        .reset(rst),
        .instruction(instruction),
        .MemData(MemData),
        .ALU_result(ALU_result),
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .RegDst(RegDst),
        .jal(Jal),
        .pc(pc),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .immediate(immediate)
    );
    wire[31:0] Mem_write_data;
    data_memory dmemery(
        .clock(clock),
        .memWrite(MemWrite),
        .address(data_address),
        .writeData(Mem_write_data),
        .readData(MemData)
    );
endmodule
