// Input ports
// in_0_re     -the 1st input (real part) of the commutator (16 bits)
// in_0_im     -the 1st input (imag part) of the commutator (16 bits)
// in_1_re     -the 2nd input (real part) of the commutator (16 bits)
// in_1_im     -the 2nd input (imag part) of the commutator (16 bits)
// pattern     -Enable signal, tells us whether to re-order the inputs of the commutator

// Output ports
// out_0_re    -the 1st output (real part) of the commutator (16 bits)
// out_0_im    -the 1st output (imag part) of the commutator (16 bits)
// out_1_re    -the 2nd output (real part) of the commutator (16 bits)
// out_1_im    -the 2nd output (imag part) of the commutator (16 bits)

module commutator_radix2
    (
        input [15:0] in_0_re,
        input [15:0] in_0_im,
        input [15:0] in_1_re,
        input [15:0] in_1_im,
        input pattern,
        output [15:0] out_0_re,
        output [15:0] out_0_im,
        output [15:0] out_1_re,
        output [15:0] out_1_im
    );

    assign out_0_re = (pattern) ? in_1_re : in_0_re;
    assign out_0_im = (pattern) ? in_1_im : in_0_im;
    assign out_1_re = (pattern) ? in_0_re : in_1_re;
    assign out_1_im = (pattern) ? in_0_im : in_1_im;

endmodule