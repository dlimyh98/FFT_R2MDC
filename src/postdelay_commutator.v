module postdelay_commutator #(parameter DELAY_CYCLES = 15,
                             parameter DELAY_BEFORE_SAVING = 0,
                             parameter NUM_INPUTS_PER_PATH = 32)
    (
        input CLK,
        input [4:0] cntr_IFFT_input_pairs,
        input [15:0] cm_out0_re,
        input [15:0] cm_out0_im,
        input [15:0] cm_out1_re,
        input [15:0] cm_out1_im,
        output reg [15:0] bf_in0_re,
        output reg [15:0] bf_in0_im,
        output [15:0] bf_in1_re,
        output [15:0] bf_in1_im
    );

reg begin_FF_output_aft_cm = 1'b0;
reg [4:0] FF_index_aft_cm = 5'b0;
reg [15:0] delay_FF_aft_cm_re [0:NUM_INPUTS_PER_PATH-1];
reg [15:0] delay_FF_aft_cm_im [0:NUM_INPUTS_PER_PATH-1];

assign bf_in1_re = cm_out1_re;
assign bf_in1_im = cm_out1_im;


// Delay 1st path after input to Commutator
always @ (posedge CLK) begin
    if (begin_FF_output_aft_cm) begin
        bf_in0_re <= delay_FF_aft_cm_re[FF_index_aft_cm];
        bf_in0_im <= delay_FF_aft_cm_im[FF_index_aft_cm];
        FF_index_aft_cm <= FF_index_aft_cm + 1;
    end
    else begin
        bf_in0_re <= 16'bx;
        bf_in0_im <= 16'bx;
    end
end


always @ (posedge CLK) begin
    // Save the 32 values from cm_out0 into FF registers
    if (cntr_IFFT_input_pairs >= DELAY_BEFORE_SAVING) begin
        // Cntr hasn't overflowed
        delay_FF_aft_cm_re[cntr_IFFT_input_pairs - DELAY_BEFORE_SAVING] <= cm_out0_re;
        delay_FF_aft_cm_im[cntr_IFFT_input_pairs - DELAY_BEFORE_SAVING] <= cm_out0_im;
    end
    else begin
        // Cntr overflowed, or it's writing garbage data (that will be overwritten)
        delay_FF_aft_cm_re[cntr_IFFT_input_pairs + DELAY_BEFORE_SAVING] <= cm_out0_re;
        delay_FF_aft_cm_im[cntr_IFFT_input_pairs + DELAY_BEFORE_SAVING] <= cm_out0_im;
    end

    if (cntr_IFFT_input_pairs >= DELAY_CYCLES-1) begin
        // Signal to output saved values from FF (Begins two cycles from now)
        begin_FF_output_aft_cm <= 1'b1;
    end

    /*
    if (FF_index_aft_cm == NUM_INPUTS_PER_PATH-1) begin
        begin_FF_output_aft_cm <= 1'b0;
        FF_index_aft_cm <= 5'bX;
        //enable_FF_saving_aft_cm <= 1'b0;
    end
    */
end

endmodule