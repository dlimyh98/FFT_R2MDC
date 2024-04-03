// Input ports
// A_re    -the 1st input (real part) of the radix butterfly unit (16 bits)
// B_re    -the 2nd input (real part) of the radix butterfly unit (16 bits)
// W_re    -the twiddle factor (real part) (16 bits)
// A_im    -the 1st input (imag part) of the radix butterfly unit (16 bits)
// B_im    -the 2nd input (imag part) of the radix butterfly unit (16 bits)
// W_im    -the twiddle factor (imag part) (16 bits)

// Output ports
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

/*
assign Y0_re = A_re;
assign Y0_im = A_im;
assign Y1_im = B_im;

wire signed [63:0] intermediate_re;
//reg signed [15:0] multiplicand = 16'sb1111111100000000; //FPR -1, NFPR -256
//reg signed [15:0] multiplicand = 16'sb0000000011111011; //FPR 0.98046875, NFPR 251
//reg signed [15:0] multiplicand = 16'sb0000_0000_0011_0001; //FPR 0.19140625, NFPR 49
reg signed [15:0] multiplicand = 16'sb1111_1111_0111_0010; //FPR -0.5546875, NFPR -142

// Sign extend B_re and the reg
wire signed [31:0] extended_B_re;
wire signed [31:0] extended_multiplicand;
wire signed [31:0] intermediate_re_cut;
assign extended_B_re = {{16{B_re[15]}}, B_re};
assign extended_multiplicand = {{16{multiplicand[15]}}, multiplicand};
assign intermediate_re = (extended_B_re * extended_multiplicand);

wire signed [31:0] intermediate_re_cut;
assign intermediate_re_cut = intermediate_re[31:0] >>> FIXED_POINT_NUM_FRACTIONAL_BITS;
assign Y1_re = (intermediate_re_cut);
*/

wire signed [15:0] X_re;
wire signed [15:0] X_im;
wire signed [31:0] extended_X_re;
wire signed [31:0] extended_X_im;
wire signed [31:0] extended_W_re;
wire signed [31:0] extended_W_im;
wire signed [63:0] intermediate_re;
wire signed [63:0] intermediate_im;

// Compute Y0 = A + B
assign Y0_re = (A_re + B_re);
assign Y0_im = (A_im + B_im);

// Compute Y1 = (A-B)*W
// (R+jI) = (X+jY)(C+jS)    ; (X+jY) is A-B, (C+jS) is twiddle factor (noting that C and S are stored in our twiddle factor LUT)
//        = (XC-YS)+j(XS+YC); R = XC-YS, I = XS+YC
//https://mathworld.wolfram.com/ComplexMultiplication.html

assign X_re = (A_re - B_re);
assign X_im = (A_im - B_im);
assign extended_X_re = {{16{X_re[15]}}, X_re};
assign extended_X_im = {{16{X_im[15]}}, X_im};
assign extended_W_re = {{16{W_re[15]}}, W_re};
assign extended_W_im = {{16{W_im[15]}}, W_im};

assign intermediate_re = (extended_X_re * extended_W_re) - (extended_X_im * extended_W_im);
assign intermediate_im = (extended_X_re * extended_W_im) + (extended_X_im * extended_W_re);
//assign intermediate_re = (A_minus_B_re * W_re) - (A_minus_B_im * W_im);
//assign intermediate_im = (A_minus_B_re * W_im) + (A_minus_B_im * W_re);

wire signed [31:0] intermediate_re_cut;
wire signed [31:0] intermediate_im_cut;
assign intermediate_re_cut = intermediate_re[31:0] >>> FIXED_POINT_NUM_FRACTIONAL_BITS;
assign intermediate_im_cut = intermediate_im[31:0] >>> FIXED_POINT_NUM_FRACTIONAL_BITS;

assign Y1_re = intermediate_re_cut;
assign Y1_im = intermediate_im_cut;

endmodule