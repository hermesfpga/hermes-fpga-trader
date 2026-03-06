set TCLPATH [file dirname [info script]]
puts $TCLPATH
source $TCLPATH/build_utils.tcl
source $TCLPATH/setup_project.tcl

# Launch synthesis on top level
reset_run synth_1
launch_runs synth_1 -jobs 20
wait_on_run synth_1

# Launch implementation on top level
reset_run impl_1
set_property strategy Performance_Explore [get_runs impl_1]
launch_runs impl_1 -to_step write_bitstream -jobs 10
wait_on_run impl_1

# One-line report + checks
report_impl_results impl_1

write_hw_platform -fixed -force -include_bit -file ../$project_name.xsa
file copy -force $project_name.runs/impl_1/$project_name.bit ../$project_name.bit