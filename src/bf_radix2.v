// input ports
// A_re    -the 1st input (real part) of the radix butterfly unit (16 bits)
// B_re    -the 2nd input (real part) of the radix butterfly unit (16 bits)
// W_re    -the twiddle factor (real part) (16 bits)
// A_im    -the 1st input (imag part) of the radix butterfly unit (16 bits)
// B_im    -the 2nd input (imag part) of the radix butterfly unit (16 bits)
// W_im    -the twiddle factor (imag part) (16 bits)

// output ports
// Y0_re    -the 1st output (real part) of the radix butterfly unit (16 bits)
// Y1_re    -the 2nd output (real part) of the radix butterfly unit (16 bits)
// Y0_im    -the 1st output (imag part) of the radix butterfly unit (16 bits)
// Y1_im    -the 2nd output (imag part) of the radix butterfly unit (16 bits)

module bf_radix2
    (
        input signed [15:0] A_re,
        input signed [15:0] B_re,
        input signed [15:0] W_re,
        input signed [15:0] A_im,
        input signed [15:0] B_im,
        input signed [15:0] W_im,
        output signed [15:0] Y0_re,
        output signed [15:0] Y1_re,
        output signed [15:0] Y0_im,
        output signed [15:0] Y1_im
    );


// A, B, W, Y0, Y1 are complex numbers 
// Real and Img parts represented using 2's complement and fixed point representation
// 1 sign bit, 7 integer bits, 8 fractional bits
localparam FIXED_POINT_NUM_INTEGER_BITS = 7;
localparam FIXED_POINT_NUM_FRACTIONAL_BITS = 8;

wire signed [15:0] A_minus_B_re;
wire signed [15:0] A_minus_B_im;
wire signed [31:0] intermediate_re;
wire signed [31:0] intermediate_im;

// Compute Y0 = A + B
assign Y0_re = (A_re + B_re);
assign Y0_im = (A_im + B_im);

// Compute Y1 = (A-B)*W
// (R+jI) = (X+jY)(C+jS)    ; (X+jY) is A-B, (C+jS) is twiddle factor (noting that C and S are stored in our twiddle factor LUT)
//        = (XC-YS)+j(XS+YC); R = XC-YS, I = XS+YC

assign A_minus_B_re = (A_re - B_re);
assign A_minus_B_im = (A_im - B_im);

assign intermediate_re = (A_minus_B_re * W_re) - (A_minus_B_im * W_im);
assign intermediate_im = (A_minus_B_re * W_im) + (A_minus_B_im * W_re);

assign Y1_re = intermediate_re >> FIXED_POINT_NUM_FRACTIONAL_BITS;
assign Y1_im = intermediate_re >> FIXED_POINT_NUM_FRACTIONAL_BITS;

endmodule