`timescale 1ns / 1ps
module RAM(
    input clk,
    input [13:0] data_in,
    input write_enable,
    input [1:0] read_enable,
    output reg [13:0] data_out
    );
    
reg [13:0] ram;
always@(posedge clk) begin
    if(write_enable)
        ram <= data_in;
    if (read_enable == 2'b01)
        data_out <= ram;
end
endmodule