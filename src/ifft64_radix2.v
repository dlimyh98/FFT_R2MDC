// Input ports
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
// pattern2          -control signal, to control the communator at the 2nd layer in the 64IFFT pipeline
// pattern3          -control signal, to control the communator at the 3rd layer in the 64IFFT pipeline
// pattern4          -control signal, to control the communator at the 4th layer in the 64IFFT pipeline
// pattern5          -control signal, to control the communator at the 5th layer in the 64IFFT pipeline
// pattern6          -control signal, to control the communator at the 6th layer in the 64IFFT pipeline
// cntr_IFFT_input_pairs           -to count 32 cycles within each test case (5 bits)

// Output ports
// ifft_out0_re      -to testbench, the 1st output (real part) of the IFFT pipeline (16 bits)
// ifft_out0_im      -to testbench, the 1st output (imag part) of the IFFT pipeline (16 bits) 
// ifft_out1_re      -to testbench, the 2nd output (real part) of the IFFT pipeline (16 bits) 
// ifft_out1_im      -to testbench, the 2nd output (imag part) of the IFFT pipeline (16 bits) 

module ifft64_radix2
    (
        // From TB
        input CLK, 
        input ARSTN,
        input [511:0] ifft_in0_re,
        input [511:0] ifft_in0_im,
        input [511:0] ifft_in1_re,
        input [511:0] ifft_in1_im,
        input signed [511:0] twiddle_lut_re,
        input [511:0] twiddle_lut_im,

        // From IFFT_CTRL
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
        input [4:0] cntr_IFFT_input_pairs,

        // Outputs
        output [15:0] ifft_out0_re,
        output [15:0] ifft_out0_im,
        output [15:0] ifft_out1_re,
        output [15:0] ifft_out1_im
    );


    localparam CNTR_MAX_VALUE = 31;
    localparam NUM_BITS_PER_INPUT = 16;
    localparam NUM_INPUTS_PER_PATH = 32;

    localparam L1_L2_DELAY = 16;
    localparam L2_L3_DELAY = 8;
    localparam L3_L4_DELAY = 4;
    localparam L4_L5_DELAY = 2;
    localparam L5_L6_DELAY = 1;

    localparam L1_L2_DELAY_BEFORE_SAVING = 0;
    localparam L2_L3_DELAY_BEFORE_SAVING = 16;
    localparam L3_L4_DELAY_BEFORE_SAVING = 24;
    localparam L4_L5_DELAY_BEFORE_SAVING = 28;
    localparam L5_L6_DELAY_BEFORE_SAVING = 30;


/************************************* INPUT MUX *************************************/
    wire [15:0] bf1_in0_re;
    wire [15:0] bf1_in0_im;
    wire [15:0] bf1_in1_re;
    wire [15:0] bf1_in1_im;

    // To select inputs for the IFFT pipeline at each cycle (Feeding into BFU1)
    // Selection Signal: [4:0] cntr_IFFT_input_pairs
    // Input: 512 bits; (ifft_in0_re, ifft_in0_im), (ifft_in1_re, ifft_in1_im)
    // Output: 16 bits; (bf1_in0_re, bf1_in0_im), (bf1_in1_re, bf1_in1_im)

    // https://stackoverflow.com/questions/3011510/how-to-declare-and-use-1d-and-2d-byte-arrays-in-verilog
    // https://www.geeksforgeeks.org/little-and-big-endian-mystery/
    // Inputs are read using $readmemb in the format reg[511:0][0:TEST_CASE-1]
    // NOTE:, Bits of some TEST_CASE scenario are stored in LITTLE-ENDIAN mode
    // e.g. when cntr_IFFT_input_pairs = 0,  bf1_in0_re = ifft_in0_re[32*16-1 : 31*16], bf1_in0_im = ifft_in0_im[32*16-1 : 31*16]
    //      when cntr_IFFT_input_pairs = 31, bf1_in0_re = ifft_in0_re[1*16-1 : 0*16], bf1_in0_im = ifft_in0_im[1*16-1 : 0*16]

    // Select which of the 16bits (amongst 512bits) are relevant
    // Basically, we want to do assign bf1_in0_re = ifft_in0_re[(31-cntr_IFFT_input_pairs)*16) + 15 
    //                                                     : (31-cntr_IFFT_input_pairs)*16)];
    // https://stackoverflow.com/questions/43771894/verilog-code-error-range-must-be-bounded-by-constant-expressions
    // https://stackoverflow.com/questions/18067571/indexing-vectors-and-arrays-with
    assign bf1_in0_re = ifft_in0_re[((CNTR_MAX_VALUE-cntr_IFFT_input_pairs)*NUM_BITS_PER_INPUT)+:NUM_BITS_PER_INPUT];
    assign bf1_in0_im = ifft_in0_im[((CNTR_MAX_VALUE-cntr_IFFT_input_pairs)*NUM_BITS_PER_INPUT)+:NUM_BITS_PER_INPUT];
    assign bf1_in1_re = ifft_in1_re[((CNTR_MAX_VALUE-cntr_IFFT_input_pairs)*NUM_BITS_PER_INPUT)+:NUM_BITS_PER_INPUT];
    assign bf1_in1_im = ifft_in1_im[((CNTR_MAX_VALUE-cntr_IFFT_input_pairs)*NUM_BITS_PER_INPUT)+:NUM_BITS_PER_INPUT];


