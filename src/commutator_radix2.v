////////////////////////////////////////////////////////////////
// input ports
// in_0_re     -the 1st input (real part) of the commutator (16 bits)
// in_0_im     -the 1st input (imag part) of the commutator (16 bits)
// in_1_re     -the 2nd input (real part) of the commutator (16 bits)
// in_1_im     -the 2nd input (imag part) of the commutator (16 bits)
// pattern     -to re-order the inputs of the commutator

// output ports
// out_0_re    -the 1st output (real part) of the commutator (16 bits)
// out_0_im    -the 1st output (imag part) of the commutator (16 bits)
// out_1_re    -the 2nd output (real part) of the commutator (16 bits)
// out_1_im    -the 2nd output (imag part) of the commutator (16 bits)
////////////////////////////////////////////////////////////////
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

// wire definition
// fill in your code here


// commutator: depends on pattern, re-order the 1st and the 2nd input or not
// fill in your code here



endmodule
