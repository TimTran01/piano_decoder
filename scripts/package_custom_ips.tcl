proc package_local_ip {root_dir ip_name top_module src_list} {
    set ip_root [file join $root_dir "ip_repo" $ip_name]
    file mkdir $ip_root

    create_project -force ${ip_name}_pkg $ip_root -part xc7z010clg400-1
    foreach src $src_list {
        add_files -norecurse $src
    }
    update_compile_order -fileset sources_1
    set_property top $top_module [current_fileset]

    ipx::package_project -root_dir $ip_root -vendor user.org -library user -taxonomy /UserIP -import_files
    set core [ipx::current_core]
    set_property name $ip_name $core
    set_property version 1.0 $core
    set_property display_name $ip_name $core
    set_property description "Packaged local IP for Zybo piano detector project" $core
    ipx::save_core $core
    close_project
}

set root_dir [file normalize [pwd]]
package_local_ip $root_dir "zybo_audio_in" "zybo_audio_in" [list \
    [file join $root_dir "rtl" "zybo_audio_in.vhd"]]
package_local_ip $root_dir "piano_note_detect" "piano_note_detect" [list \
    [file join $root_dir "rtl" "piano_note_tables_pkg.vhd"] \
    [file join $root_dir "rtl" "piano_note_detect.vhd"]]