/************************************* LAYER 1 *************************************/
    // Twiddle MUX1 (Choose between W0,W1,W2,...,W31)
    wire [15:0] twiddle1_re;
    wire [15:0] twiddle1_im;

    // Selection Signal: [4:0] twiddle_sel1 (Available range is 0,1,2,...,31)
    // Input: 512 bits; (twiddle_lut_re, twiddle_lut_im)
    // Output: 16 bits; (twiddle1_re, twiddle1_im)
    assign twiddle1_re = twiddle_lut_re[((CNTR_MAX_VALUE-twiddle_sel1)*NUM_BITS_PER_INPUT)+:16];
    assign twiddle1_im = twiddle_lut_im[((CNTR_MAX_VALUE-twiddle_sel1)*NUM_BITS_PER_INPUT)+:16];

    // Butterfly Unit (with Twiddle Factor)
    wire [15:0] bf1_out0_re;
    wire [15:0] bf1_out0_im;
    wire [15:0] bf1_out1_re;
    wire [15:0] bf1_out1_im;

    bf_radix2 BF1 (.A_re(bf1_in0_re),
                  .A_im(bf1_in0_im),
                  .B_re(bf1_in1_re),
                  .B_im(bf1_in1_im),
                  .W_re(twiddle1_re),
                  .W_im(twiddle1_im),
                  .Y0_re(bf1_out0_re),
                  .Y0_im(bf1_out0_im),
                  .Y1_re(bf1_out1_re),
                  .Y1_im(bf1_out1_im));


