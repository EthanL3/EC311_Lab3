module onesecondclock(
    input clock_in,
    input reset_in,
    output reg clock_out,
    output reg [31:0] sec_out
);

reg[27:0] counter; //this is for the 1 sec clock, only reset when reset is pressed or when >= 100000000 - 1
parameter HURTS = 28'd100000000;   // this brings the clock divider to one second operation (ie 1 hz)

reg [31:0] seconds_counter; //elapsed seconds

initial begin
    seconds_counter = 0;
    counter = 28'd0;
end


always @(posedge clock_in)
begin
    if (reset_in)
    begin
        counter <= 28'd0;
        seconds_counter <= 32'd0;
    end
    else // Normal operation
    begin
        counter <= counter + 28'd1; //increment
        if(counter >= (HURTS-1)) //sets counter back to zero to to bit overflow
        begin
            counter <= 28'd0;
            seconds_counter <= seconds_counter + 32'd1; // Increment the time in seconds counter
        end
        clock_out <= (counter < HURTS/2) ? 1'b1 : 1'b0; //if counter is less than half of divisor, set clock high, otherwise set clock low (ie makes clock both high and low per cycle)
    end

    sec_out = seconds_counter;

end


endmodule