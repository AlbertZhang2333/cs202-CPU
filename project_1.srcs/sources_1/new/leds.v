`timescale 1ns / 1ps

module leds (
    input			ledrst,		// reset, active HIGH!
    input			led_clk,	// clock for led
//    input			ledwrite,	// led write ENABLE, active HIGH!
    input			ledcs,		// 1 means the leds are selected as output
//    input	[1:0]	ledaddr,	// 2'b01 means updata the LOW 16bits of ledout, 2'b10 means updata the HIGH 8 bits of ledout
    input	[31:0]	ledwdata,	// the data (from register/memorio)  waiting for to be writen to the leds of the board
    output reg	[15:0]	ledout		// the data writen to the leds of the board
);
    
    always @* begin
        if (ledrst)
            ledout <= 16'h0;
		//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		else if (ledcs) 
            ledout <= ledwdata[15:0];
        else 
            ledout <= ledout;
    end
	
endmodule
