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
    - The IFFT Pipeline needs to wait 31 cycles before the FIRST valid output of the FIRST testcase shows up at ifft_out0 and ifft_out1
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


9. BFU Verification (Layer 1 and Layer 2)
    - testCase = 0
        BF1 OUTPUTS; [ (bf1_out0_re, bf1_out0_im) , (bf1_out1_re, bf1_out1_im) ]
            0th Output  : (64636, 64577) , (640, 65361)  ;0,32
            1st Output  : (65377,912) , (63926,725)      ;1,33
            2nd Output  : (64266,63597) , (64674,333)    ;2,34
            3rd Output  : (792,64540) , (64731,64931)    ;15,47
            6th Output  : (127,63492) , (243,65181)      ;6,38
            10th Output : (42,65235), (2554,1017)        ;10,42
            14th Output : (945,65028) , (63764,64993)    ;14,46
            16th Output : (64780,63907) , (791,1028)     ;16,48
            17th Output : (230,64463) , (44665,33560)    ;17,49
            18th Output : (63632,1896) , (49122,52542)   ;18,50
            22nd Output : (63880,65500) , (29743,38120)  ;22,54
            26th Output : (118,696) , (27681,2495)       ;26,58
            30th Output : (88,65234) , (43355,52298)     ;30,62
            31st Output : (234,310) , (8894,60208)       ;31,63

        BF2 INPUTS; [ (bf2_in0_re, bf2_in0_im) , (bf2_in1_re, bf2_in1_im) ]
            0th Input   : (64636, 64577) , (64780,63907)  ;0,16
            1st Input   : (65377,912) , (230,64463)       ;1,17
            2nd Input   : (64266,63957) , (63632,1896)    ;2,18
            18th Input  : (64674,333) , (49122,52542)     ;34,50
            22nd Input  : (243,65181) , (29743,38120)     ;38,54
            26th Input  : (2554,1017) , (27681,2495)      ;42,58


    - testCase = 1
        BF1 OUTPUTS; [ (bf1_out0_re, bf1_out0_im) , (bf1_out1_re, bf1_out1_im) ]
            0th Output  : (986,64110) , (1500,65508)  ;0,32
            6th Output  : (572,65429) , (882,64787)   ;6,38
            16th Output : (412,1108) , (65044,65046)  ;16,48
            22nd Output : (2089,1047) , (11164,31970) ;22,54

        BF2 INPUTS; [ (bf2_in0_re, bf2_in0_im) , (bf2_in1_re, bf2_in1_im) ]
            0th Input  : (986,64110) , (412,1108)     ;0,16
            22nd Input : (882,64787) , (11164,31970)  ;38,54



10. BFU Verification (Layer 2 and Layer 3)
    - testCase = 0
        BF2 OUTPUTS; [ (bf2_out0_re, bf2_out0_im) , (bf2_out1_re, bf2_out1_im) ]
            0th Output  : (63880,62948) , (65392,670)    ;0,16
            1st Output  : (71,65375) , (64774,1871)      ;1,17
            2nd Output  : (62362,65493) , (2037,62240)   ;2,18
            8th Output  : (1296,597) , (1755,65220)      ;8,24
            9th Output  : (64617,1856) , (50642,7844)    ;9,25
            10th Output : (160,395) , (56755,3763)       ;10,26
            17th Output : (43055,34285) , (12625,35748)  ;33,49
            19th Output : (56434,7291) , (10140,62535)   ;35,51
            25th Output : (30736,39840) , (41970,39465)  ;41,57
            27th Output : (17877,8452) , (53247,30024)   ;43,59

        BF3 INPUTS; [ (bf3_in0_re, bf3_in0_im) , (bf3_in1_re, bf3_in1_im) ]
            0th Input  : (63380,62948) , (1296,597)      ;0,8
            1st Input : (71,65375) , (64617,1856)        ;1,9
            2nd Input : (62362,65493) , (160,395)        ;2,10
            17th Input : (43055,34285) , (30736,39840)   ;33,41
            27th Input : (10140,62535) , (53247,30024)   ;51,59


    - testCase = 1
        BF2 OUTPUTS; [ (bf2_out0_re, bf2_out0_im) , (bf2_out1_re, bf2_out1_im) ]
            0th Output  : (1398,65218) , (574,63002)    ;0,16
            8th Output  : (64067,64910) , (65392,63411) ;8,24
            17th Output : (9767,44660) , (52841,18743)  ;33,49
            19th Output : (18696,8066) , (52971,50984)  ;35,51
            25th Output : (31450,17442) , (58311,7693)  ;41,57
            27th Output : (48741,28615) , (52427,13727) ;43,59

        BF3 INPUTS; [ (bf3_in0_re, bf3_in0_im) , (bf3_in1_re, bf3_in1_im) ]
            0th Input  : (1398,65218) , (64067,64910)    ;0,8
            17th Input : (9767,44660) , (31450,17442)    ;33,41
            27th Input : (52971,50984) , (52427,13727)   ;51,59