/************************************* LAYER 2 *************************************/
    // Pre-Delay to Commutator
    wire [15:0] cm2_in0_re;
    wire [15:0] cm2_in0_im;
    wire [15:0] cm2_in1_re;
    wire [15:0] cm2_in1_im;
    wire [15:0] cm2_out0_re;
    wire [15:0] cm2_out0_im;
    wire [15:0] cm2_out1_re;
    wire [15:0] cm2_out1_im;

    predelay_commutator #(.DELAY_CYCLES(L1_L2_DELAY-1),                     // 15
                          .DELAY_BEFORE_SAVING(L1_L2_DELAY_BEFORE_SAVING),  // 0
                          .NUM_INPUTS_PER_PATH(NUM_INPUTS_PER_PATH))
    PreDelay_Commutator2 (.CLK(CLK),
                          .cntr_IFFT_input_pairs(cntr_IFFT_input_pairs),
                          .bf_out0_re(bf1_out0_re),
                          .bf_out0_im(bf1_out0_im),
                          .bf_out1_re(bf1_out1_re),
                          .bf_out1_im(bf1_out1_im),
                          .cm_in0_re(cm2_in0_re),
                          .cm_in0_im(cm2_in0_im),
                          .cm_in1_re(cm2_in1_re),
                          .cm_in1_im(cm2_in1_im));

    // Commutator
    commutator_radix2 Commutator2 (.in_0_re(cm2_in0_re),
                                   .in_0_im(cm2_in0_im),
                                   .in_1_re(cm2_in1_re),
                                   .in_1_im(cm2_in1_im),
                                   .pattern(pattern2),
                                   .out_0_re(cm2_out0_re),
                                   .out_0_im(cm2_out0_im),
                                   .out_1_re(cm2_out1_re),
                                   .out_1_im(cm2_out1_im));

    // Post-Delay Commutator
    wire [15:0] bf2_in0_re;
    wire [15:0] bf2_in0_im;
    wire [15:0] bf2_in1_re;
    wire [15:0] bf2_in1_im;
    wire [15:0] bf2_out0_re;
    wire [15:0] bf2_out0_im;
    wire [15:0] bf2_out1_re;
    wire [15:0] bf2_out1_im;

    postdelay_commutator #(.DELAY_CYCLES(L1_L2_DELAY-1),                        // 15
                           .DELAY_BEFORE_SAVING(L1_L2_DELAY_BEFORE_SAVING),     // 0
                           .NUM_INPUTS_PER_PATH(NUM_INPUTS_PER_PATH))
    PostDelay_Commutator2 (.CLK(CLK),
                          .cntr_IFFT_input_pairs(cntr_IFFT_input_pairs),
                          .cm_out0_re(cm2_out0_re),
                          .cm_out0_im(cm2_out0_im),
                          .cm_out1_re(cm2_out1_re),
                          .cm_out1_im(cm2_out1_im),
                          .bf_in0_re(bf2_in0_re),
                          .bf_in0_im(bf2_in0_im),
                          .bf_in1_re(bf2_in1_re),
                          .bf_in1_im(bf2_in1_im));

    // Twiddle MUX2 (Choose between W0,W2,W4,...,W30)
    wire [15:0] twiddle2_re;
    wire [15:0] twiddle2_im;

    // Selection Signal: [4:0] twiddle_sel2 (Available range is 0,2,4,...,30)
    // Input: 512 bits; (twiddle_lut_re, twiddle_lut_im)
    // Output: 16 bits; (twiddle2_re, twiddle2_im)
    assign twiddle2_re = twiddle_lut_re[((CNTR_MAX_VALUE-twiddle_sel2)*NUM_BITS_PER_INPUT)+:16];
    assign twiddle2_im = twiddle_lut_im[((CNTR_MAX_VALUE-twiddle_sel2)*NUM_BITS_PER_INPUT)+:16];

    // Butterfly Unit (with Twiddle Factor)
    bf_radix2 BF2 (.A_re(bf2_in0_re),
                  .A_im(bf2_in0_im),
                  .B_re(bf2_in1_re),
                  .B_im(bf2_in1_im),
                  .W_re(twiddle2_re),
                  .W_im(twiddle2_im),
                  .Y0_re(bf2_out0_re),
                  .Y0_im(bf2_out0_im),
                  .Y1_re(bf2_out1_re),
                  .Y1_im(bf2_out1_im));


