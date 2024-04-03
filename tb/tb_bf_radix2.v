module tb_bf_radix2(

    );

    reg signed [15:0] tb_A_re;
    reg signed [15:0] tb_B_re;
    reg signed [15:0] tb_W_re;
    reg signed [15:0] tb_A_im;
    reg signed [15:0] tb_B_im;
    reg signed [15:0] tb_W_im;

    wire signed [15:0] tb_Y0_re;
    wire signed [15:0] tb_Y1_re;
    wire signed [15:0] tb_Y0_im;
    wire signed [15:0] tb_Y1_im;


    bf_radix2 DUT (
        .A_re(tb_A_re),
        .B_re(tb_B_re),
        .W_re(tb_W_re),
        .A_im(tb_A_im),
        .B_im(tb_B_im),
        .W_im(tb_W_im),
        .Y0_re(tb_Y0_re),
        .Y1_re(tb_Y1_re),
        .Y0_im(tb_Y0_im),
        .Y1_im(tb_Y1_im)
    );

    /* NFPR MULTIPLICATION

        A = -130-j567
        B = -770-j392
        W = 256+j25

        Y0 = A + B = -900 - j959

        Y1 = (A-B) * W
            = (640-j175) * (256+j25)
            = 168215 - j28800
    */

    initial begin
        //tb_A_re = 16'sb1_111_1111_0111_1110;    // NFPR -130. FPR -0.5078125
        tb_A_re = 16'sb0_000_0001_0000_0000;    
        tb_A_im = 16'sb0_000_0000_0001_1001;     // NFPR 25. FPR 0.09765625

        tb_B_re = 16'sb0_000_0001_0000_0000;    
        tb_B_im = 16'sb1_111_1011_0110_1101;    // NFPR -1171. FPR -4.57421875

        tb_W_re = 16'sb0_000_0001_0000_0000;    // NFPR 256. FPR 1
        tb_W_im = 16'sb0_000_0001_0000_0000;
    end

endmodule