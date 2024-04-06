reset_design

# What target library are we using?
# Looking into .synopsys_dc.setup file, look at the arguments of set target_library. That is our target library.

## Determine the time unit of our target library
# 1. First, read in our .v file using read_file -format verilog {PATH_TO_VERILOG_FILE}
# 2. Next, run report_lib TARGET_LIBRARY_NAME. In our case, is report_lib saed32rvt_tt1p05v125c
# 3. Above command gives time unit as 1ns

## Determine the load_value units of our target library, using report_lib command same as above
# We will find that Capacitive Load Unit is 1fF

## CONSTRAINT: Clock Period = 10ns
create_clock -period 10 [get_ports CLK]

## CONSTRAINT: Clock Uncertainty = 0.1ns
set_clock_uncertainty -setup 0.1 [get_clocks CLK]

## CONSTRAINT: Input Transition (all Inputs excluding CLK) = 0.1ns
set all_inputs_except_CLK [remove_from_collection [all_inputs] [get_ports CLK]]
set_input_transition 0.1 $all_inputs_except_CLK

## CONSTRAINT: Input Delay (all Inputs excluding CLK and ARSTN) = 0.2ns
set all_inputs_except_CLK_and_ARSTN [remove_from_collection [all_inputs] [get_ports {CLK ARSTN}]]
set_input_delay 0.2 -clock CLK $all_inputs_except_CLK_and_ARSTN

## CONSTRAINT: Output Delay (all Outputs) = 0.2ns
set_output_delay 0.2 -clock CLK [all_outputs]

## CONSTRAINT: Load Capacitance (all outputs) = 5fF;
set_load 5 [all_outputs]

## CONSTRAINT: Driving Gates = Inverter gates with 4x strength
# if -pin not specified, it uses first output pin it finds.
# Not sure how to check pins of target library's cells
set_driving_cell -lib_cell INVX4_RVT [all_inputs]

## CONSTRAINT: Maximum Area = 0 (Yes this is not a typo)
set_max_area 0