/************************************* LAYER 3 *************************************/
    // Pre-Delay to Commutator
    wire [15:0] cm3_in0_re;
    wire [15:0] cm3_in0_im;
    wire [15:0] cm3_in1_re;
    wire [15:0] cm3_in1_im;
    wire [15:0] cm3_out0_re;
    wire [15:0] cm3_out0_im;
    wire [15:0] cm3_out1_re;
    wire [15:0] cm3_out1_im;

    predelay_commutator #(.DELAY_CYCLES(L1_L2_DELAY + L2_L3_DELAY - 1),     // 23
                          .DELAY_BEFORE_SAVING(L2_L3_DELAY_BEFORE_SAVING),  // 16
                          .NUM_INPUTS_PER_PATH(32))
    PreDelay_Commutator3 (.CLK(CLK),
                          .cntr_IFFT_input_pairs(cntr_IFFT_input_pairs),
                          .bf_out0_re(bf2_out0_re),
                          .bf_out0_im(bf2_out0_im),
                          .bf_out1_re(bf2_out1_re),
                          .bf_out1_im(bf2_out1_im),
                          .cm_in0_re(cm3_in0_re),
                          .cm_in0_im(cm3_in0_im),
                          .cm_in1_re(cm3_in1_re),
                          .cm_in1_im(cm3_in1_im));

    // Commutator
    commutator_radix2 Commutator3 (.in_0_re(cm3_in0_re),
                                   .in_0_im(cm3_in0_im),
                                   .in_1_re(cm3_in1_re),
                                   .in_1_im(cm3_in1_im),
                                   .pattern(pattern3),
                                   .out_0_re(cm3_out0_re),
                                   .out_0_im(cm3_out0_im),
                                   .out_1_re(cm3_out1_re),
                                   .out_1_im(cm3_out1_im));

    // Post-Delay Commutator
    wire [15:0] bf3_in0_re;
    wire [15:0] bf3_in0_im;
    wire [15:0] bf3_in1_re;
    wire [15:0] bf3_in1_im;
    wire [15:0] bf3_out0_re;
    wire [15:0] bf3_out0_im;
    wire [15:0] bf3_out1_re;
    wire [15:0] bf3_out1_im;

    postdelay_commutator #(.DELAY_CYCLES(L1_L2_DELAY + L2_L3_DELAY - 1),        // 23
                           .DELAY_BEFORE_SAVING(L2_L3_DELAY_BEFORE_SAVING),     // 16
                           .NUM_INPUTS_PER_PATH(32))
    PostDelay_Commutator3 (.CLK(CLK),
                          .cntr_IFFT_input_pairs(cntr_IFFT_input_pairs),
                          .cm_out0_re(cm3_out0_re),
                          .cm_out0_im(cm3_out0_im),
                          .cm_out1_re(cm3_out1_re),
                          .cm_out1_im(cm3_out1_im),
                          .bf_in0_re(bf3_in0_re),
                          .bf_in0_im(bf3_in0_im),
                          .bf_in1_re(bf3_in1_re),
                          .bf_in1_im(bf3_in1_im));

    // Twiddle MUX3 (Choose between W0,W4,W8,...,W28)
    wire [15:0] twiddle3_re;
    wire [15:0] twiddle3_im;

    // Selection Signal: [4:0] twiddle_sel3 (Available range is 0,4,8,...,28)
    // Input: 512 bits; (twiddle_lut_re, twiddle_lut_im)
    // Output: 16 bits; (twiddle3_re, twiddle3_im)
    assign twiddle3_re = twiddle_lut_re[((CNTR_MAX_VALUE-twiddle_sel3)*NUM_BITS_PER_INPUT)+:16];
    assign twiddle3_im = twiddle_lut_im[((CNTR_MAX_VALUE-twiddle_sel3)*NUM_BITS_PER_INPUT)+:16];

    // Butterfly Unit (with Twiddle Factor)
    bf_radix2 BF3 (.A_re(bf3_in0_re),
                  .A_im(bf3_in0_im),
                  .B_re(bf3_in1_re),
                  .B_im(bf3_in1_im),
                  .W_re(twiddle3_re),
                  .W_im(twiddle3_im),
                  .Y0_re(bf3_out0_re),
                  .Y0_im(bf3_out0_im),
                  .Y1_re(bf3_out1_re),
                  .Y1_im(bf3_out1_im));


