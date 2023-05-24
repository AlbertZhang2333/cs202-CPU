`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/09 14:46:15
// Design Name: 
// Module Name: IFetch
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


module IFetch(
    input clock,
    input reset,
    input[31:0] ALU_res,//instruction address calculated by ALU. 
    input zero,
    input read_data1, //read from register by decoder
    
    //from controller
    input Branch,
    input nBranch,
    input Jmp,
    input Jal,
    input Jr,
    
    input kickOff,
    input uart_rst,
    input uart_addr,
    input uart_data,
    input uart_clk,
    input uart_write_en,    
    output[31:0] Instruction,
    output[31:0] branch_base_addr,
    output reg[31:0] link_addr //pc + 4
    );
    
    programrom instruction_memory(
          .clka(kickOff ? clock : uart_clk),
          .addra(kickOff ? pc[15:2] : uart_addr),
          .douta(Instruction),
          .dina(kickOff ? 32'h00000000 : uart_data),
          .wea(kickOff ? 1'b0 : uart_write_en)
          );
          
    reg[31:0] pc, next_pc;
    //get next pc
    always @(*) begin
         //Jump and Jal ��ת������ Jal��Ҫ����$ra��ֵ����decoder�и��£���
        if(((Branch == 1) && (zero == 1 )) || ((nBranch == 1) && (zero == 0))) 
            next_pc = ALU_res << 2; 
        else if(Jr == 1) next_pc = read_data1 << 2; //jr ֱ�Ӵ�$ra�ж�ȡָ���ַ
        else if ((Jmp == 1) || (Jal == 1)) next_pc = {pc[31:28], Instruction[25:0], 2'b00};
        else next_pc = pc + 4; 
    end
    
    always @(negedge clock) begin
        if(Jal == 1 || Jmp == 1)begin
            link_addr <= (pc + 4) >> 2;
        end
    end

    always @(negedge clock) begin
        if(reset == 1'b1) begin
            pc <= 32'h0000_0000;
        end
        else begin
            pc <= next_pc;
        end
      end
    
    assign branch_base_addr = pc + 4;
endmodule
