////////////////////////////////////////////////////////////////
// input ports
// clk               -clock signal
// arstn             -reset the system (asynchronous reset, active low)
// ifft_in0_re       -from testbench, test cases for the of the 1st input (real part) of the IFFT pipeline (32 elements * 16 bits = 512 bits)
// ifft_in0_im       -from testbench, test cases for the of the 2nd input (imag part) of the IFFT pipeline (32 elements * 16 bits = 512 bits)
// ifft_in1_re       -from testbench, test cases for the of the 1st input (real part) of the IFFT pipeline (32 elements * 16 bits = 512 bits)
// ifft_in1_im       -from testbench, test cases for the of the 2nd input (imag part) of the IFFT pipeline (32 elements * 16 bits = 512 bits)
// twiddle_lut_re    -from testbench, twiddle factors needed during 64IFFT calculation (32 elements * 16 bits = 512 bits)
// twiddle_lut_im    -from testbench, twiddle factors needed during 64IFFT calculation (32 elements * 16 bits = 512 bits)
// twiddle_sel1      -control signal, to select twiddle factors for the 1st layer in the 64IFFT pipeline
// twiddle_sel2      -control signal, to select twiddle factors for the 2nd layer in the 64IFFT pipeline
// twiddle_sel3      -control signal, to select twiddle factors for the 3rd layer in the 64IFFT pipeline
// twiddle_sel4      -control signal, to select twiddle factors for the 4th layer in the 64IFFT pipeline
// twiddle_sel5      -control signal, to select twiddle factors for the 5th layer in the 64IFFT pipeline
// pattern2          -control signal, to contol the communator at the 2nd layer in the 64IFFT pipeline
// pattern3          -control signal, to contol the communator at the 3rd layer in the 64IFFT pipeline
// pattern4          -control signal, to contol the communator at the 4th layer in the 64IFFT pipeline
// pattern5          -control signal, to contol the communator at the 5th layer in the 64IFFT pipeline
// pattern6          -control signal, to contol the communator at the 6th layer in the 64IFFT pipeline
// cnt_cal           -to counter 32 cycles within each test case (5 bits)

// output ports
// ifft_out0_re      -to testbench, the 1st output (real part) of the IFFT pipeline (16 bits)
// ifft_out0_im      -to testbench, the 1st output (imag part) of the IFFT pipeline (16 bits) 
// ifft_out1_re      -to testbench, the 2nd output (real part) of the IFFT pipeline (16 bits) 
// ifft_out1_im      -to testbench, the 2nd output (imag part) of the IFFT pipeline (16 bits) 
////////////////////////////////////////////////////////////////
module ifft64_radix2
    (
        //from tb
        input clk, 
        input arstn,
        input [511:0] ifft_in0_re,
        input [511:0] ifft_in0_im,
        input [511:0] ifft_in1_re,
        input [511:0] ifft_in1_im,
        input [511:0] twiddle_lut_re,
        input [511:0] twiddle_lut_im,
        //from ctrl
        input [4:0] twiddle_sel1,
        input [4:0] twiddle_sel2,
        input [4:0] twiddle_sel3,
        input [4:0] twiddle_sel4,
        input [4:0] twiddle_sel5,
        input pattern2,
        input pattern3,
        input pattern4,
        input pattern5,
        input pattern6,
        input [4:0] cnt_cal,
        //outputs
        output [15:0] ifft_out0_re,
        output [15:0] ifft_out0_im,
        output [15:0] ifft_out1_re,
        output [15:0] ifft_out1_im
    );

// wire definition
// fill in your code here


