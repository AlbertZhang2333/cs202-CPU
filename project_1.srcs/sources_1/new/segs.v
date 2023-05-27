`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/27 23:31:22
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


module segs(
    input clk,
    input rst,
    input segCtrl,
    input [31:0] data_in,
    output reg [7: 0] seg_o_0,
    // output [7: 0] seg_o_1,
    // output [7: 0] seg2,
    // output [7: 0] seg3,
    output reg [7: 0] seg_en
);

reg [2:0] cnt;
reg clk_out;
reg [31:0] ccnt;
wire [7:0] seg0,seg1,seg2,seg3;
reg [31:0] data;

// assign seg_o_1 = 8'b11111101;

parameter T = 200000;

always @(posedge clk_out,negedge segCtrl) begin
    if(!segCtrl)
        data <= data;
    else
        data <= data_in;
end

always @(posedge clk,posedge rst) begin
    if(rst) begin
        ccnt <= 0;
        clk_out <= 0;
    end
    else begin
        if(ccnt == (T >> 1) - 1) begin
            clk_out <= ~clk_out;
            ccnt <= 0;
        end
        else
            ccnt <= ccnt + 1;
    end
end

bin_to_hex light0(rst, data[3:0], seg0);
bin_to_hex light1(rst, data[7:4], seg1);
bin_to_hex light2(rst, data[11:8], seg2);
bin_to_hex light3(rst, data[15:12], seg3);

always @(cnt) begin
    case(cnt)
        3'b000:seg_o_0 <= seg0;
        3'b001:seg_o_0 <= seg1;
        3'b010:seg_o_0 <= seg2;
        3'b011:seg_o_0 <= seg3;
        default:seg_o_0 <= 8'b11111101;
    endcase
end

always @(posedge clk_out,posedge rst) begin
    if(rst) begin
        cnt <= 0;
    end
    else begin
        if(cnt == 3'd7)
            cnt <= 0;
        else 
            cnt <= cnt + 1;
    end
end

always @(cnt) begin
    case(cnt)
        3'd0:seg_en = 8'b11111110;
        3'd1:seg_en = 8'b11111101;
        3'd2:seg_en = 8'b11111011;
        3'd3:seg_en = 8'b11110111;
        3'd4:seg_en = 8'b11101111;
        3'd5:seg_en = 8'b11011111;
        3'd6:seg_en = 8'b10111111;
        3'd7:seg_en = 8'b01111111;
    endcase
end
endmodule
