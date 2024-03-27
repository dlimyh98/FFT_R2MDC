1. 64-bit FFT means N=64 (number of samples).


2. Need to do multiplication of two complex numbers, (a+jb) * (c+jd) in Butterfly Unit
    - Lets look at one of the complex numbers, (a+jb).
    - We have 16bits for real portion and 16 bits for imaginary portion.


3. Twiddle factors (real and imaginary) are pre-computed and stored in ..._lut_im_bin.txt AND ..._lut_re_bin.txt
    - Note that for N=64 (i.e 64-bit FFT), we technically expect 64 twiddle factors. 
    - But we can exploit symmetry of twiddle factors to halve the expected number (64/2=32 twiddle factors expected).
    - Now, note that the twiddle factor stored in the LUT is 512 bits.
    - 512bits/32 expected twiddle factors = 16bits, which is exactly the number of bits we allocated for real/imaginary portion.


4. Naive implementation of 64-FFT is to build 32 Butterfly Units to operate in parallel, PER LAYER.
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