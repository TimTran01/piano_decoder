set root_dir [file normalize [pwd]]
set proj_path [file join $root_dir "final_project_v2.xpr"]

open_project $proj_path

set impl_run [get_runs -quiet impl_1]
if {[llength $impl_run] == 0} {
    puts "ERROR: impl_1 run not found"
    close_project
    exit 1
}

reset_run synth_1
reset_run $impl_run
launch_runs $impl_run -to_step route_design -jobs 4
wait_on_run $impl_run

open_run $impl_run -name impl_1
report_timing_summary -delay_type max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -file [file join $root_dir "final_project_v2.runs" "impl_1" "design_1_wrapper_timing_summary_post_fix.rpt"]
close_project
