// Input ports
// clk             -clock signal
// arstn           -reset the system (asynchronous reset, active low)
// start           -start IFFT calculation

// Output ports
// start_check     -to testbench, to be activated when the first effective result is generated at the output of the IFFT pipeline (active high)
// bank_addr       -to select test case (10 bits)
// twiddle_sel1    -control signal, to select twiddle factors for the 1st layer in the 64IFFT pipeline
// twiddle_sel2    -control signal, to select twiddle factors for the 2nd layer in the 64IFFT pipeline
// twiddle_sel3    -control signal, to select twiddle factors for the 3rd layer in the 64IFFT pipeline
// twiddle_sel4    -control signal, to select twiddle factors for the 4th layer in the 64IFFT pipeline
// twiddle_sel5    -control signal, to select twiddle factors for the 5th layer in the 64IFFT pipeline
// pattern2        -control signal, to contol the communator at the 2nd layer in the 64IFFT pipeline
// pattern3        -control signal, to contol the communator at the 3rd layer in the 64IFFT pipeline
// pattern4        -control signal, to contol the communator at the 4th layer in the 64IFFT pipeline
// pattern5        -control signal, to contol the communator at the 5th layer in the 64IFFT pipeline
// pattern6        -control signal, to contol the communator at the 6th layer in the 64IFFT pipeline
// cntr_IFFT_input_pairs -count 32 cycles for the IFFT Pipeline (before valid result shows up at ifft_out0 and ifft_out1)

