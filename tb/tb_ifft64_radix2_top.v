module tb_ifft64_radix2_top();

    parameter TEST_CASE = 1000;
    parameter CYCLES_OF_EACH_CASE = 32;
    parameter NUM_OF_TEST_CYCLES = (TEST_CASE+1)*CYCLES_OF_EACH_CASE-1;

    parameter CLK_PERIOD = 40;
    parameter HALF_CLK_PERIOD = CLK_PERIOD/2;
    parameter QUARTER_CLK_PERIOD = CLK_PERIOD/4;

    reg clk;
    reg arstn;
    reg start;
    reg [511:0] ifft_in0_re;
    reg [511:0] ifft_in0_im;
    reg [511:0] ifft_in1_re;
    reg [511:0] ifft_in1_im;
    reg [511:0] twiddle_lut_re;
    reg [511:0] twiddle_lut_im;
    wire [15:0] ifft_out0_re;
    wire [15:0] ifft_out0_im;
    wire [15:0] ifft_out1_re;
    wire [15:0] ifft_out1_im;
    wire start_check;
    wire [9:0] bank_addr;

    ifft64_radix2_top DUT
        (   
            .CLK(clk), 
            .ARSTN(arstn),
            .Start(start),
            .ifft_in0_re(ifft_in0_re),
            .ifft_in0_im(ifft_in0_im),
            .ifft_in1_re(ifft_in1_re),
            .ifft_in1_im(ifft_in1_im),
            .twiddle_lut_re(twiddle_lut_re),
            .twiddle_lut_im(twiddle_lut_im),
            .ifft_out0_re(ifft_out0_re),
            .ifft_out0_im(ifft_out0_im),
            .ifft_out1_re(ifft_out1_re),
            .ifft_out1_im(ifft_out1_im),
            .start_check(start_check),
            .bank_addr(bank_addr)
        );

    // Read inputs
    reg [511:0] test_twiddle_lut_re_bin [0:0];
    reg [511:0] test_twiddle_lut_im_bin [0:0];
    reg [511:0] test_ifft_in0_re_bin [0:TEST_CASE-1];
    reg [511:0] test_ifft_in0_im_bin [0:TEST_CASE-1];
    reg [511:0] test_ifft_in1_re_bin [0:TEST_CASE-1];
    reg [511:0] test_ifft_in1_im_bin [0:TEST_CASE-1];
    reg [15:0] test_ifft_out0_reference_re_bin [0:TEST_CASE*32-1];
    reg [15:0] test_ifft_out0_reference_im_bin [0:TEST_CASE*32-1];
    reg [15:0] test_ifft_out1_reference_re_bin [0:TEST_CASE*32-1];
    reg [15:0] test_ifft_out1_reference_im_bin [0:TEST_CASE*32-1];

    initial begin
        /* Use below if compiling manually
        $readmemb("../ref/test_twiddle_lut_re_bin.txt",test_twiddle_lut_re_bin);
        $readmemb("../ref/test_twiddle_lut_im_bin.txt",test_twiddle_lut_im_bin);
        $readmemb("../ref/test_ifft_in0_re_bin.txt",test_ifft_in0_re_bin);
        $readmemb("../ref/test_ifft_in0_im_bin.txt",test_ifft_in0_im_bin);
        $readmemb("../ref/test_ifft_in1_re_bin.txt",test_ifft_in1_re_bin);
        $readmemb("../ref/test_ifft_in1_im_bin.txt",test_ifft_in1_im_bin);
        $readmemb("../ref/test_ifft_out0_reference_re_bin.txt",test_ifft_out0_reference_re_bin);
        $readmemb("../ref/test_ifft_out0_reference_im_bin.txt",test_ifft_out0_reference_im_bin);
        $readmemb("../ref/test_ifft_out1_reference_re_bin.txt",test_ifft_out1_reference_re_bin);
        $readmemb("../ref/test_ifft_out1_reference_im_bin.txt",test_ifft_out1_reference_im_bin);
        */
        $readmemb("test_twiddle_lut_re_bin.txt",test_twiddle_lut_re_bin);
        $readmemb("test_twiddle_lut_im_bin.txt",test_twiddle_lut_im_bin);
        $readmemb("test_ifft_in0_re_bin.txt",test_ifft_in0_re_bin);
        $readmemb("test_ifft_in0_im_bin.txt",test_ifft_in0_im_bin);
        $readmemb("test_ifft_in1_re_bin.txt",test_ifft_in1_re_bin);
        $readmemb("test_ifft_in1_im_bin.txt",test_ifft_in1_im_bin);
        $readmemb("test_ifft_out0_reference_re_bin.txt",test_ifft_out0_reference_re_bin);
        $readmemb("test_ifft_out0_reference_im_bin.txt",test_ifft_out0_reference_im_bin);
        $readmemb("test_ifft_out1_reference_re_bin.txt",test_ifft_out1_reference_re_bin);
        $readmemb("test_ifft_out1_reference_im_bin.txt",test_ifft_out1_reference_im_bin);
    end


    /**************************** CLK GENERATION ****************************/
    initial begin
        clk = 1'b0;
        forever #HALF_CLK_PERIOD clk = ~clk;
    end


    /**************************** PROVIDE DUT INPUTS ****************************/
    always @(*) begin
        twiddle_lut_re = test_twiddle_lut_re_bin[0];
        twiddle_lut_im = test_twiddle_lut_im_bin[0];
        ifft_in0_re = test_ifft_in0_re_bin[bank_addr];
        ifft_in0_im = test_ifft_in0_im_bin[bank_addr];
        ifft_in1_re = test_ifft_in1_re_bin[bank_addr];
        ifft_in1_im = test_ifft_in1_im_bin[bank_addr];
    end


    /**************************** TESTING ****************************/
    integer i,j,k;
    integer num_of_errors = 0;
    reg [15:0] ifft_out0_re_check [0:TEST_CASE*32-1];
    reg [15:0] ifft_out0_im_check [0:TEST_CASE*32-1];
    reg [15:0] ifft_out1_re_check [0:TEST_CASE*32-1];
    reg [15:0] ifft_out1_im_check [0:TEST_CASE*32-1];

    initial begin
	    //$vcdplusfile("waveform.vpd");
        //$vcdpluson();
        
        // Initial state
        arstn = 1'b1;
        start = 1'b0;
        #QUARTER_CLK_PERIOD;
        #CLK_PERIOD;
        #CLK_PERIOD;
        #CLK_PERIOD;
        #CLK_PERIOD;

        // Reset
        arstn = 1'b0;
        #CLK_PERIOD;
        #CLK_PERIOD;
        #CLK_PERIOD;
        #CLK_PERIOD;
        arstn = 1'b1;
        #CLK_PERIOD;
        #CLK_PERIOD;
        #CLK_PERIOD;
        #CLK_PERIOD;

        // Start
        start = 1'b1;
        for (i = 0;i < NUM_OF_TEST_CYCLES; i = i + 1) begin
            #CLK_PERIOD;
        end

        #CLK_PERIOD;
        #CLK_PERIOD;
        #CLK_PERIOD;
        #CLK_PERIOD;
        $display("Testcase Checking Loop\n");

        for (j = 0; j < TEST_CASE-1; j = j + 1) begin
            for (k = 0; k < 32; k = k + 1) begin
                if ((ifft_out0_re_check[j*32+k] == test_ifft_out0_reference_re_bin[j*32+k])&&
                    (ifft_out0_im_check[j*32+k] == test_ifft_out0_reference_im_bin[j*32+k])&&
                    (ifft_out1_re_check[j*32+k] == test_ifft_out1_reference_re_bin[j*32+k])&&
                    (ifft_out1_im_check[j*32+k] == test_ifft_out1_reference_im_bin[j*32+k])) begin
                        num_of_errors = num_of_errors;
                end
                else begin
                    num_of_errors = num_of_errors + 1;
                    $display("There is a failure at the %d th cycle in the %d th test case",k,j);
                end
            end
        end

        if (num_of_errors == 0) begin
            $display("\n\n\nCongratulations, your code passed all the tests...\n\n\n");
        end
        else begin
            $display("\n\n\nYour code didn't pass all tests...");
        end
        $display("\n");

        // Stop
        //$vcdplusoff();
        $finish;	
    end


    /**************************** RECEIVE OUTPUT ****************************/
    reg [9:0] cnt_test_case;
    reg [4:0] cnt_cycle;

    initial begin
        cnt_test_case = 10'd0;
        cnt_cycle = 5'd0;
    end

    always @(negedge clk) begin
	    if (start_check) begin
            ifft_out0_re_check[cnt_test_case*32+cnt_cycle] = ifft_out0_re;
            ifft_out0_im_check[cnt_test_case*32+cnt_cycle] = ifft_out0_im;
            ifft_out1_re_check[cnt_test_case*32+cnt_cycle] = ifft_out1_re;
            ifft_out1_im_check[cnt_test_case*32+cnt_cycle] = ifft_out1_im;
            cnt_cycle = cnt_cycle + 5'd1;

            if (cnt_cycle == 5'd0) begin
                cnt_test_case = cnt_test_case + 10'd1;
            end
        end
    end

endmodule