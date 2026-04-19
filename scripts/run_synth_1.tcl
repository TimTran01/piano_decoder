set root_dir [file normalize [pwd]]
set proj_path [file join $root_dir "final_project_v2.xpr"]

open_project $proj_path

set synth_run [get_runs -quiet synth_1]
if {[llength $synth_run] == 0} {
    puts "ERROR: synth_1 run not found"
    close_project
    exit 1
}

reset_run $synth_run
launch_runs $synth_run -jobs 4
wait_on_run $synth_run

open_run $synth_run -name synth_1
report_messages -severity ERROR
report_messages -severity WARNING
close_project
