////////////////////////////////////////////////////////////////
// input ports
// clk             -clock signal
// arstn           -reset the system (asynchronous reset, active low)
// start           -start IFFT calculation

// output ports
// start_check     -to testbench, to be activated when the first effective result is generated at the output of the IFFT papeline (active high)
// bank_addr       -to select test case (10 bits)
// twiddle_sel1    -control signal, to select twiddle factors for the 1st layer in the 64IFFT pipeline
// twiddle_sel2    -control signal, to select twiddle factors for the 2nd layer in the 64IFFT pipeline
// twiddle_sel3    -control signal, to select twiddle factors for the 3rd layer in the 64IFFT pipeline
// twiddle_sel4    -control signal, to select twiddle factors for the 4th layer in the 64IFFT pipeline
// twiddle_sel5    -control signal, to select twiddle factors for the 5th layer in the 64IFFT pipeline
// pattern2        -control signal, to contol the communator at the 2nd layer in the 64IFFT pipeline
// pattern3        -control signal, to contol the communator at the 3rd layer in the 64IFFT pipeline
// pattern4        -control signal, to contol the communator at the 4th layer in the 64IFFT pipeline
// pattern5        -control signal, to contol the communator at the 5th layer in the 64IFFT pipeline
// pattern6        -control signal, to contol the communator at the 6th layer in the 64IFFT pipeline
// cnt_cal         -to counter 32 cycles within each test case (5 bits)
////////////////////////////////////////////////////////////////
module ifft_ctrl
    (
        input clk,
        input arstn,
        input start,
        output start_check,
        output [9:0] bank_addr,
        output [4:0] twiddle_sel1,
        output [4:0] twiddle_sel2,
        output [4:0] twiddle_sel3,
        output [4:0] twiddle_sel4,
        output [4:0] twiddle_sel5,
        output pattern2,
        output pattern3,
        output pattern4,
        output pattern5,
        output pattern6,
        output [4:0] cnt_cal
    );
    
    localparam NO_TEST_CASE = 10'd1000;

//define cycles need to wait to get the first result
    localparam IFFT_LATENCY = 5'd31;

//state define   
    localparam IDLE = 2'd0;
    localparam INIT = 2'd1;
    localparam CAL = 2'd2;
    localparam DONE = 2'd3;

// port definition
// fill in your code here
    
// update current states (sequential logic, reset with arstn)
// fill in your code here


// next state generation (combinational logic)
// fill in your code here


// output generation (combinational logic)
// fill in your code here


// cnt_cal, 5-bit counter (sequential logic, reset with arstn)
// to counter 32 cycles within each test case
// fill in your code here


// bank_addr, 10-bit counter (sequential logic, reset with arstn)
// to select test case
// fill in your code here
    
endmodule