/************************************* LAYER 4 *************************************/
    // Pre-Delay to Commutator
    wire [15:0] cm4_in0_re;
    wire [15:0] cm4_in0_im;
    wire [15:0] cm4_in1_re;
    wire [15:0] cm4_in1_im;
    wire [15:0] cm4_out0_re;
    wire [15:0] cm4_out0_im;
    wire [15:0] cm4_out1_re;
    wire [15:0] cm4_out1_im;

    predelay_commutator #(.DELAY_CYCLES(L1_L2_DELAY + L2_L3_DELAY + L3_L4_DELAY - 1),     // 27
                          .DELAY_BEFORE_SAVING(L3_L4_DELAY_BEFORE_SAVING),                // 24
                          .NUM_INPUTS_PER_PATH(32))
    PreDelay_Commutator4 (.CLK(CLK),
                          .cntr_IFFT_input_pairs(cntr_IFFT_input_pairs),
                          .bf_out0_re(bf3_out0_re),
                          .bf_out0_im(bf3_out0_im),
                          .bf_out1_re(bf3_out1_re),
                          .bf_out1_im(bf3_out1_im),
                          .cm_in0_re(cm4_in0_re),
                          .cm_in0_im(cm4_in0_im),
                          .cm_in1_re(cm4_in1_re),
                          .cm_in1_im(cm4_in1_im));

    // Commutator
    commutator_radix2 Commutator4 (.in_0_re(cm4_in0_re),
                                   .in_0_im(cm4_in0_im),
                                   .in_1_re(cm4_in1_re),
                                   .in_1_im(cm4_in1_im),
                                   .pattern(pattern4),
                                   .out_0_re(cm4_out0_re),
                                   .out_0_im(cm4_out0_im),
                                   .out_1_re(cm4_out1_re),
                                   .out_1_im(cm4_out1_im));

    // Post-Delay Commutator
    wire [15:0] bf4_in0_re;
    wire [15:0] bf4_in0_im;
    wire [15:0] bf4_in1_re;
    wire [15:0] bf4_in1_im;
    wire [15:0] bf4_out0_re;
    wire [15:0] bf4_out0_im;
    wire [15:0] bf4_out1_re;
    wire [15:0] bf4_out1_im;

    postdelay_commutator #(.DELAY_CYCLES(L1_L2_DELAY + L2_L3_DELAY + L3_L4_DELAY - 1),  // 27
                           .DELAY_BEFORE_SAVING(L3_L4_DELAY_BEFORE_SAVING),             // 24
                           .NUM_INPUTS_PER_PATH(32))
    PostDelay_Commutator4 (.CLK(CLK),
                          .cntr_IFFT_input_pairs(cntr_IFFT_input_pairs),
                          .cm_out0_re(cm4_out0_re),
                          .cm_out0_im(cm4_out0_im),
                          .cm_out1_re(cm4_out1_re),
                          .cm_out1_im(cm4_out1_im),
                          .bf_in0_re(bf4_in0_re),
                          .bf_in0_im(bf4_in0_im),
                          .bf_in1_re(bf4_in1_re),
                          .bf_in1_im(bf4_in1_im));

    // Twiddle MUX4 (Choose between W0,W8,W16,W24)
    wire [15:0] twiddle4_re;
    wire [15:0] twiddle4_im;

    // Selection Signal: [4:0] twiddle_sel4 (Available range is 0,8,16,24)
    // Input: 512 bits; (twiddle_lut_re, twiddle_lut_im)
    // Output: 16 bits; (twiddle4_re, twiddle4_im)
    assign twiddle4_re = twiddle_lut_re[((CNTR_MAX_VALUE-twiddle_sel4)*NUM_BITS_PER_INPUT)+:16];
    assign twiddle4_im = twiddle_lut_im[((CNTR_MAX_VALUE-twiddle_sel4)*NUM_BITS_PER_INPUT)+:16];

    // Butterfly Unit (with Twiddle Factor)
    bf_radix2 BF4 (.A_re(bf4_in0_re),
                  .A_im(bf4_in0_im),
                  .B_re(bf4_in1_re),
                  .B_im(bf4_in1_im),
                  .W_re(twiddle4_re),
                  .W_im(twiddle4_im),
                  .Y0_re(bf4_out0_re),
                  .Y0_im(bf4_out0_im),
                  .Y1_re(bf4_out1_re),
                  .Y1_im(bf4_out1_im));


