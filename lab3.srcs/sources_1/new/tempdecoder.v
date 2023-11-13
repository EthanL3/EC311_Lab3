//uses double dabble algo to conver the 8-bit binary (from temp sensor) to BCD

module tempdecoder (
    input [13:0] temp_binary,  // from temp sensor
    input [13:0] temp_stored,  // from ram
    input [1:0] mode,         // displays current temp OR displays stored value (tied to switch 0 on board)
    input isF,              
    output [4:0] sign_digit, 
    output [4:0] hundreds,
    output [4:0] tens,
    output [4:0] ones,
    output [4:0] tenths,
    output [4:0] hundredths
);

  reg [13:0] binary_temp; //8 bits number that will be convert to 5bit BCD
  reg [15:0] bcd; //double dabble BCD (4 digts)
  integer i; //for dd
   
  reg [5:0] sign_reg, hundreds_reg, tens_reg, ones_reg, tenths_reg, hundredths_reg;
  
  reg [15:0] farenheit_temp;        // is 16 bits since we first have to multiply by 9 to handle the fraction. ( ie dont want overflow)

  // decides to either display current temp or stored temp based on mode 
  always @(temp_binary, mode, isF, temp_stored) begin
  case (mode)
     2'b00: begin // current temp mode
        if (isF) begin                                  // formula for converting C to F using a temporary variable for calculation
            farenheit_temp = temp_binary * 8'd9;        // we use farenheit_temp with more bits so we don't lose any MSBs    ex (25.5C): 255 * 9 = 2295
            farenheit_temp = farenheit_temp / 8'd5;     // divide by 8                                                                  2295 / 5 = 459
            binary_temp = farenheit_temp + 16'd32;     // add 320 since the value is stored with 1 decimal precison                   459 + 320 = 779 (77.9F)
        end else begin
            binary_temp = temp_binary;
        end
     end 
     2'b01: begin //read from memory mode
        if (isF) begin
            farenheit_temp = temp_stored * 8'd9;
            farenheit_temp = farenheit_temp / 8'd5;
            binary_temp = farenheit_temp + 16'd32;
        end else begin
            binary_temp = temp_stored;
        end
     end
     //2'b10: begin //timestamp
     //   //binary_temp = temp_binary ; //have to assign to seconds counter timestamp, right now it does nothing
     //   if (isF) begin
     //       binary_temp <= ((temp_binary * 8'd9)/8'd5) + 8'd32;
     //   end else begin
     //       binary_temp = temp_binary;
     //   end
     //end
     default: begin // default case also displays the current temp for safety
        if (isF) begin
            farenheit_temp = temp_binary * 8'd9;
            farenheit_temp = farenheit_temp / 8'd5;
            binary_temp = farenheit_temp + 16'd32;
        end else begin
            binary_temp = temp_binary;
        end
     end
     endcase
     sign_reg = 5'h10; // automatically positive for now, so we display nothing
  
    end // end of always block
     
     
    // Double dabble algorithm converts 14 bit binary to 4 BCD digits
    // From: https://www.realdigital.org/doc/6dae6583570fd816d1d675b93578203d
    always @(binary_temp)
            begin
                bcd = 0; //initialize bcd to zero
                for (i=0;i<14;i=i+1) begin					//Iterate once for each bit in input number
                    if (bcd[3:0] >= 5) bcd[3:0] = bcd[3:0] + 3;		//If any BCD digit is >= 5, add three
                    if (bcd[7:4] >= 5) bcd[7:4] = bcd[7:4] + 3;
                    if (bcd[11:8] >= 5) bcd[11:8] = bcd[11:8] + 3;
                    if (bcd[15:12] >= 5) bcd[15:12] = bcd[15:12] + 3;
                    bcd = {bcd[14:0],binary_temp[13-i]};				//Shift one bit, and shift in proper bit from input 
                end
            end     

    
    assign sign_digit =  sign_reg; // currently doesnt support negative so we just disp nothing
    
    assign hundreds = 5'h10; // display nothing
    assign tens = {1'b0, bcd[15:12]}; // Append a leading zero for the 5-bit output, then adds the BCD result from double dabble
    assign ones = {1'b0, bcd[11:8]};
    assign tenths = {1'b0, bcd[7:4]};
    assign hundredths = {1'b0, bcd[3:0]};

  
endmodule
