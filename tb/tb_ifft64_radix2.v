module tb_ifft64_radix2(

    );

    reg tb_CLK;
    reg tb_ARSTN;
    reg [511:0] tb_ifft_in0_re;
    reg [511:0] tb_ifft_in0_im;
    reg [511:0] tb_ifft_in1_re;
    reg [511:0] tb_ifft_in1_im;
    reg [511:0] tb_twiddle_lut_re;
    reg [511:0] tb_twiddle_lut_im;

    reg [4:0] tb_twiddle_sel1;
    reg [4:0] tb_twiddle_sel2;
    reg [4:0] tb_twiddle_sel3;
    reg [4:0] tb_twiddle_sel4;
    reg [4:0] tb_twiddle_sel5;
    reg tb_pattern2;
    reg tb_pattern3;
    reg tb_pattern4;
    reg tb_pattern5;
    reg tb_pattern6;
    reg [4:0] tb_cntr_IFFT_input_pairs;

    wire [15:0] tb_ifft_out0_re;
    wire [15:0] tb_ifft_out0_im;
    wire [15:0] tb_ifft_out1_re;
    wire [15:0] tb_ifft_out1_im;

    ifft64_radix2 DUT (
        .CLK(tb_CLK),
        .ARSTN(tb_ARSTN),
        .ifft_in0_re(tb_ifft_in0_re),
        .ifft_in0_im(tb_ifft_in0_im),
        .ifft_in1_re(tb_ifft_in1_re),
        .ifft_in1_im(tb_ifft_in1_im),
        .twiddle_lut_re(tb_twiddle_lut_re),
        .twiddle_lut_im(tb_twiddle_lut_im),
    );


endmodule