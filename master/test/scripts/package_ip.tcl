# set variable names
set design_name "package_ip"
set def_ip_dir "../def_ip"
set project_dir "runs"
set hdl_dir "../hdl"
set scripts_dir "../scripts"

# set up project
create_project $design_name ../$project_dir -part xc7z100ffg900-2

# add hdl sources and xdc constraints to project
add_files -norecurse $hdl_dir/n_x_serdes_1_to_7_mmcm_idelay_sdr.v
add_files -norecurse $hdl_dir/delay_controller_wrap.v
add_files -norecurse $hdl_dir/serdes_7_to_1_diff_sdr.v
add_files -norecurse $hdl_dir/gearbox_4_to_7.v
add_files -norecurse $hdl_dir/n_x_serdes_7_to_1_diff_sdr.v
add_files -norecurse $hdl_dir/gearbox_4_to_7_slave.v
add_files -norecurse $hdl_dir/clock_generator_pll_7_to_1_diff_sdr.v
add_files -norecurse $hdl_dir/serdes_1_to_7_mmcm_idelay_sdr.v
add_files -norecurse $hdl_dir/lvds_n_x_1to7_sdr_rx.v
add_files -norecurse $hdl_dir/serdes_1_to_7_slave_idelay_sdr.v

update_compile_order -fileset sources_1
update_compile_order -fileset sources_1

set_property top lvds_n_x_1to7_sdr_rx [current_fileset]
update_compile_order -fileset sources_1
ipx::package_project -root_dir $def_ip_dir -vendor xilinx.com -library user -taxonomy /UserIP -import_files -set_current false
ipx::unload_core $def_ip_dir/component.xml
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory $def_ip_dir $def_ip_dir/component.xml
update_compile_order -fileset sources_1
set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete
set_property  ip_repo_paths  $def_ip_dir [current_project]
update_ip_catalog