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


module IFetch(clock,reset, ALU_res,zero, read_data1, Branch, nBranch,
    Jmp,Jal,Jr,kickOff,uart_rst,uart_addr,uart_data,uart_clk,uart_write_en,   
    Instruction,branch_base_addr,link_addr);
    input clock;
    input reset;
    input[31:0] ALU_res;//instruction address calculated by ALU. 
    input zero;
    input[31:0] read_data1; //read from register by decoder
    
    //from controller
    input Branch;
    input nBranch;
    input Jmp;
    input Jal;
    input Jr;
    
    input kickOff;
    input uart_rst;
    input uart_addr;
    input uart_data;
    input uart_clk;
    input uart_write_en; 
    /* input send,
    output reg syscall,  */  
    output[31:0] Instruction;
    output[31:0] branch_base_addr;
    output reg[31:0] link_addr; //pc + 4
    //wire rom_clk = !clock;
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
        if(Jr == 1'b1) 
        next_pc <= read_data1; //jr 
        else if(((Branch == 1) && (zero == 1'b1)) || ((nBranch == 1'b1) && (zero == 1'b0))) 
            next_pc <= ALU_res; 
        else next_pc <= pc + 4; 
    end

    /* always @(negedge send) begin
        pc <= next_pc;
        syscall <= 1'b0;
    end */

    always @(negedge clock) begin
        if(reset == 1'b1) begin
            pc <= 32'h0000_0000;
        end
        /* else if(Instruction == 32'h0000000C)begin
            pc <= pc;
            syscall <= 1'b1;
        end */
        else begin
            
            //Jump and Jal 
            if ((Jmp == 1'b1) || (Jal == 1'b1)) 
            begin
                link_addr <= next_pc;
                pc <= {pc[31:28], Instruction[25:0], 2'b00};
            end
            else
            pc <= next_pc;
        end
      end
    
    assign branch_base_addr = pc + 4;
endmodule
