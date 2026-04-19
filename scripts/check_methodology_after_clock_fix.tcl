set root_dir [file normalize [pwd]]
set dcp_path [file join $root_dir "final_project_v2.runs" "impl_1" "design_1_wrapper_routed.dcp"]
set rpt_path [file join $root_dir "final_project_v2.runs" "impl_1" "design_1_wrapper_methodology_after_clock_fix.rpt"]

open_checkpoint $dcp_path

set duplicate_clk [get_clocks -quiet "design_1_i/clk_wiz_0/inst/clk_in1"]
if {[llength $duplicate_clk] != 0} {
    delete_clocks $duplicate_clk
}

report_methodology -file $rpt_path
close_design
