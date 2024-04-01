module predelay_commutator #(parameter DELAY_CYCLES = 15,
                             parameter NUM_INPUTS_PER_PATH = 32)
    (
        input CLK,
        input [4:0] cntr_IFFT_input_pairs,
        input [15:0] bf_out0_re,
        input [15:0] bf_out0_im,
        input [15:0] bf_out1_re,
        input [15:0] bf_out1_im,
        output [15:0] cm_in0_re,
        output [15:0] cm_in0_im,
        output reg [15:0] cm_in1_re,
        output reg [15:0] cm_in1_im
    );

reg begin_FF_output_bef_cm = 1'b0;
reg enable_FF_saving_bef_cm = 1'b1;
reg [4:0] FF_index_bef_cm = 5'b0;
reg [15:0] delay_FF_bef_cm_re [0:NUM_INPUTS_PER_PATH-1];
reg [15:0] delay_FF_bef_cm_im [0:NUM_INPUTS_PER_PATH-1];

assign cm_in0_re = bf_out0_re;
assign cm_in0_im = bf_out0_im;


// Delay 2nd path before input to Commutator
always @ (posedge CLK) begin
    if (begin_FF_output_bef_cm) begin
        cm_in1_re <= delay_FF_bef_cm_re[FF_index_bef_cm];
        cm_in1_im <= delay_FF_bef_cm_im[FF_index_bef_cm];
        FF_index_bef_cm <= FF_index_bef_cm + 1;
    end
    else begin
        cm_in1_re <= 16'bx;
        cm_in1_im <= 16'bx;
    end
end

always @ (posedge CLK) begin
    // Save the 32 values from bf1_out1 into FF registers
    if (enable_FF_saving_bef_cm) begin
        delay_FF_bef_cm_re[cntr_IFFT_input_pairs] <= bf_out1_re;
        delay_FF_bef_cm_im[cntr_IFFT_input_pairs] <= bf_out1_im;

        if (cntr_IFFT_input_pairs >= DELAY_CYCLES-1) begin
            // Signal to output saved values from FF (Begins two cycles from now)
            begin_FF_output_bef_cm <= 1'b1;
        end

        if (FF_index_bef_cm == NUM_INPUTS_PER_PATH-1) begin
            begin_FF_output_bef_cm <= 1'b0;
            FF_index_bef_cm <= 5'bX;
            enable_FF_saving_bef_cm <= 1'b0;
        end
    end
end

endmodule