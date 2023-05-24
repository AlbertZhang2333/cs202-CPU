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
    input sys_clk, 
    input rst_in,
    input[23:0] switch,
    output[23:0] led,
    input start_pg,
    input rx,
    output tx
    );
    wire RegDst, RegWrite, MemRead, MemtoReg, MemWrite, ALUSrc, I_format, zero, Branch, nBranch, Jump, Jal, Jr, Sftmd, IORead, IOWrite;//control signal
    wire [31:0] read_data1, read_data2;//read data from register
    wire immediate; //immediate extend
    wire [31:0] ALU_addr_res; // for Branch  in IFetch.v called ALU_res
    wire [31:0] instruction;
    wire [31:0] branch_base_addr;// PC + 4
    wire [31:0] link_addr;// for jal jump to address in $ra
    wire [31:0] pc;
    wire clock; //circle
    wire[1:0] ALUOp;
    wire[31:0] MemData; //Data read from Memory(or IO ?)
    wire[31:0]ALU_result;
    wire[31:0] data_address;
    wire[31:0] reg_write_data;
    wire[5:0] opcode;
    assign opcode = instruction[31:26];
    //assign reg_write_data = (opcode == 6'b10_0011) ? mem_io_read_val : 
    //                    (opcode == 6'b00_0011) ? return_addr : result;
    wire uart_clk;
    reg uart_rst, rx_reg, uart_write_en_reg;
    wire spg_bufg, uart_clk_o, uart_write_en, uart_done, kickOff;
    wire [14:0] uart_addr;
    wire [31:0] uart_data;
    wire[15:0] switch_wdata;
    wire[23:0] led_rout;
    wire[15:0] key_wdata;
    wire LEDCtrlHigh, LEDCtrlLow, SwitchCtrlLow, SwitchCtrlHigh,  SegCtrl, BoardCtrl;

    assign kickOff = uart_rst | (~uart_rst & uart_done);
    
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
        .Jmp(Jump),
        .Jal(Jal),
        .Jr(Jr),
        .Instruction(instruction),
        .kickOff(kickOff),
        .uart_clk(uart_clk_o),
        .uart_write_en(uart_write_en & !uart_addr[14]), 
        .uart_addr(uart_addr[13:0]),
        .uart_data(uart_data),
        .uart_rst(uart_rst),
        .branch_base_addr(branch_base_addr),
        .link_addr(link_addr)
    );
    
    wire[21:0] ALU_result_high;
    assign ALU_result_high = ALU_result[31:10];
    control32 controller(
        .Opcode(instruction[31:26]),
        .Function_opcode(instruction[5:0]),
        .RegDST(RegDst),
        .Branch(Branch),
        .nBranch(nBranch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jmp(Jump),
        .Jal(Jal),
        .Jr(Jr),
        .I_format(I_format),
        .Sftmd(Sftmd),
        .ALU_result_high(ALU_result_high),
        .IORead(IORead),
        .IOWrite(IOWrite)
    );
    
    decode32 decoder(
        .clock(clock),
        .reset(rst_in),
        .Instruction(instruction),
        .mem_data(reg_write_data),
        .ALU_result(ALU_result),
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .RegDst(RegDst),
        .Jal(Jal),
        .opcplus4(link_addr),
        .read_data_1(read_data1),
        .read_data_2(read_data2),
        .Sign_extend(immediate)
    );

    MemOrIO morio(
        .memRead(MemRead),
        .memWrite(MemWrite),
        .ioRead(IORead),
        .ioWrite(IOWrite),
        .addr_in(ALU_result),
        .addr_out(data_address),
        .m_rdata(memData),
        .io_rdata_switch(switch_wdata),
        .io_rdata_board(key_wdata),
        .r_wdata(reg_write_data),
        .r_rdata(read_data2),
        .write_data(Mem_write_data),
        .LEDCtrlLow(LEDCtrlLow),
        .LEDCtrlHigh(LEDCtrlHigh),
        .SwitchCtrlLow(SwitchCtrlLow),
        .SwitchCtrlHigh(SwitchCtrlHigh),
        .SegCtrl(SegCtrl),
        .BoardCtrl(BoardCtrl)
    );

    wire ledCS = LEDCtrlLow | LEDCtrlHigh;
    wire ledAddr = {LEDCtrlHigh,LEDCtrlLow};
    leds LED(
        .ledrst(rst_in),
        .led_clk(clock),
        .ledwrite(IOWrite),
        .ledcs(ledCS),
        .ledaddr(ledAddr),
        .ledwdata(Mem_write_data),
        .ledout(led)
    );

    wire[1:0] SwitchCtrl = {SwitchCtrlHigh,SwitchCtrlLow};
    wire SwitchCS = SwitchCtrlLow | SwitchCtrlHigh; //means data from switch, not board
    switches Switch(
        .reset(rst_in),
        .ior(SwitchCS),
        .switchctrl(SwitchCtrl),
        .ioread_data_switch(switch),
        .ioread_data(switch_wdata)
    );

    wire[31:0] Mem_write_data;
    dmemory32 dmemory(
        .clock(clock),
        .memWrite(MemWrite),
        .address(data_address),
        .writeData(Mem_write_data),
        .readData(MemData),
        .kickOff(kickOff),
        .uart_clk(uart_clk),
        .uart_write_en(uart_write_en & uart_addr[14]),
        .uart_addr(uart_addr[13:0]),
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
