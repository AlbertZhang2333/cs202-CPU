`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module switches (
    input			reset,				// reset, active high 
//	input			ior,				// from MenOrIO, 1 means read from switches
    input	    	switchctrl,			// means the switch is selected as input device (CS signal from MemOrIO)
    input	[18:0]	ioread_data_switch,	// the data from switches
    output reg	[18:0] ioread_data 		// the data to memorio
);
    
    always @* begin
        if (reset)
            ioread_data = {3'b000,16'h0000};
        else if (switchctrl == 1) 
            ioread_data = ioread_data_switch[18:0];
        else
            begin
                ioread_data = ioread_data;
            end
    end
	
endmodule

