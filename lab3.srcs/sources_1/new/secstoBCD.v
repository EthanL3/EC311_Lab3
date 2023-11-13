module secToBCD (
    input [31:0] elapsed_time_sec, // Elapsed time in seconds
    output reg [4:0] BCD_min_tens,
    output reg [4:0] BCD_min_ones,
    output reg [4:0] BCD_sec_tens,
    output reg [4:0] BCD_sec_ones
);

    reg [5:0] min;
    reg [5:0] sec;

    // seconds -> min, seconds -> remainder seconds
    always @(elapsed_time_sec) begin
        min = elapsed_time_sec / 60;
        sec = elapsed_time_sec % 60; //mod 60
    end

    // some BCD math for min plus leading zeroes since we use 5bit bCD
    always @(min) begin
        BCD_min_ones[3:0] = min % 10; // Units place
        BCD_min_ones[4] = 1'b0; // MSB set to 0 since we only care about 4 bits of BCD
        BCD_min_tens[3:0] = min / 10; // Tens place
        BCD_min_tens[4] = 1'b0;
    end

    // BCD for seconds
    always @(sec) begin
        BCD_sec_ones[3:0] = sec % 10;
        BCD_sec_ones[4] = 1'b0;
        BCD_sec_tens[3:0] = sec / 10;
        BCD_sec_tens[4] = 1'b0;
    end

endmodule