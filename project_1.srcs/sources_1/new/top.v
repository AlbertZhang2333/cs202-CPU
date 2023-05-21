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
    input sys_clk, //系统时钟
    input rst_in,
    input[23:0] switch,
    output[23:0] led,
    input start_pg,
    input rx,
    output tx
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
    
    wire uart_clk;
    reg uart_rst, rx_reg, uart_write_en_reg;
    wire spg_bufg, uart_clk_o, uart_write_en, uart_done, kickOff;
    wire [14:0] uart_addr;
    wire [31:0] uart_data;
    
    
    cpuclk clock1(
        .clk_in1(sys_clk),
        .clk_out1(clock),
        .clk_out2(uart_clk)
    );
    
    IFetch Ifetch(
        .clock(clock),
        .reset(rst_in),
        .ALU_res(ALU_addr_res),
        .zero(zero),
        .read_data1(read_data1),
        .Branch(Branch),
        .nBranch(nBranch),
        .Jump(Jump),
        .Jal(Jal),
        .Jr(Jr),
        .instruction(instruction),
        .kickOff(kickOff),
        .uart_clk(uart_clk_o),
        .uart_write_en(uart_write_en & !uart_addr[13]), 
        .uart_addr(uart_addr),
        .uart_data(uart_data)
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
        .reset(rst_in),
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
        .readData(MemData),
        .kickOff(kickOff),
        .uart_clk(uart_clk),
        .uart_write_en(uart_write_en & uart_addr[13]),
        .uart_addr(uart_addr),
        .uart_data(uart_data)
    );
    
    uart_bmpg_0 uart(
            .upg_clk_i(uart_clk),
            .upg_rst_i(uart_rst),
            .upg_rx_i(rx),
            .upg_clk_o(uart_clk_o),
            .upg_wen_o(uart_write_en),
            .upg_adr_o(uart_addr),
            .upg_dat_o(uart_data),
            .upg_done_o(uart_done),
            .upg_tx_o(tx)
        );
        
        BUFG U1(.I(start_pg), .O(spg_bufg));
         always@(posedge sys_clk) begin
            if(spg_bufg) uart_rst = 0;
            if(rst_in) uart_rst = 1;
            if (uart_rst) begin
                rx_reg = 0;
                uart_write_en_reg = 0;
            end
            else begin
                if (!rx) rx_reg = 1;
                if (uart_write_en) uart_write_en_reg = 1;
            end
          end
          
endmodule
