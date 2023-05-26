`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 14:36:40
// Design Name: 
// Module Name: executs32
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
///////////////////////////////////////////////////////////////////////////////////////////////////


module executs32 (
        Read_data_1,
        Read_data_2,
        Sign_extend,
        Function_opcode,
        Exe_opcode,
        ALUOp,
        Shamt,
        ALUSrc,
        I_format,
        Zero,
        Jr,
        Sftmd,
        ALU_Result,
        Addr_Result,
        PC_plus_4
    );
    input[31:0] Read_data_1; // 来自解码单元的读入数据1
    input[31:0] Read_data_2; // 来自解码单元的读入数据2
    input[31:0] Sign_extend; // 来自解码单元的立即数扩展结果
    input[5:0] Function_opcode; // 来自指令解析单元的R型指令的功能码（6位）
    input[5:0] Exe_opcode; // 来自指令解析单元的指令操作码
    input[1:0] ALUOp; // 来自控制单元的ALU操作控制码
    input[4:0] Shamt; // 来自取指单元的指令[10:6]，指定位移的位数
    input Sftmd; // 来自控制单元，仅有一位，指示是否为位移指令
    input ALUSrc; // 来自控制单元，指示第二个操作数是否为立即数（除了beq、bne指令）
    input I_format; //来自控制单元，指示是否为除了beq、bne、LW、SW之外的I型指令
    input Jr; // 来自控制单元，指示是否为JR指令
    output Zero; // 当计算结果为0时为1，否则为0
    output reg [31:0] ALU_Result; // 输出计算结果数据
    output[31:0] Addr_Result; // 输出计算结果地址        
    input[31:0] PC_plus_4; // 来自取指单元的PC+4

    wire [31:0] operand1, operand2;  //OP1记录数据1
    wire[5:0] exe_code; //用于存储指令的功能码，R和I有区别
    wire[2:0] ALU_con; // 控制ALU，不同位数不同ALU进行不同的计算
    reg[31:0] Shift_Result; // the result of shift operation
    reg[31:0] AL_result; // 存储算数逻辑结果
    wire [31:0] Branch_Addr;

    assign operand1     = Read_data_1;
    assign operand2     = (ALUSrc == 0) ? Read_data_2 : Sign_extend[31:0];

    assign exe_code   = (I_format == 0) ? Function_opcode : {3'b000, Exe_opcode[2:0]};
    assign ALU_con[0] = (exe_code[0] | exe_code[3]) & ALUOp[1];
    assign ALU_con[1] = ((!exe_code[2]) | (!ALUOp[1]));
    assign ALU_con[2] = (exe_code[1] & ALUOp[1]) | ALUOp[0];
    always @(ALU_con or operand1 or operand2)
    begin
        case (ALU_con)
            3'b000: AL_result =operand1 & operand2;
            3'b001:  AL_result= operand1 | operand2;
            3'b010:  AL_result=$signed(operand1) + $signed(operand2);
            3'b011:  AL_result= operand1 + operand2;
            3'b100: AL_result= operand1 ^ operand2;
            3'b101: AL_result=~(operand1 | operand2);
            3'b110: AL_result=$signed(operand1) - $signed(operand2);
            3'b111:AL_result= operand1 - operand2;
            default: AL_result = 0;
        endcase
    end
    
    always @*
    begin
        //set type operation (slt, slti, sltu, sltiu)
        if (((ALU_con == 3'b111) && (exe_code[3] == 1'b1)) || ((ALU_con[2:1] == 2'b11) && (I_format == 1)))
            ALU_Result = AL_result[31] == 1 ? 1 : 0;
        //lui operation
        else if ((ALU_con == 3'b101) && (I_format == 1))
            ALU_Result[31:0] = {operand2[15:0], 16'b0};
        //shift operation
        else if (Sftmd == 1)
            ALU_Result = Shift_Result;
        //other types of operation in ALU (arithmatic or logic calculation)
        else
            ALU_Result = AL_result[31:0];
    end

    // 以下是移位指令
     always @* begin 
        if(Sftmd)
        case(Function_opcode[2:0])
            3'b000:Shift_Result <= operand2 << Shamt; //Sll rd,rt,shamt 00000
            3'b010:Shift_Result <= operand2 >> Shamt; //Srl rd,rt,shamt 00010
            3'b100:Shift_Result <= operand2 << operand1; //Sllv rd,rt,rs 00010
            3'b110:Shift_Result <= operand2 >> operand1; //Srlv rd,rt,rs 00110
            3'b011:Shift_Result <= $signed(operand2) >>> $signed(Shamt); //Sra rd,rt,shamt 00011
            3'b111:Shift_Result <= $signed(operand2) >>>  $signed(operand1); //Srav rd,rt,rs 00111
            default:Shift_Result <= operand2;
        endcase
        else
            Shift_Result <= operand2;// 如果不是移位指令，则直接把OP2的值复制给结果
    end

    assign Zero        = (AL_result == 32'h0000_0000) ? 1'b1 : 1'b0;
    assign Branch_Addr = ALUOp[0] ? {{14{operand2[15]}}, operand2[15:0], 2'b0} : PC_plus_4;
    assign Addr_Result = PC_plus_4 + (Sign_extend << 2);
endmodule