11. BFU Verification (Layer 3 and Layer 4)
    - testCase = 0
        BF3 OUTPUTS; [ (bf3_out0_re, bf3_out0_im) , (bf3_out1_re, bf3_out1_im) ]
            0th Output  : (65176,63545) , (62584,62351)    ;0,8
            1st Output  : (64688,1695) , (1676,64051)      ;1,9
            2nd Output  : (62522,352) , (63488,62869)      ;2,10
            6th Output  : (65040,62646) , (2453,33134)     ;6,14
            4th Output  : (63527,63237) , (64375,65511)    ;4,12
            5th Output  : (64046,2307) , (54382,58679)     ;5,13
            16th Output : (48762,23936) , (19636,43306)    ;32,40
            20th Output : (42493,51904) , (21634,41243)    ;36,44

        BF4 INPUTS; [ (bf4_in0_re, bf4_in0_im) , (bf4_in1_re, bf4_in1_im) ]
            0th Input  : (65176,63545) , (63527,63237)      ;0,4
            2nd Input  : (62522,352) , (65040,62646)        ;2,6
            5th Input  : (1676,64051) , (54382,58679)       ;9,13
            20th Input : (19636,43306) , (21634,41243)      ;40,44


    - testCase = 1
        BF3 OUTPUTS; [ (bf3_out0_re, bf3_out0_im) , (bf3_out1_re, bf3_out1_im) ]
            0th Output  : (65465,64592) , (2867,308)    ;0,8
            4th Output  : (1104,254) , (64836,1020)     ;4,12
            16th Output : (18598,47480) , (48954,17020) ;32,40
            20th Output : (2255,37271) , (20243,30003)  ;36,44

        BF4 INPUTS; [ (bf4_in0_re, bf4_in0_im) , (bf4_in1_re, bf4_in1_im) ]
            0th Input  : (65465,64592) , (1104,254)     ;0,4
            20th Input : (48954,17020) , (20243,30003)  ;40,44


    - testCase = 2
        BF3 OUTPUTS; [ (bf3_out0_re, bf3_out0_im) , (bf3_out1_re, bf3_out1_im) ]
            16th Output : (59985,7999) , (7831,58735)    ;32,40
            20th Output : (28280,11220) , (23598,30456)  ;36,44

        BF4 INPUTS; [ (bf4_in0_re, bf4_in0_im) , (bf4_in1_re, bf4_in1_im) ]
            20th Input : (7831,58735) , (23598,30456)  ;40,44





12. BFU Verification (Layer 4 and Layer 5)
    - testCase = 0
        BF4 OUTPUTS; [ (bf4_out0_re, bf4_out0_im) , (bf4_out1_re, bf4_out1_im) ]
            0th Output : (63167,61246) , (1649,308)       ;0,4
            2nd Output : (62026,62998) , (62294,63018)    ;2,6
            16th Output : (25719,10304) , (6269,37568)    ;32,36
            18th Output : (18992,14835) , (33133,6926)    ;34,38

        BF5 INPUTS; [ (bf5_in0_re, bf5_in0_im) , (bf5_in1_re, bf5_in1_im) ]
            0th Input : (63167,61246) , (62026,62998)     ;0,2
            2nd Output : (1649,308) , (62294,63018)       ;4,6
            18th Input : (6269,37568) , (33133,6926)      ;36,38

