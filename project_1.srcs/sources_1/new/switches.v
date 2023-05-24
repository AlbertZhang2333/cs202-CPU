`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module switches (
    input			reset,				// reset, active high 
	input			ior,				// from Controller, 1 means read from switches
    input	[1:0]	switchctrl,			// means the switch is selected as input device (CS signal from MemOrIO)
    input	[23:0]	ioread_data_switch,	// the data from switches
    output	[15:0]	ioread_data 		// the data to memorio
);    
    reg [15:0] ioread_data;
    
    always @* begin
        if (reset)
            ioread_data = 16'h0000;
        else if (ior == 1) 
            begin
                if (switchctrl == 2'b01)
                    ioread_data = ioread_data_switch[15:0];
                else if (switchctrl == 2'b10)
                    ioread_data = {8'h00,ioread_data_switch[23:16]};
                else
                    ioread_data = ioread_data;
            end
        else
            begin
                ioread_data = 16'h0000;
            end
    end
	
endmodule

