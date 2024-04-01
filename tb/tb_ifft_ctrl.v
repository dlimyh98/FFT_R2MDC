module tb_ifft_ctrl(

    );

    reg tb_CLK;
    reg tb_ARSTN;
    reg tb_Start;
    wire tb_Start_Check;
    wire [9:0] tb_bank_addr;
    wire [4:0] tb_twiddle_sel1;
    wire [4:0] tb_twiddle_sel2;
    wire [4:0] tb_twiddle_sel3;
    wire [4:0] tb_twiddle_sel4;
    wire [4:0] tb_twiddle_sel5;
    wire tb_pattern2;
    wire tb_pattern3;
    wire tb_pattern4;
    wire tb_pattern5;
    wire tb_pattern6;
    wire [4:0] tb_cntr_IFFT_input_pairs;

    ifft_ctrl DUT (
        .CLK(tb_CLK),
        .ARSTN(tb_ARSTN),
        .Start(tb_Start),
        .Start_Check(tb_Start_Check),
        .bank_addr(tb_bank_addr),
        .twiddle_sel1(tb_twiddle_sel1),
        .twiddle_sel2(tb_twiddle_sel2),
        .twiddle_sel3(tb_twiddle_sel3),
        .twiddle_sel4(tb_twiddle_sel4),
        .twiddle_sel5(tb_twiddle_sel5),
        .pattern2(tb_pattern2),
        .pattern3(tb_pattern3),
        .pattern4(tb_pattern4),
        .pattern5(tb_pattern5),
        .pattern6(tb_pattern6),
        .cntr_IFFT_input_pairs(tb_cntr_IFFT_input_pairs)
    );

    /**************************** CLK GENERATION ****************************/
    initial begin
        tb_CLK = 1'b0;
        forever #25 tb_CLK = ~tb_CLK;
    end

    initial begin
        // Initial State
        tb_ARSTN = 1'b1;
        tb_Start = 1'b0;
        #200;

        // Apply Reset (Active Low)
        tb_ARSTN = 1'b0; #100; tb_ARSTN = 1'b1;

        // Start
        #50 tb_Start = 1'b1;
    end


endmodule