module ifft_ctrl
    (
        input CLK,
        input ARSTN,
        input Start,
        output reg Start_Check = 1'b0,
        output reg [9:0] bank_addr = 10'b0,
        output reg [4:0] twiddle_sel1 = 5'b0,
        output reg [4:0] twiddle_sel2 = 5'b0,
        output reg [4:0] twiddle_sel3 = 5'b0,
        output reg [4:0] twiddle_sel4 = 5'b0,
        output reg [4:0] twiddle_sel5 = 5'b0,
        output reg pattern2 = 1'b0,
        output reg pattern3 = 1'b0,
        output reg pattern4 = 1'b0,
        output reg pattern5 = 1'b0,
        output reg pattern6 = 1'b0,
        output reg [4:0] cntr_IFFT_input_pairs = 5'b0
    );
    
    localparam LAST_TEST_CASE = 10'd1000;
    localparam IFFT_PIPELINE_LATENCY = 5'd31;

    // State definitions
    localparam IDLE = 3'd0;
    localparam FFT_PIPELINE = 3'd1;
    localparam VERIFICATION = 3'd2;
    localparam DONE = 3'd3;
    localparam RESET = 3'd4;

    reg [2:0] current_State = IDLE;
    reg [2:0] next_State = IDLE;
    reg [9:0] cnt_testcases = 10'd0;

    // We can use cntr_IFFT_input_pairs as twiddle_layer1_cntr
    localparam LAYER_TWO_OVERFLOW = 15;
    localparam LAYER_THREE_OVERFLOW = 7;
    localparam LAYER_FOUR_OVERFLOW = 3;
    localparam LAYER_FIVE_OVERFLOW = 1;
    reg [3:0] twiddle_layer2_cntr = 4'b0;   // Period is [0,2,4,...,30]. 16 different values
    reg [2:0] twiddle_layer3_cntr = 3'b0;   // Period is [0,4,8,...,28]. 8 different values
    reg [1:0] twiddle_layer4_cntr = 2'b0;   // Period is [0,8,16,24]. 4 different values
    reg twiddle_layer5_cntr = 1'b0;         // Period is [0,16]. 2 different values

    // Code FSM in similar fashion to Two-Always Block FSM Style (But not quite. eg. cntr_IFFT_input_pairs is output, but we do it sequentially)
    // - One for SEQUENTIAL state register
    // - One for COMBINATIONAL next state generation & COMBINATIONAL output logic generation
    // https://course.cutm.ac.in/wp-content/uploads/2020/06/Lec-4.pdf
    // https://courses.cs.washington.edu/courses/cse370/99sp/sections/may18/slides/sld002.htm

    /************************************ SEQUENTIAL STATE LOGIC ************************************/
    // TODO: bank_addr, 10-bit counter (sequential logic, reset with arstn) to select test case
    always @ (posedge CLK or negedge ARSTN) begin
        if (!ARSTN) begin
            current_State <= RESET;

            // Reset all synchronous internal signals
            twiddle_layer2_cntr <= 0;
            twiddle_layer3_cntr <= 0;
            twiddle_layer4_cntr <= 0;
            twiddle_layer5_cntr <= 0;

            // Reset all synchronous output signals
            bank_addr <= 0;
            cntr_IFFT_input_pairs <= 0;
            pattern2 <= 0;
            pattern3 <= 0;
            pattern4 <= 0;
            pattern5 <= 0;
            pattern6 <= 0;

        end
        else begin
            current_State <= next_State;

            if (current_State == FFT_PIPELINE) begin
                // BFU1: (0,32),(1,33),(2,34),...,(31,63)
                // BFU2: (0,16),(1,17),...,(15,31) , (32,48),(33,49),...,(47,63)
                // commutator2: Active between clockCycles 16-31. Flips 16 pairs of inputs; (16,32),(17,33),(18,34),...,(31,47)
                // commutator3: Active between clockCycles 24-31. Flips 8 pairs of inputs;  (8,16),(9,17),(10,18),...,(15,23)

                // Basically, we want patternx to toggle between every overflow of it's corresponding twiddle_layerx_cntr
                // We know that overflow (for unsigned numbers) occurs when the sum is smaller than it's constituents
                // patternx is an output signal, but it is a SEQUENTIAL output signal
                // This is because patternx needs MEMORY of it's previous state (to toggle appropriately)
                // Check if overflow will occur in the next cycle. If it will, then toggle the patternx signal on the next clockCycle.
                pattern2 <= (twiddle_layer2_cntr == LAYER_TWO_OVERFLOW) ? (pattern2 ^ 1) : (pattern2);
                pattern3 <= (twiddle_layer3_cntr == LAYER_THREE_OVERFLOW ) ? (pattern3 ^ 1) : (pattern3);
                pattern4 <= (twiddle_layer4_cntr == LAYER_FOUR_OVERFLOW) ? (pattern4 ^ 1) : (pattern4);
                pattern5 <= (twiddle_layer5_cntr == LAYER_FIVE_OVERFLOW) ? (pattern5 ^ 1) : (pattern5);
                pattern6 <= pattern6 ^ 1;

                cntr_IFFT_input_pairs <= cntr_IFFT_input_pairs + 1;
                twiddle_layer2_cntr <= twiddle_layer2_cntr + 1;
                twiddle_layer3_cntr <= twiddle_layer3_cntr + 1;
                twiddle_layer4_cntr <= twiddle_layer4_cntr + 1;
                twiddle_layer5_cntr <= twiddle_layer5_cntr + 1;
            end
        end
    end


    /************************************ COMBINATIONAL NEXT-STATE GENERATION ************************************/
    always @ (current_State, Start, cntr_IFFT_input_pairs, cnt_testcases) begin
        next_State = 2'bx;
        
        case (current_State)
            RESET: begin
                next_State = IDLE;
            end

            IDLE: begin
                if (Start) next_State = FFT_PIPELINE;
                else next_State = IDLE;
            end

            FFT_PIPELINE: begin
                if (cntr_IFFT_input_pairs == IFFT_PIPELINE_LATENCY-1) next_State = VERIFICATION;
                else next_State = FFT_PIPELINE;
            end

            VERIFICATION: begin
                if (cnt_testcases == LAST_TEST_CASE) next_State = DONE;
                else next_State = VERIFICATION;
            end

            DONE: begin
                next_State = DONE;
            end
        endcase
    end


    /************************************ COMBINATIONAL INTERNAL AND OUTPUT CONTROL SIGNALS (Twiddle and Communator) ************************************/
    always @ (*) begin
        cnt_testcases = 10'bx;
        Start_Check = 1'bx;
        twiddle_sel1 = 5'bx;
        twiddle_sel2 = 5'bx;
        twiddle_sel3 = 5'bx;
        twiddle_sel4 = 5'bx;
        twiddle_sel5 = 5'bx;

        case (current_State)
            RESET: begin
                // Reset combinational internal signals
                cnt_testcases = 0;

                // Reset combinational output signals
                Start_Check = 0;
                twiddle_sel1 = 0;
                twiddle_sel2 = 0;
                twiddle_sel3 = 0;
                twiddle_sel4 = 0;
                twiddle_sel5 = 0;
            end

            IDLE: begin
                cnt_testcases = 10'bx;
                Start_Check = 1'b0;

                twiddle_sel1 = 5'dx;
                twiddle_sel2 = 5'dx;
                twiddle_sel3 = 5'dx;
                twiddle_sel4 = 5'dx;
                twiddle_sel5 = 5'dx;
            end

            // Each BFU receives 32 paired inputs through it's input ports in0 and in1
            // LAYER 1: [(in0,in32), (in1,in33), ..., (in31,in63)]
            // LAYER 2: ["FIRST HALF" --> (in0,in16), (in1,in17), ... , (in15,in31), ... ,
            //           "SECOND HALF" -> (in32,in48), (in33,in49), ... , (in47,in63)]

            // We stay in this state for exactly 32 cycles (numCycles required for FIRST valid output of FIRST testCase to show up at ifft_out0 and ifft_out1)
            FFT_PIPELINE: begin
                // twiddle_sel1: Picks between W0(in0 & in32), W1(in1 & in33), ... , W31(in31 & in63)
                // twiddle_sel2: Picks between W0(in0 & in16, in32 & in48), W2(in1 & in17, in33 & in49), ... , W30(in15 & in31, in47 & in63)
                // twiddle_sel3: Picks between W0,W4,...,W28
                // twiddle_sel4: Picks between W0,W8,...,W24
                // twiddle_sel5: Picks between W0,W16
                // NOTE: The twiddle_layerx_cntr counters will OVERFLOW and reset back to 0. This is intended behaviour.
                twiddle_sel1 = cntr_IFFT_input_pairs;
                twiddle_sel2 = twiddle_layer2_cntr*2;
                twiddle_sel3 = twiddle_layer3_cntr*4;
                twiddle_sel4 = twiddle_layer4_cntr*8;
                twiddle_sel5 = twiddle_layer5_cntr*16;
            end

            /*
            VERIFICATION: begin
                Start_Check = 1'b1;

            end

            DONE: begin

            end
            */
        endcase
    end

endmodule