set proj_path [file normalize [file join [pwd] "final_project_v2.xpr"]]
set root_dir [file normalize [pwd]]
set bd_file [file join $root_dir "final_project_v2.srcs" "sources_1" "bd" "design_1" "design_1.bd"]
set bd_src_root [file dirname $bd_file]
set bd_gen_root [file join $root_dir "final_project_v2.gen" "sources_1" "bd" "design_1"]
set bd_ip_user_root [file join $root_dir "final_project_v2.ip_user_files" "bd" "design_1"]
set xdc_file [file join $root_dir "constraints" "zybo_audio_eth.xdc"]

source [file join $root_dir "scripts" "package_custom_ips.tcl"]

open_project $proj_path
set_property target_language VHDL [current_project]

foreach stale [list \
    [file join $root_dir "rtl" "piano_note_tables.svh"] \
    [file join $root_dir "rtl" "zybo_audio_in.sv"] \
    [file join $root_dir "rtl" "piano_note_detect.sv"] \
    [file join $root_dir "final_project_v2.gen" "sources_1" "bd" "design_1" "hdl" "design_1_wrapper.v"] \
    [file join $root_dir "final_project_v2.gen" "sources_1" "bd" "design_1" "hdl" "design_1_wrapper.vhd"]] {
    if {[llength [get_files -quiet $stale]] != 0} {
        remove_files [get_files $stale]
    }
}

foreach src [list \
    [file join $root_dir "rtl" "piano_note_tables_pkg.vhd"] \
    [file join $root_dir "rtl" "zybo_audio_in.vhd"] \
    [file join $root_dir "rtl" "piano_note_detect.vhd"]] {
    if {[llength [get_files -quiet $src]] == 0} {
        add_files -norecurse -fileset sources_1 $src
    }
}

if {[llength [get_files -quiet $xdc_file]] == 0} {
    add_files -norecurse -fileset constrs_1 $xdc_file
}

set_property ip_repo_paths [list [file join $root_dir "ip_repo"]] [current_project]
update_ip_catalog

update_compile_order -fileset sources_1

if {[llength [get_files -quiet $bd_file]] != 0} {
    remove_files [get_files $bd_file]
}
if {[file exists $bd_file]} {
    file delete -force $bd_file
}
foreach stale_dir [list \
    [file join $bd_src_root "ip"] \
    $bd_gen_root \
    $bd_ip_user_root] {
    if {[file exists $stale_dir]} {
        file delete -force $stale_dir
    }
}

create_bd_design "design_1"
current_bd_design design_1

create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
    -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable"} \
    [get_bd_cells processing_system7_0]
