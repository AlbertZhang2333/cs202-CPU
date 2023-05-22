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
        //jr 直接从$ra中读取指令地址
        if(Jr == 1'b1) begin
            next_pc <= read_data1;
        end
        //when condition of branch is true, set next pc as the ALU result
        else if(((Branch == 1'b1) && (zero == 1'b1)) || ((nBranch == 1'b1) && (zero == 1'b0))) begin
            next_pc <= ALU_res;
        end
        else begin
            next_pc <= pc + 4;
        end
    end
    
    always @Jal begin
        if(Jal == 1)begin
            link_addr = pc + 4;
        end
    end

    always @(negedge clock) begin
        if(reset == 1'b1) begin
            pc <= 32'h0000_0000;
        end
        else begin
        //Jump and Jal 跳转方法， Jal还要更新$ra的值（在decoder中更新？）
            if((Jmp == 1'b1)|| (Jal == 1'b1)) begin
                pc <= {4'b0000, Instruction[25:0],2'b00};
            end
            else begin
                pc <= next_pc;
            end
         end
      end
    
    assign branch_base_addr = pc + 4;
endmodule
