`timescale 1ns / 1ps

module top(

    input CLK100MHZ,
    input reset,                // reset input (tied to the middle button on board - N17)
    input storeTemp,            // tied to a button (P18) on board that stores the current temp to RAM
    input [1:0] mode,           // 00 - display current, 01 display stored, 10 display elapsed time, 11 unused
    input cf,                   // 1 for Freedom units, 0 for Celsius
    inout SDA_inout,            // I2C data line for temp sensor
    output SCL_out,             // SCL out line to temp sensor
    output [7:0] cathode_seg,   // 7-segment cathode outputs
    output [7:0] anode_seg      // 7-segment anode outputs (8 bits since we include decimal point here)
);

    wire [13:0] temp_data_int;   // internal wire to store temperature data to be sent to display or to RAM
    wire [13:0] d_out;           // temp data out of ram, to be sent to display only

    wire SDA_dir;               // SDA direction control - unused

    wire [4:0] tsign, thundreds, ttens, tones, ttenths, thundredths; //BCD from decoder is sent to display module
    wire [31:0] elapsed_time;   // in seconds since either the program started or a new value has been stored
    
    wire slowclk;               // a slow clock (500hz) from the clockdivider module
    wire onesecclk;             // one second clock (1hz) for the elapsed time
    wire clk200;

    // RAM for storing temp data
    RAM myram (
        .clk(CLK100MHZ),
        .write_enable(storeTemp),
        .read_enable(mode),
        .data_in(temp_data_int),
        .data_out(d_out)
    );
    
    // clock (200mhz) for ts   
    clk200mhz clkdiv200 (
        .clock_in(CLK100MHZ),
        .clock_out_200(clk200)
    );
    
    // temp sensor state machine
	tempsensor ts (
        .clk_200kHz(clk200),
        .reset(reset),
        .SDA(SDA_inout),
        .temp_data(temp_data_int),
        .SDA_dir(SDA_dir),
        .SCL(SCL_out)
    );
    
    // converts temp from sensor or from RAM to BCD to be displayed
    tempdecoder mytempdecoder (
        .temp_binary(temp_data_int),    // links right to temp sensor
        .temp_stored(d_out),            // from RAM
        .mode(mode),                    // links PleaseView which is a swtich on the board
        .isF(cf),                       // if Farenheit, do math before converting to BCD
        //rest of these ouputs are wires that link to 7seg display
        .sign_digit(tsign), 
        .hundreds(thundreds),
        .tens(ttens),
        .ones(tones),
        .tenths(ttenths),
        .hundredths(thundredths)
    );
	
	// slow clock (500hz) for display   
    clock_divider clkdiv (
        .clock_in(CLK100MHZ),
        .clock_out(slowclk)
    );
    
    // 1hz clock for elapsed time
    onesecondclock osc (
        .clock_in(CLK100MHZ),
        .reset_in(storeTemp),           // whenever a new temp is stored, this clock is reset
        .sec_out(elapsed_time),
        .clock_out(onesecclk)    
    );
    
    wire [4:0] BCD_M2, BCD_M1, BCD_S2, BCD_S1;  // wires for 
    wire [4:0] disp_tsign, disp_thundreds, disp_ttens, disp_tones, disp_ttenths, disp_thundredths, disp_degsym, disp_corf;
    secToBCD secBCD (
       .elapsed_time_sec(elapsed_time),
       .BCD_min_tens(BCD_M2),
       .BCD_min_ones(BCD_M1),
       .BCD_sec_tens(BCD_S2),
       .BCD_sec_ones(BCD_S1) 
    );
    
    //assigns either the temp or the timestamp to this 7seg display wire
    assign disp_tsign      = (mode <= 2'b01) ? tsign      : 5'hE;   //sign bit (currently unused) or E for elapsed time
    assign disp_thundreds  = (mode <= 2'b01) ? thundreds  : 5'h10;  //hundreds place or nothing
    assign disp_ttens      = (mode <= 2'b01) ? ttens      : BCD_M2; //tens place or 10-minutes
    assign disp_tones      = (mode <= 2'b01) ? tones      : BCD_M1; //ones place or minutes
    assign disp_ttenths    = (mode <= 2'b01) ? ttenths    : BCD_S2; //hundreds place or ten-seconds
    assign disp_thundredths= (mode <= 2'b01) ? thundredths: BCD_S1; //hundredths place or seconds
    assign disp_degsym     = (mode <= 2'b01) ? 5'b10001   : 5'h10;  //deg sym OR nothing
    assign disp_corf       = (mode <= 2'b01) ? ((cf == 1'b1) ? 5'hF : 5'hC) : 5'h10; //C or F (depending on mode) OR nothing
    
    
    segment_disp sevendisp (
        .val_TBD5(disp_tsign),
        .val_TBD4(disp_thundreds),
        .val_TBD3(disp_ttens),
        .val_TBD2(disp_tones),
        .val_TBD1(disp_ttenths),
        .val_TBD0(disp_thundredths),
        .val_TBD7(disp_degsym), //deg symbol
        .val_TBD6(disp_corf), // c or f or nothing

        .clock_in(slowclk),
        .reset_in(reset),
        .cathode_out(cathode_seg),
        .anode_out(anode_seg)
    );
    
    
    //segment_disp sevendisp (
    //    .val_TBD0(tsign),
    //    .val_TBD1(thundreds),
    //    .val_TBD2(ttens),
    //    .val_TBD3(tones),
    //    .val_TBD4(ttenths),
    //    .val_TBD5(thundredths),
    //    .val_TBD6(5'b10001), // hard coded deg symbol
    //    .val_TBD7(5'hC), //hard coded C
    //    .clock_in(slowclk),
    //    .reset_in(reset),
    //    .cathode_out(cathode_seg),
    //    .anode_out(anode_seg)
    //);
    
    
     //this commented out part was for testing the display on the board independent of the temp sensor data val
     //segment_disp sevendisp (
     //   .val_TBD0(5'b10000), //display - symbol
     //   .val_TBD1(5'd2),//display -23456[]C for testing
     //   .val_TBD2(5'd3),
     //   .val_TBD3(5'd4),
     //   .val_TBD4(5'd5),
     //   .val_TBD5(5'd6),
     //   .val_TBD6(5'b10001), // display deg symbol
     //   .val_TBD7(5'hC), //display C
     //   .clock_in(slowclk),
     //   .reset_in(reset),
     //   .cathode_out(cathode_seg),
     //   .anode_out(anode_seg)
     //);
    
endmodule