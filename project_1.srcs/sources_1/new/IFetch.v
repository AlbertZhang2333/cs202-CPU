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
    input[31:0] ALU_res,//instruction number calculated by ALU. PC = ALU_res * 4
    input zero,
    input read_data1, //read from register by decoder
    
    //from controller
    input Branch,
    input nBranch,
    input Jump,
    input Jal,
    input Jr,
    
    output[31:0] instruction
    );
    
    prgrom instruction_memory(
          .clka(clock),
          .addra(pc[15:2]),
          .douta(instruction)
          );
          
    reg[31:0] pc, next_pc;
    //get next pc
    always @(*) begin
        //jr 直接从$ra中读取指令地址
        if(Jr == 1'b1) begin
            next_pc <= read_data1 * 4;
        end
        //when condition of branch is true, set next pc as the ALU result
        else if(((Branch == 1'b1) && (zero == 1'b1)) || ((nBranch == 1'b1) && (zero == 1'b0))) begin
            next_pc <= ALU_res * 4;
        end
        else begin
            next_pc <= pc + 4;
        end
    end
    
    always @(negedge clock) begin
        if(reset == 1'b1) begin
            pc <= 32'h0000_0000;
        end
        else begin
        //Jump and Jal 跳转方法， Jal还要更新$ra的值（在decoder中更新？）
            if((Jump == 1'b1)|| (Jal == 1'b1)) begin
                pc <= {4'b0000, instruction[25:0],2'b00};
            end
            else begin
                pc <= next_pc;
            end
         end
      end
    
endmodule