// input MUX, depends on cnt_cal, to select inputs for the IFFT pipeline at each cycle
// input: 512 bits, ifft_in0_re, ifft_in0_im, ifft_in1_re, ifft_in1_im
// output: 16 bits, bf1_in0_re, bf1_in0_im, bf1_in1_re, bf1_in1_im
// selection signal: cnt_cal (e.g. when cnt_cal = 0,  bf1_in0_re = ifft_in0_re[32*16-1 : 31*16], ..., bf1_in0_im = ifft_in0_im[32*16-1 : 31*16], ...
//                                 when cnt_cal = 31, bf1_in0_re = ifft_in0_re[1*16-1 : 0*16], ..., bf1_in0_im = ifft_in0_im[1*16-1 : 0*16], ...)
// fill in your code here


// layer 1
    // twiddle factor MUX, depends on twiddle_sel1, to select twiddle factors for the 1st layer of the 64IFFT pipeline
    // input: 512 bits, twiddle_lut_re, twiddle_lut_im
    // output: 16 bits, twiddle1_re, twiddle1_im
    // fill in your code here


    // butterfly radix calculation with twiddle factor
    // Y0 = A + B
    // Y1 = (A - B)*W
    // instantiate your bf_radix2.v here
    // fill in your code here


//layer 2
    // twiddle factor MUX, depends on twiddle_sel2, to select twiddle factors for the 2nd layer of the 64IFFT pipeline
    // input: 512 bits, twiddle_lut_re, twiddle_lut_im
    // output: 16 bits, twiddle2_re, twiddle2_im
    // fill in your code here


    //re-arrange data
        // delay before commutator
        // fill in your code here


        // commutator
        // fill in your code here


        // delay after commutator
        // fill in your code here


    // butterfly radix calculation with twiddle factor
    // Y0 = A + B
    // Y1 = (A - B)*W
    // instantiate your bf_radix2.v here
    // fill in your code here


//layer 3
    // twiddle factor MUX, depends on twiddle_sel3, to select twiddle factors for the 3rd layer of the 64IFFT pipeline
    // input: 512 bits, twiddle_lut_re, twiddle_lut_im
    // output: 16 bits, twiddle3_re, twiddle3_im
    // fill in your code here


    //re-arrange data
        // delay before commutator
        // fill in your code here


        // commutator
        // fill in your code here


        // delay after commutator
        // fill in your code here


    // butterfly radix calculation with twiddle factor
    // Y0 = A + B
    // Y1 = (A - B)*W
    // instantiate your bf_radix2.v here
    // fill in your code here


//layer 4
    // twiddle factor MUX, depends on twiddle_sel4, to select twiddle factors for the 4th layer of the 64IFFT pipeline
    // input: 512 bits, twiddle_lut_re, twiddle_lut_im
    // output: 16 bits, twiddle4_re, twiddle4_im
    // fill in your code here


    //re-arrange data
        // delay before commutator
        // fill in your code here


        // commutator
        // fill in your code here


        // delay after commutator
        // fill in your code here


    // butterfly radix calculation with twiddle factor
    // Y0 = A + B
    // Y1 = (A - B)*W
    // instantiate your bf_radix2.v here
    // fill in your code here


//layer 5
    // twiddle factor MUX, depends on twiddle_sel5, to select twiddle factors for the 5th layer of the 64IFFT pipeline
    // input: 512 bits, twiddle_lut_re, twiddle_lut_im
    // output: 16 bits, twiddle5_re, twiddle5_im
    // fill in your code here


    //re-arrange data
        // delay before commutator
        // fill in your code here


        // commutator
        // fill in your code here


        // delay after commutator
        // fill in your code here


    // butterfly radix calculation with twiddle factor
    // Y0 = A + B
    // Y1 = (A - B)*W
    // instantiate your bf_radix2.v here
    // fill in your code here


//layer 6
    //re-arrange data
        // delay before commutator
        // fill in your code here


        // commutator
        // fill in your code here


        // delay after commutator
        // fill in your code here


    // butterfly radix calculation without twiddle factor
    // Y0 = A + B
    // Y1 = A - B
    // instantiate your bf_radix2_noW.v here
    // fill in your code here



endmodule
