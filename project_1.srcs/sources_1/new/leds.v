`timescale 1ns / 1ps

module leds (
    input			ledrst,		// reset, active HIGH!
    input			led_clk,	// clock for led
    input			ledwrite,	// led write ENABLE, active HIGH!
    input			ledcs,		// 1 means the leds are selected as output((LEDCtrlLow || LEDCtrlHigh) in MenOrIO)
    input	[1:0]	ledaddr,	// 2'b01 means updata the LOW 16bits of ledout, 2'b10 means updata the HIGH 8 bits of ledout({LEDCtrlHigh,LEDCtrlLow})
    input	[32:0]	ledwdata,	// the data (from register/memorio)  waiting for to be writen to the leds of the board
    output	[23:0]	ledout		// the data writen to the leds of the board
);
  
    reg [23:0] ledout;
    
    always @ (posedge led_clk or posedge ledrst) begin
        if (ledrst)
            ledout <= 24'h000000;
		//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		else if (ledcs && ledwrite) 
            begin
                if (ledaddr == 2'b01)
                    ledout[23:0] <= { 8'h00, ledwdata[15:0] };
                else if (ledaddr == 2'b10 )
                    ledout[23:0] <= ledwdata[23:0];
                else
                    ledout <= ledout;
            end 
        else 
            begin
                ledout <= 24'h000000;
            end
    end
	
endmodule
