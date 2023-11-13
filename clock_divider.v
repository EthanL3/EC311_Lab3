module clock_divider(
    input clock_in,
    output reg clock_out
);

reg[27:0] counter=28'd0;
parameter HURTS = 28'd200000;   // we tested various frequencies but this one looks good on the board
                                // 100Mhz / 200000= 500hz refresh rate

//according to data sheet: 
//refresh rate >45Hz to prevent flicker
//should be 1 KHz to 60Hz for bright display ( 1 to 16ms  refresh)

always @(posedge clock_in)
begin
    counter <= counter + 28'd1; //increments counter every clock cycle (100mhz)
    if(counter >= (HURTS-1))
        counter <= 28'd0;
    clock_out <= (counter < HURTS/2) ? 1'b1 : 1'b0; //if counter is less than half of divisor, set clock high, otherwise set clock low (ie makes clock both high and low per cycle)
end
endmodule