/************************************* LAYER 5 *************************************/
    // Pre-Delay to Commutator
    wire [15:0] cm5_in0_re;
    wire [15:0] cm5_in0_im;
    wire [15:0] cm5_in1_re;
    wire [15:0] cm5_in1_im;
    wire [15:0] cm5_out0_re;
    wire [15:0] cm5_out0_im;
    wire [15:0] cm5_out1_re;
    wire [15:0] cm5_out1_im;

    predelay_commutator #(.DELAY_CYCLES(L1_L2_DELAY + L2_L3_DELAY + L3_L4_DELAY + L4_L5_DELAY - 1),     // 29
                          .DELAY_BEFORE_SAVING(L4_L5_DELAY_BEFORE_SAVING),                              // 28
                          .NUM_INPUTS_PER_PATH(32))
    PreDelay_Commutator5 (.CLK(CLK),
                          .cntr_IFFT_input_pairs(cntr_IFFT_input_pairs),
                          .bf_out0_re(bf4_out0_re),
                          .bf_out0_im(bf4_out0_im),
                          .bf_out1_re(bf4_out1_re),
                          .bf_out1_im(bf4_out1_im),
                          .cm_in0_re(cm5_in0_re),
                          .cm_in0_im(cm5_in0_im),
                          .cm_in1_re(cm5_in1_re),
                          .cm_in1_im(cm5_in1_im));

    // Commutator
    commutator_radix2 Commutator5 (.in_0_re(cm5_in0_re),
                                   .in_0_im(cm5_in0_im),
                                   .in_1_re(cm5_in1_re),
                                   .in_1_im(cm5_in1_im),
                                   .pattern(pattern5),
                                   .out_0_re(cm5_out0_re),
                                   .out_0_im(cm5_out0_im),
                                   .out_1_re(cm5_out1_re),
                                   .out_1_im(cm5_out1_im));

    // Post-Delay Commutator
    wire [15:0] bf5_in0_re;
    wire [15:0] bf5_in0_im;
    wire [15:0] bf5_in1_re;
    wire [15:0] bf5_in1_im;
    wire [15:0] bf5_out0_re;
    wire [15:0] bf5_out0_im;
    wire [15:0] bf5_out1_re;
    wire [15:0] bf5_out1_im;

    postdelay_commutator #(.DELAY_CYCLES(L1_L2_DELAY + L2_L3_DELAY + L3_L4_DELAY + L4_L5_DELAY - 1),  // 29
                           .DELAY_BEFORE_SAVING(L4_L5_DELAY_BEFORE_SAVING),                           // 28
                           .NUM_INPUTS_PER_PATH(32))
    PostDelay_Commutator5 (.CLK(CLK),
                          .cntr_IFFT_input_pairs(cntr_IFFT_input_pairs),
                          .cm_out0_re(cm5_out0_re),
                          .cm_out0_im(cm5_out0_im),
                          .cm_out1_re(cm5_out1_re),
                          .cm_out1_im(cm5_out1_im),
                          .bf_in0_re(bf5_in0_re),
                          .bf_in0_im(bf5_in0_im),
                          .bf_in1_re(bf5_in1_re),
                          .bf_in1_im(bf5_in1_im));

    // Twiddle MUX5 (Choose between W0,W16)
    wire [15:0] twiddle5_re;
    wire [15:0] twiddle5_im;

    // Selection Signal: [4:0] twiddle_sel5 (Available range is 0,16)
    // Input: 512 bits; (twiddle_lut_re, twiddle_lut_im)
    // Output: 16 bits; (twiddle5_re, twiddle5_im)
    assign twiddle5_re = twiddle_lut_re[((CNTR_MAX_VALUE-twiddle_sel5)*NUM_BITS_PER_INPUT)+:16];
    assign twiddle5_im = twiddle_lut_im[((CNTR_MAX_VALUE-twiddle_sel5)*NUM_BITS_PER_INPUT)+:16];

    // Butterfly Unit (with Twiddle Factor)
    bf_radix2 BF5 (.A_re(bf5_in0_re),
                  .A_im(bf5_in0_im),
                  .B_re(bf5_in1_re),
                  .B_im(bf5_in1_im),
                  .W_re(twiddle5_re),
                  .W_im(twiddle5_im),
                  .Y0_re(bf5_out0_re),
                  .Y0_im(bf5_out0_im),
                  .Y1_re(bf5_out1_re),
                  .Y1_im(bf5_out1_im));


