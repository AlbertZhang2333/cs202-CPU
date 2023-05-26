`timescale 1ns / 1ps

module MemOrIO(memRead,memWrite, ioRead, ioWrite, addr_in, addr_out, 
m_rdata,io_rdata_switch,io_rdata_board, r_wdata, r_rdata, write_data,LEDCtrl, SwitchCtrl, SegCtrl,BoardCtrl
);
//Controller
input           memRead; // read memory, from Controller
input           memWrite; // write memory, from Controller
input           ioRead; // read IO, from Controller
input           ioWrite; // write IO, from Controller

input   [31:0]  addr_in; // from alu_result in ALU
output  [31:0]  addr_out; // address to Data-Memory

input   [31:0]  m_rdata; // data read from Data-Memory
input   [18:0]  io_rdata_switch; // data read from switch,19 bits
input   [18:0]  io_rdata_board; // data read from board,19 bits
output  [31:0]  r_wdata; // data to register
input   [31:0]  r_rdata; // data read from register
output reg  [31:0]  write_data; // data to memory or I/O（m_wdata, io_wdata�?
output          LEDCtrl; // LED Chip Select
output          SwitchCtrl; // Switch Chip Select
output          SegCtrl;//segment
output          BoardCtrl;//keyboard
wire    [18:0]  io_rdata;
wire    [1:0]   low_addr;
assign low_addr = addr_in[1:0];
assign io_rdata=(low_addr==2'b01)?io_rdata_board:io_rdata_switch;

assign addr_out = addr_in;

assign r_wdata = (ioRead==1'b1) ? {13'b0,io_rdata} : m_rdata;

assign LEDCtrl = (ioWrite == 1 && low_addr == 2'b00) ? 1'b1 : 1'b0;
assign SwitchCtrl = (ioRead == 1 && low_addr == 2'b00) ? 1'b1 : 1'b0;
assign SegCtrl = (ioWrite == 1 && low_addr == 2'b01) ? 1'b1 : 1'b0;
assign BoardCtrl = (ioRead == 1 && low_addr == 2'b01) ? 1'b1 : 1'b0;

always @* begin
    if ((memWrite == 1) || (ioWrite == 1)) begin
        write_data = memRead ? m_rdata : r_rdata;
    end
    else begin
        write_data = 32'hZZZZZZZZ;
    end
end

endmodule