set_property -dict [list \
    CONFIG.PCW_USE_S_AXI_GP0 {1} \
    CONFIG.PCW_EN_CLK0_PORT {1} \
    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_IRQ_F2P_INTR {1} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {0.000} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {0.000} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {0.000} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {0.000}] [get_bd_cells processing_system7_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0
create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0
set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {3}] [get_bd_cells smartconnect_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.1 axi_iic_0
set_property -dict [list CONFIG.C_GPO_WIDTH {1}] [get_bd_cells axi_iic_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0
set_property -dict [list \
    CONFIG.PRIM_IN_FREQ {100.000} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {12.288} \
    CONFIG.RESET_TYPE {ACTIVE_LOW} \
    CONFIG.USE_LOCKED {false} \
    CONFIG.USE_RESET {false}] [get_bd_cells clk_wiz_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0
set_property -dict [list CONFIG.CONST_VAL {1} CONFIG.CONST_WIDTH {1}] [get_bd_cells xlconstant_0]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1
set_property -dict [list CONFIG.CONST_VAL {1} CONFIG.CONST_WIDTH {1}] [get_bd_cells xlconstant_1]

create_bd_cell -type ip -vlnv user.org:user:zybo_audio_in:1.0 zybo_audio_in_0
create_bd_cell -type ip -vlnv user.org:user:piano_note_detect:1.0 piano_note_detect_0

connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] \
    [get_bd_pins proc_sys_reset_0/slowest_sync_clk] \
    [get_bd_pins smartconnect_0/aclk] \
    [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] \
    [get_bd_pins processing_system7_0/S_AXI_GP0_ACLK] \
    [get_bd_pins axi_iic_0/s_axi_aclk] \
    [get_bd_pins zybo_audio_in_0/aclk] \
    [get_bd_pins piano_note_detect_0/aclk] \
    [get_bd_pins clk_wiz_0/clk_in1]

connect_bd_net [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins proc_sys_reset_0/ext_reset_in]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] \
    [get_bd_pins smartconnect_0/aresetn] \
    [get_bd_pins axi_iic_0/s_axi_aresetn] \
    [get_bd_pins zybo_audio_in_0/aresetn] \
    [get_bd_pins piano_note_detect_0/aresetn]

connect_bd_intf_net [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins smartconnect_0/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins piano_note_detect_0/S_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins zybo_audio_in_0/S_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M02_AXI] [get_bd_intf_pins axi_iic_0/S_AXI]
connect_bd_intf_net [get_bd_intf_pins zybo_audio_in_0/M_AXIS_AUDIO] [get_bd_intf_pins piano_note_detect_0/S_AXIS_AUDIO]

make_bd_intf_pins_external [get_bd_intf_pins axi_iic_0/IIC]
set_property name ac_iic [get_bd_intf_ports IIC_0]

create_bd_port -dir I ac_bclk
create_bd_port -dir I ac_reclrc
create_bd_port -dir I ac_recdat
create_bd_port -dir I ac_pblrc
create_bd_port -dir O ac_pbdat
create_bd_port -dir O ac_muten
create_bd_port -dir O ac_mclk
create_bd_port -dir O eth_rst_b
create_bd_port -dir O eth_int_pu_b

connect_bd_net [get_bd_ports ac_bclk]   [get_bd_pins zybo_audio_in_0/ac_bclk]
connect_bd_net [get_bd_ports ac_reclrc] [get_bd_pins zybo_audio_in_0/ac_reclrc]
connect_bd_net [get_bd_ports ac_recdat] [get_bd_pins zybo_audio_in_0/ac_recdat]
connect_bd_net [get_bd_ports ac_pblrc]  [get_bd_pins zybo_audio_in_0/ac_pblrc]
connect_bd_net [get_bd_ports ac_pbdat]  [get_bd_pins zybo_audio_in_0/ac_pbdat]
connect_bd_net [get_bd_ports ac_muten]  [get_bd_pins zybo_audio_in_0/ac_muten]
connect_bd_net [get_bd_ports ac_mclk]   [get_bd_pins clk_wiz_0/clk_out1]
connect_bd_net [get_bd_ports eth_rst_b] [get_bd_pins xlconstant_0/dout]
connect_bd_net [get_bd_ports eth_int_pu_b] [get_bd_pins xlconstant_1/dout]

assign_bd_address

regenerate_bd_layout
validate_bd_design
save_bd_design
reset_target all [get_files $bd_file]
generate_target all [get_files $bd_file]
export_ip_user_files -of_objects [get_files $bd_file] -no_script -sync -force -quiet

# Vivado may version the generated clk_wiz instance directory with either
# `design_1_clk_wiz_0_0` or `design_1_clk_wiz_0_0_1`. Patch and disable every
# matching input-clock XDC so the PS7 FCLK remains the only primary source clock.
set clk_wiz_xdcs [glob -nocomplain \
    [file join $root_dir "final_project_v2.gen" "sources_1" "bd" "design_1" "ip" "design_1_clk_wiz_0_0*" "design_1_clk_wiz_0_0.xdc"]]
foreach clk_wiz_xdc $clk_wiz_xdcs {
    if {[file exists $clk_wiz_xdc]} {
        set fp [open $clk_wiz_xdc r]
        set clk_wiz_xdc_text [read $fp]
        close $fp

        set clk_wiz_xdc_text [string map [list \
            {create_clock -period 10.000 [get_ports clk_in1]} {# create_clock disabled: PS7 clk_fpga_0 already defines this clock tree} \
            {set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.100} {# set_input_jitter disabled with duplicate input clock} \
        ] $clk_wiz_xdc_text]

        set fp [open $clk_wiz_xdc w]
        puts -nonewline $fp $clk_wiz_xdc_text
        close $fp
    }

    # The PS7 FCLK already defines the upstream primary clock. Disabling the
    # generated clk_wiz input-clock XDC avoids an invalid clock redefinition on
    # the internal clk_in1 pin during full-design timing analysis.
    if {[llength [get_files -quiet $clk_wiz_xdc]] != 0} {
        set_property is_enabled false [get_files $clk_wiz_xdc]
    }
}
make_wrapper -files [get_files $bd_file] -top
add_files -norecurse [file join $root_dir "final_project_v2.gen" "sources_1" "bd" "design_1" "hdl" "design_1_wrapper.vhd"]
update_compile_order -fileset sources_1
close_project
