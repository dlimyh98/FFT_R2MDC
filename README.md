1. 64-bit FFT means N=64 (number of samples).


2. Need to do multiplication of two complex numbers, (a+jb) * (c+jd) in Butterfly Unit
    - Lets look at one of the complex numbers, (a+jb).
    - We have 16bits for real portion and 16 bits for imaginary portion.


3. Twiddle factors (real and imaginary) are pre-computed and stored in ..._lut_im_bin.txt
    - Note that for N=64 (i.e 64-bit FFT), we technically expect 64 twiddle factors. 
    - But we can exploit symmetry of twiddle factors to halve the expected number (64/2=32 twiddle factors expected).
    - Now, note that the twiddle factor stored in the LUT is 512 bits.
    - 512bits/32 expected twiddle factors = 16bits, which is exactly the number of bits we allocated for real/imaginary portion.
