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

wire signed [15:0] X_re;
wire signed [15:0] X_im;
wire signed [31:0] extended_X_re;
wire signed [31:0] extended_X_im;
wire signed [31:0] extended_W_re;
wire signed [31:0] extended_W_im;

wire signed [15:0] intermediate_re;
wire signed [15:0] intermediate_im;

wire signed [63:0] intermediate_re1;
wire signed [63:0] intermediate_re2;
wire signed [63:0] intermediate_im1;
wire signed [63:0] intermediate_im2;

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

wire signed [15:0] intermediate_re3;
wire signed [15:0] intermediate_re4;
wire signed [15:0] intermediate_re5;
wire signed [15:0] intermediate_re6;
wire signed [15:0] intermediate_re7;

wire signed [15:0] intermediate_im3;
wire signed [15:0] intermediate_im4;
wire signed [15:0] intermediate_im5;
wire signed [15:0] intermediate_im6;
wire signed [15:0] intermediate_im7;

assign intermediate_re1 = (extended_X_re * extended_W_re);  // 64bits
assign intermediate_re2 = (extended_X_im * extended_W_im);  //64bits

assign intermediate_re3 = intermediate_re1[31:0] >>> FIXED_POINT_NUM_FRACTIONAL_BITS;
assign intermediate_re4 = (intermediate_re1[63]) ? intermediate_re3 + intermediate_re1[7] : intermediate_re3 - intermediate_re1[7];

assign intermediate_re5 = intermediate_re2[31:0] >>> FIXED_POINT_NUM_FRACTIONAL_BITS;
assign intermediate_re6 = (intermediate_re2[63]) ? intermediate_re5 + intermediate_re2[7] : intermediate_re5 - intermediate_re2[7];

assign intermediate_re = intermediate_re4 - intermediate_re6;


assign intermediate_im1 = (extended_X_re * extended_W_im);
assign intermediate_im2 = (extended_X_im * extended_W_re);

assign intermediate_im3 = intermediate_im1[31:0] >> FIXED_POINT_NUM_FRACTIONAL_BITS;
assign intermediate_im4 = (intermediate_im1[63]) ? intermediate_im3 + intermediate_im1[7] : intermediate_im3 - intermediate_im1[7];

assign intermediate_im5 = intermediate_im2[31:0] >> FIXED_POINT_NUM_FRACTIONAL_BITS;

assign intermediate_im6 = (intermediate_im2[63]) ? (intermediate_im2[31:0] >>> FIXED_POINT_NUM_FRACTIONAL_BITS) + intermediate_im2[7]
                                : (intermediate_im2[31:0] >>> FIXED_POINT_NUM_FRACTIONAL_BITS) - intermediate_im2[7];

assign intermediate_im = intermediate_im4 + intermediate_im6;

//assign intermediate_re = (extended_X_re * extended_W_re) - (extended_X_im * extended_W_im);
//assign intermediate_im = (extended_X_re * extended_W_im) + (extended_X_im * extended_W_re);

assign Y1_re = intermediate_re;
assign Y1_im = intermediate_im;

endmodule