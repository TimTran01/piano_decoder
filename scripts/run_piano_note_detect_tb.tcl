set script_dir [file dirname [file normalize [info script]]]
set root_dir [file normalize [file join $script_dir ".."]]
set build_dir [file join $root_dir ".xsim" "piano_note_detect_tb"]

file mkdir $build_dir
cd $build_dir

exec xvhdl --2008 \
    [file join $root_dir "rtl" "piano_note_tables_pkg.vhd"] \
    [file join $root_dir "rtl" "piano_note_detect.vhd"] \
    [file join $root_dir "sim" "piano_note_detect_tb.vhd"]

exec xelab --debug typical piano_note_detect_tb -s piano_note_detect_tb
exec xsim piano_note_detect_tb -R -onfinish quit

set log_path [file join $build_dir "xsim.log"]
set log_fp [open $log_path r]
set log_text [read $log_fp]
close $log_fp

if {[string first "Failure:" $log_text] >= 0} {
    error "piano_note_detect_tb failed; see $log_path"
}
