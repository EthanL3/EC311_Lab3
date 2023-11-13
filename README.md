James Conlon
U23459610

Ethan Levine
U71700384

EC311 Lab3

Demo video:
https://drive.google.com/file/d/1AQ_mbW39wqc0osaYZ6BFaJx2OeK6zn93/view?usp=sharing

For our project, we created a temperature sensor which displays the given temperature at any instant in either F or C on the 7-segment display. It also can store temp. values in memory and read them in both C and F. We also included a clock that records the time since a temperature has been saved to memory. All is demoed in our video.

For this lab, we have the top module named top that links to everything. The only logic we do in the top is an if/else changing what inputs are passed to the display. The rest are in their respective modules. We commented all our modules with what is going on in them.

We did not write the temperature sensor module, however we made our own clock divider according to the datasheet. We have 3 clock divider modules in total that we use for different things.

We only used one testbench since the first module we finished was the seven-segement display. Some of the commentted out code shows how we tested the display. The rest of the code could be tested direct on the FPGA since we could use the display for testing.

We both contributed an adaquate amount of work to this lab, and we feel the other partner did as well.
E-Signatures: 
Ethan Levine
James Conlon
