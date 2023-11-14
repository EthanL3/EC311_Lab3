module tb_top;
  reg clk = 0;  // Clock signal initialization at time 0
  reg reset;
  wire [7:0] anode;
  wire [7:0] cathode;

  top uut (
    .CLK100MHZ(clk),
    .reset(reset),
    .anode_seg(anode),
    .cathode_seg(cathode)
  );

  always #5 clk = ~clk; // a simulated 100 MHz clock

  initial begin
    //reset = 0;
    
    //$dumpfile("dump.vcd"); 
    //$dumpvars;
    
    $display("Simulation started at time: %0t", $time);
    
    #12; //waits 10 just for fun

    // have to reset to get the display to start working
    //reset = 1;
    //#17;  // Holds a reset signal for 5 ns
    //reset = 0;
    
    // Run simulation for 80 time units to cover 8 cycles of display working (ie 8 anodes displayed)
    #300;

    $finish;
  end
endmodule
