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
    input           sys_clk, 
    input           rst_in,
    input   [18:0]  switch,
    input           start_pg,
    input           rx,
    output  [15:0]  led,
    output          tx,
    output          CPUMood,
    output          UARTMood,
        output  [7:0]   seg_out,
        output  [7:0]   seg_en
    );

    wire            RegDst, RegWrite, MemRead, MemtoReg, MemWrite, ALUSrc, I_format, zero, Branch, nBranch, Jump, Jal, Jr, Sftmd, IORead, IOWrite;//control signal
    wire    [31:0]  read_data1, read_data2;//read data from register
    wire    [31:0]  immediate; //immediate extend
    wire    [31:0]  ALU_addr_res; // for Branch  in IFetch.v called ALU_res
    wire    [31:0]  instruction;
    wire    [31:0]  branch_base_addr;// PC + 4
    wire    [31:0]  link_addr;// for jal jump to address in $ra
    wire    [31:0]  pc;
    wire            clock; //circle
    wire    [1:0]   ALUOp;
    wire    [31:0]  MemData; //Data read from Memory(or IO ?)
    wire    [31:0]  ALU_result;
    wire    [31:0]  data_address;
    wire    [31:0]  reg_write_data;
    wire    [5:0]   opcode;

    assign opcode = instruction[31:26];
    //assign reg_write_data = (opcode == 6'b10_0011) ? mem_io_read_val : 
    //                    (opcode == 6'b00_0011) ? return_addr : result;

    wire            uart_clk;
    reg             uart_rst, rx_reg, uart_write_en_reg;
    wire            uart_clk_o, uart_write_en, uart_done, kickOff,spg_bufg;
    wire    [14:0]  uart_addr;
    wire    [31:0]  uart_data;
    wire    [18:0]  switch_wdata;
    wire    [23:0]  led_rout;
    wire    [18:0]  key_wdata;
    wire            LEDCtrl, SwitchCtrl, SegCtrl, BoardCtrl;
    wire            rst_nu;
    assign kickOff = uart_rst | (~uart_rst & uart_done);
    assign rst_nu = rst_in | !uart_rst;
    assign CPUMood = kickOff;
    assign UARTMood = ~kickOff;
    cpuclk clock1(
        .clk_in1(sys_clk),
        .clk_out1(clock),
        .clk_out2(uart_clk)
    );
    
    IFetch Ifetch(
        .clock(clock),
        .reset(rst_nu),
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
        .uart_write_en(uart_write_en & !uart_addr[14]),  //uart_write_en & uart_addr[14]
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
        .reset(rst_nu),
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

    wire[31:0] Mem_write_data;
    MemOrIO morio(
        .memRead(MemRead),
        .memWrite(MemWrite),
        .ioRead(IORead),
        .ioWrite(IOWrite),
        .addr_in(ALU_result),
        .addr_out(data_address),
        .m_rdata(MemData),
        .io_rdata_switch(switch_wdata),
        .io_rdata_board(key_wdata),
        .r_wdata(reg_write_data),
        .r_rdata(read_data2),
        .write_data(Mem_write_data),
        .LEDCtrl(LEDCtrl),
        .SwitchCtrl(SwitchCtrl),
        .SegCtrl(SegCtrl),
        .BoardCtrl(BoardCtrl)
    );

    executs32 alu(
        .Read_data_1(read_data1),
        .Read_data_2(read_data2),
        .Sign_extend(immediate),
        .Function_opcode(instruction[5:0]),
        .Exe_opcode(instruction[31:26]),
        .ALUOp(ALUOp),
        .Shamt(instruction[10:6]),
        .Sftmd(Sftmd),
        .ALUSrc(ALUSrc),
        .I_format(I_format),
        .Jr(Jr),
        .Zero(zero),
        .ALU_Result(ALU_result),
        .Addr_Result(ALU_addr_res),
        .PC_plus_4(branch_base_addr)
    );

    wire LEDC = 1'b1;
    wire[31:0] out1 = {Mem_write_data};
    leds LED(
        .ledrst(rst_nu),
        .led_clk(clock),
        .ledcs(LEDCtrl),
        .ledwdata(Mem_write_data),
        .ledout(led)
    );

    switches Switch(
        .reset(rst_nu),
        .switchctrl(SwitchCtrl),
        .ioread_data_switch(switch),
        .ioread_data(switch_wdata)
    );

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
        .uart_data(uart_data),
        .uart_rst(uart_rst),
        .uart_done(uart_done)
    );

    segs seg(
        .clk(sys_clk),
        .rst(rst_nu),
        .segCtrl(SegCtrl),
        .data_in(Mem_write_data),
        .seg_o_0(seg_out),
        .seg_en(seg_en)
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
        
    /* always @(start_pg) begin
        if (rst_in) spg_bufg <= 0;
        else spg_bufg <= ~spg_bufg;
    end */
        BUFG U1(.I(start_pg), .O(spg_bufg));
         always@(posedge sys_clk) begin
            if(spg_bufg) uart_rst = 0;
            if(rst_in) uart_rst = 1;
            /* if (uart_rst) begin
                rx_reg = 0;
                uart_write_en_reg = 0;
            end
            else begin
                if (!rx) rx_reg = 1;
                if (uart_write_en) uart_write_en_reg = 1;
            end */
        end
    //    always @(posedge sys_clk) begin
    //     if(spg_bufg) begin
    //         CPUMood <= 1'b0;
    //         UARTMood <= 1'b1;
    //     end
    //     if(rst_in) begin
    //         CPUMood <= 1'b1;
    //         UARTMood <= 1'b0;
    //     end
        
    // end
          
endmodule
