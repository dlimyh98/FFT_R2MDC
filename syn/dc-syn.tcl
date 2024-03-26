remove_design -all

set design_name ifft64_radix2_top

analyze -library WORK -format verilog  ../src/ifft64_radix2_top.v
analyze -library WORK -format verilog  ../src/ifft64_radix2.v
analyze -library WORK -format verilog  ../src/ifft_ctrl.v
analyze -library WORK -format verilog  ../src/bf_radix2.v
analyze -library WORK -format verilog  ../src/bf_radix2_noW.v
analyze -library WORK -format verilog  ../src/commutator_radix2.v
##add more if needed



elaborate $design_name

source ./constraint.tcl

set_fix_multiple_port_nets -all -exclude_clock_network -buffer_constants [get_designs *]

link

compile

remove_unconnected_ports -blast_buses [get_cells "*" -hier]

change_name -hierarchy -rules verilog

write -format verilog -hierarchy -output ./output/$design_name.v
write_sdf                                ./output/$design_name.sdf
write_sdc                                ./output/$design_name.sdc
write -hierarchy -output                 ./output/$design_name.ddc

check_design >                           ./report/check_$design_name.rpt
report_qor >                             ./report/qor_$design_name.rpt
report_timing >                          ./report/timing_$design_name.rpt
report_area >                            ./report/area_$design_name.rpt

exit


