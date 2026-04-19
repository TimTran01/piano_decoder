# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_S_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FRAME_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "HOP_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "STABLE_FRAMES" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.FRAME_SIZE { PARAM_VALUE.FRAME_SIZE } {
	# Procedure called to update FRAME_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FRAME_SIZE { PARAM_VALUE.FRAME_SIZE } {
	# Procedure called to validate FRAME_SIZE
	return true
}

proc update_PARAM_VALUE.HOP_SIZE { PARAM_VALUE.HOP_SIZE } {
	# Procedure called to update HOP_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HOP_SIZE { PARAM_VALUE.HOP_SIZE } {
	# Procedure called to validate HOP_SIZE
	return true
}

proc update_PARAM_VALUE.STABLE_FRAMES { PARAM_VALUE.STABLE_FRAMES } {
	# Procedure called to update STABLE_FRAMES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.STABLE_FRAMES { PARAM_VALUE.STABLE_FRAMES } {
	# Procedure called to validate STABLE_FRAMES
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.FRAME_SIZE { MODELPARAM_VALUE.FRAME_SIZE PARAM_VALUE.FRAME_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FRAME_SIZE}] ${MODELPARAM_VALUE.FRAME_SIZE}
}

proc update_MODELPARAM_VALUE.HOP_SIZE { MODELPARAM_VALUE.HOP_SIZE PARAM_VALUE.HOP_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HOP_SIZE}] ${MODELPARAM_VALUE.HOP_SIZE}
}

proc update_MODELPARAM_VALUE.STABLE_FRAMES { MODELPARAM_VALUE.STABLE_FRAMES PARAM_VALUE.STABLE_FRAMES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.STABLE_FRAMES}] ${MODELPARAM_VALUE.STABLE_FRAMES}
}