13. BFU Verification (Layer 5 and Layer 6)
    - testCase = 0
        BF5 OUTPUTS; [ (bf5_out0_re, bf5_out0_im) , (bf5_out1_re, bf5_out1_im) ]
            0th Output : (59657,58708) , (1141,63784)       ;0,2
            1st Output : (2122,2192) , (59724,58738)        ;1,3
            2nd Output : (63943,63326) , (4891,2826)        ;4,6
            3rd Output : (32629,54355) , (54313,34679)      ;5,7
            8th Output : (16383,27550) , (3459,11024)       ;16,18
            9th Output : (9592,40955) , (7361,25602)        ;17,19
            22nd Output : (42672,50776) , (18868,18886)     ;44,46
            23rd Output : (57029,16546) , (31614,2323)      ;45,47

        BF6 INPUTS; [ (bf6_in0_re, bf6_in0_im) , (bf6_in1_re, bf6_in1_im) ]
            0th Input : (59657,58708) , (2122,2192)     ;0,1
            1st Input : (1141,63784) , (59724,58738)    ;2,3
            2nd Input : (63943,63326) , (32629,54355)   ;4,5
            9th Input : (3459,11024) , (7361,25602)     ;18,19
            23rd Input : (18868,18886) , (31614,2323)   ;46,47


    - testCase = 1
        BF5 OUTPUTS; [ (bf5_out0_re, bf5_out0_im) , (bf5_out1_re, bf5_out1_im) ]
            26th Output : (32838,9614) , (31772,49626)       ;52,54
            27th Output : (10762,13554) , (24906,52248)      ;53,55

        BF6 INPUTS; [ (bf6_in0_re, bf6_in0_im) , (bf6_in1_re, bf6_in1_im) ]
            27th Input : (31772,49626) , (24906,52248)   ;54,55

    - testCase = 2
        BF5 OUTPUTS; [ (bf5_out0_re, bf5_out0_im) , (bf5_out1_re, bf5_out1_im) ]
            0th Output : () , ()       ;0,2
            1st Output : () , (59724,58738)        ;1,3

        BF6 INPUTS; [ (bf6_in0_re, bf6_in0_im) , (bf6_in1_re, bf6_in1_im) ]
            0th Input : () , ()   ;0,1


14. Problem Solving
    - 2nd Input onwards of each testcase seems to be consistently wrong
        - We are getting (31036-j13391), (31314+j8971)
        - It should be (2108+j945), (-5294-j5365)





15. How does the testbench work?
    - cnt_cal is still incrementing even in State CAL
    - We wait for cnt_cal == 32 before transitioning to CAL stage.
        - This means we are waiting for this first valid output to show up at ifft_out
    - IFFT pipeline requires 31 cycles for valid output to show up
        - Therefore, we have to CHANGE to CAL stage by Cycle31


16. Twiddle
0
0000000100000000
0000000100000000

1
0000000011111110
0000000011111110

2
0000000011111011
0000000011111011

3
0000000011110100
0000000011110100

4
0000000011101100
0000000011101100

5
0000000011100001
0000000011100001

6
0000000011010100
0000000011010100

7
0000000011000101
0000000011000101

8
0000000010110101
0000000010110101

9
0000000010100010
0000000010100010

10
0000000010001110
0000000010001110

11
0000000001111000
0000000001111000

12
0000000001100001
0000000001100001

13
0000000001001010
0000000001001010

14
0000000000110001
0000000000110001

15
0000000000011001
0000000000011001

16
0000000000000000
0000000000000000

17
1111111111100111
0111111111100111


11111111110011111111111110110110111111111001111111111111100010001111111101110010111111110101111011111111010010111111111100111011111111110010110011111111000111111111111100010100111111110000110011111111000001011111111100000010