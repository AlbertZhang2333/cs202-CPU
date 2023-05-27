`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/27 23:02:29
// Design Name: 
// Module Name: segs
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


module bin_to_hex(
    input               rst,
    input   [3:0]      data_in,
    output reg [7:0]      seg_out
    );

    always @(*) begin
    if (rst) begin
        seg_out = 8'b11111101;
    end 
    else begin
        case (data_in)
            4'h0: seg_out = 8'b00000011;
            4'h1: seg_out = 8'b10011111;
            4'h2: seg_out = 8'b00100101;
            4'h3: seg_out = 8'b00001101;
            4'h4: seg_out = 8'b10011001;
            4'h5: seg_out = 8'b01001001;
            4'h6: seg_out = 8'b01000001;
            4'h7: seg_out = 8'b00011111;
            4'h8: seg_out = 8'b00000001;
            4'h9: seg_out = 8'b00001001;
            4'ha: seg_out = 8'b00010001;
            4'hb: seg_out = 8'b11000001; 
            4'hc: seg_out = 8'b01100011;
            4'hd: seg_out = 8'b10000101;
            4'he: seg_out = 8'b01100001;
            4'hf: seg_out = 8'b01110001; 
            default: seg_out = 8'b11111101;   
        endcase
    end
end
endmodule
