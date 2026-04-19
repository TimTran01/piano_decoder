set root_dir [file normalize [pwd]]
set proj_path [file join $root_dir "final_project_v2.xpr"]

open_project $proj_path

set detector_run [get_runs -quiet design_1_piano_note_detect_0_0_synth_1]
if {[llength $detector_run] == 0} {
    puts "INFO: detector OOC run not found, refreshing generated targets first"
    update_compile_order -fileset sources_1
    set bd_file [file join $root_dir "final_project_v2.srcs" "sources_1" "bd" "design_1" "design_1.bd"]
    if {[llength [get_files -quiet $bd_file]] != 0} {
        generate_target all [get_files $bd_file]
        export_ip_user_files -of_objects [get_files $bd_file] -no_script -sync -force -quiet
    }
    set detector_run [get_runs -quiet design_1_piano_note_detect_0_0_synth_1]
}

if {[llength $detector_run] == 0} {
    puts "ERROR: detector OOC run still not found after refresh"
    puts "INFO: available runs: [get_runs]"
    close_project
    exit 1
}

reset_run $detector_run
launch_runs $detector_run -jobs 4
wait_on_run $detector_run

open_run $detector_run -name synth_1
report_messages -severity ERROR
report_messages -severity WARNING
close_project
