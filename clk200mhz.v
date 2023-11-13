module clk200mhz(
    input clock_in,
    output reg clock_out_200
);

reg[9:0] counter=10'd0;
parameter HURTS = 10'd500;   // we tested various frequencies but this one looks good on the board
                                // 100khz / 500= 200mhz refresh rate

// temp sensor module req 200 mhz refresh rate to work right accroding to data sheet

always @(posedge clock_in)
begin
    counter <= counter + 28'd1; //increments counter every clock cycle (100mhz)
    if(counter >= (HURTS-1))
        counter <= 28'd0;
    clock_out_200 <= (counter < HURTS/2) ? 1'b1 : 1'b0; //if counter is less than half of divisor, set clock high, otherwise set clock low (ie makes clock both high and low per cycle)
end
endmodule