/************************************* LAYER 6 *************************************/
    // Pre-Delay to Commutator
    wire [15:0] cm6_in0_re;
    wire [15:0] cm6_in0_im;
    wire [15:0] cm6_in1_re;
    wire [15:0] cm6_in1_im;
    wire [15:0] cm6_out0_re;
    wire [15:0] cm6_out0_im;
    wire [15:0] cm6_out1_re;
    wire [15:0] cm6_out1_im;

    predelay_commutator #(.DELAY_CYCLES(L1_L2_DELAY + L2_L3_DELAY + L3_L4_DELAY + L4_L5_DELAY + L5_L6_DELAY - 1),     // 30
                          .DELAY_BEFORE_SAVING(L5_L6_DELAY_BEFORE_SAVING),                                            // 30
                          .NUM_INPUTS_PER_PATH(32))
    PreDelay_Commutator6 (.CLK(CLK),
                          .cntr_IFFT_input_pairs(cntr_IFFT_input_pairs),
                          .bf_out0_re(bf5_out0_re),
                          .bf_out0_im(bf5_out0_im),
                          .bf_out1_re(bf5_out1_re),
                          .bf_out1_im(bf5_out1_im),
                          .cm_in0_re(cm6_in0_re),
                          .cm_in0_im(cm6_in0_im),
                          .cm_in1_re(cm6_in1_re),
                          .cm_in1_im(cm6_in1_im));

    // Commutator
    commutator_radix2 Commutator6 (.in_0_re(cm6_in0_re),
                                   .in_0_im(cm6_in0_im),
                                   .in_1_re(cm6_in1_re),
                                   .in_1_im(cm6_in1_im),
                                   .pattern(pattern6),
                                   .out_0_re(cm6_out0_re),
                                   .out_0_im(cm6_out0_im),
                                   .out_1_re(cm6_out1_re),
                                   .out_1_im(cm6_out1_im));

    // Post-Delay Commutator
    wire [15:0] bf6_in0_re;
    wire [15:0] bf6_in0_im;
    wire [15:0] bf6_in1_re;
    wire [15:0] bf6_in1_im;
    wire [15:0] bf6_out0_re;
    wire [15:0] bf6_out0_im;
    wire [15:0] bf6_out1_re;
    wire [15:0] bf6_out1_im;

    postdelay_commutator #(.DELAY_CYCLES(L1_L2_DELAY + L2_L3_DELAY + L3_L4_DELAY + L4_L5_DELAY + L5_L6_DELAY - 1),  // 30
                           .DELAY_BEFORE_SAVING(L5_L6_DELAY_BEFORE_SAVING),                                         // 30
                           .NUM_INPUTS_PER_PATH(32))
    PostDelay_Commutator6 (.CLK(CLK),
                          .cntr_IFFT_input_pairs(cntr_IFFT_input_pairs),
                          .cm_out0_re(cm6_out0_re),
                          .cm_out0_im(cm6_out0_im),
                          .cm_out1_re(cm6_out1_re),
                          .cm_out1_im(cm6_out1_im),
                          .bf_in0_re(bf6_in0_re),
                          .bf_in0_im(bf6_in0_im),
                          .bf_in1_re(bf6_in1_re),
                          .bf_in1_im(bf6_in1_im));

    // Butterfly Unit (no Twiddle Factor)
    bf_radix2_noW BF6 (.A_re(bf6_in0_re),
                       .A_im(bf6_in0_im),
                       .B_re(bf6_in1_re),
                       .B_im(bf6_in1_im),
                       .Y0_re(bf6_out0_re),
                       .Y0_im(bf6_out0_im),
                       .Y1_re(bf6_out1_re),
                       .Y1_im(bf6_out1_im));
    
    assign ifft_out0_re = bf6_out0_re;
    assign ifft_out0_im = bf6_out0_im;
    assign ifft_out1_re = bf6_out1_re;
    assign ifft_out1_im = bf6_out1_im;


endmodule