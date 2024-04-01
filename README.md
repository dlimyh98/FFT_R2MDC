1. 64-bit FFT means N=64 (number of samples).


2. Need to do multiplication of two complex numbers, (a+jb) * (c+jd) in Butterfly Unit
    - Lets look at one of the complex numbers, (a+jb).
        - We have 16bits for real portion and 16 bits for imaginary portion.


3. Twiddle factors (real and imaginary) are pre-computed and stored in ..._lut_im_bin.txt AND ..._lut_re_bin.txt
    - Note that for N=64 (i.e 64-bit FFT), we technically expect 64 twiddle factors. 
        - But we can exploit symmetry of twiddle factors to halve the expected number (64/2 =32 twiddle factors expected).
    - Now, note that the twiddle factor stored in the LUT is 512 bits.
        - 512bits/32 expected twiddle factors = 16bits, which is exactly the number of bits we allocated for real/imaginary portion.


4. Naive implementation of 64-FFT is to build 32 Butterfly Units to operate in parallel, PER LAYER.
    - Note that this Butterfly Unit accepts TWO inputs (i.e  0,32; 1,33; ...)
    - Define num_layers = logbase(radix)(N) = log_2(64) = 6
        - Due to hardware considerations, we instead implement 1 Butterfly Unit PER LAYER. 
            - Which means the Butterfly Unit portion of each layer now takes 32 clock cycles to complete.


5. Multiplication Unit
    - Note that inputs are using 2's complement
    - test_ifft_in0_im_bin.txt has 1000 testcases (i.e 1000 lines)
        - Each line consists of a 512-bit long line
        - 512 bits / 16bits = 32 imaginary numbers through the 1st path of the pipeline (0,1,2,...,31)
        - The other 32 imaginary numbers come through test_ifft_in1_im_bin.txt (32,33,34,...,63)
        - Together, they form the 64 imaginary numbers that consist of ONE testcase


6. IFFT Control Unit
    - RECALL: Each butterfly unit needs 32 cycles to fully process ONE testcase (one testcase consists of 64 inputs evenly split through in0 and in1)
        - Therefore, we need to wait 32 cycles before we can feed inputs for the next testcase into BF1 (which will then propagate down to BF2...BF6)
    - The IFFT Pipeline needs to wait 32 cycles before the FIRST valid output of the FIRST testcase shows up at ifft_out0 and ifft_out1
        - You can see this by tracking the numDelays along a CERTAIN path
    - twiddle MUX unit
        - INPUTS: [4:0]twiddle_sel, [511:0]twiddle_lut_re, [511:0]twiddle_lut_im
        - OUTPUTS: [15:0] twiddle_lut_re, [15:0]twiddle_lut_im
        - MUX selection signal chooses between 2^5 = 32 different (twiddle_re,twiddle_im) twiddle factor pairs
            - Suppose we look at TWIDDLE_MUX_1 (Choose between W0,W1,...,W31)
                - i.e twiddle_sel1 == 5'b0; Choose [511:496] of twiddle_lut_re and twiddle_lut_im (W0)
                - i.e twiddle_sel1 == 5'b1; Choose [495:480] of twiddle_lut_re and twiddle_lut_im (W1)
            - Suppose we look at TWIDDLE_MUX_2 (Choose between W0,W2,...,W30)
                - i.e twiddle_sel2 == 5'b0; Choose [511:496] of twiddle_lut_re and twiddle_lut_im (W0)
                - i.e twiddle_sel2 == 5'b2; Choose [479:464] of twiddle_lut_re and twiddle_lut_im (W2)

7. Commutator Unit
    - Swaps INPUTS (cm_in0, cm_in1)

8. BFU Addition
    - Signed fixed point representation = <1,7,8> using 2s complement
        - Maximal value is 127.99609375
    - Suppose A = 0_111_1111_0111_1110   // 32638; 127.4921875
    - Suppose B = 0_111_1100_1111_1110   // 31998; 124.9921875
        - A + B = 1_111_1100_0111_1100   // Summation; -3.515625
        - We have an overflow.