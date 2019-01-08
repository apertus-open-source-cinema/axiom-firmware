# vivado.tcl
#	MicroZed simple build script
#	Version 1.0
# 
# Copyright (C) 2015 H.Poetzl

set ODIR .
set_param messaging.defaultLimit 10000
set_param place.sliceLegEffortLimit 2000


# STEP#1: setup design sources and constraints

read_vhdl -vhdl2008 ../addr_gen.vhd
read_vhdl -vhdl2008 ../addr_dbuf.vhd
read_vhdl -vhdl2008 ../addr_qbuf.vhd
read_vhdl -vhdl2008 ../async_div.vhd
read_vhdl -vhdl2008 ../axihp_reader.vhd
read_vhdl -vhdl2008 ../axihp_writer.vhd
read_vhdl -vhdl2008 ../axi_lite.vhd
read_vhdl -vhdl2008 ../axi_split.vhd
read_vhdl -vhdl2008 ../axi_split4.vhd
read_vhdl -vhdl2008 ../axi_split8.vhd
read_vhdl -vhdl2008 ../bram_lut.vhd
read_vhdl -vhdl2008 ../cfg_lut5.vhd
read_vhdl -vhdl2008 ../cmv_pll.vhd
read_vhdl -vhdl2008 ../cmv_serdes.vhd
read_vhdl -vhdl2008 ../cmv_spi.vhd
read_vhdl -vhdl2008 ../color_matrix.vhd
read_vhdl -vhdl2008 ../data_filter.vhd
read_vhdl -vhdl2008 ../data_sync.vhd
read_vhdl -vhdl2008 ../dsp48_wrap.vhd
read_vhdl -vhdl2008 ../enc_ctrl.vhd
read_vhdl -vhdl2008 ../enc_tmds.vhd
read_vhdl -vhdl2008 ../enc_terc.vhd
read_vhdl -vhdl2008 ../fifo_chop.vhd
read_vhdl -vhdl2008 ../fifo_reset.vhd
read_vhdl -vhdl2008 ../hdmi_pll.vhd
read_vhdl -vhdl2008 ../lvds_pll.vhd
read_vhdl -vhdl2008 ../overlay.vhd
read_vhdl -vhdl2008 ../par_match.vhd
read_vhdl -vhdl2008 ../pixel_remap.vhd
read_vhdl -vhdl2008 ../pp_reg_sync.vhd
read_vhdl -vhdl2008 ../pp_sync.vhd
read_vhdl -vhdl2008 ../ps7_stub.vhd
read_vhdl -vhdl2008 ../pulse_sync.vhd
read_vhdl -vhdl2008 ../ram_sdp_reg.vhd
read_vhdl -vhdl2008 ../reg_lut.vhd
read_vhdl -vhdl2008 ../reg_delay.vhd
read_vhdl -vhdl2008 ../reg_file.vhd
read_vhdl -vhdl2008 ../reg_mem.vhd
read_vhdl -vhdl2008 ../reg_pll.vhd
read_vhdl -vhdl2008 ../reg_spi.vhd
read_vhdl -vhdl2008 ../remap_4x4.vhd
read_vhdl -vhdl2008 ../remap_shuffle.vhd
read_vhdl -vhdl2008 ../reset_sync.vhd
read_vhdl -vhdl2008 ../rgb_dvid.vhd
read_vhdl -vhdl2008 ../rgb_hdmi.vhd
read_vhdl -vhdl2008 ../row_col_noise.vhd
read_vhdl -vhdl2008 ../scan_comp.vhd
read_vhdl -vhdl2008 ../scan_hdmi.vhd
read_vhdl -vhdl2008 ../scan_event.vhd
read_vhdl -vhdl2008 ../scan_pong.vhd
read_vhdl -vhdl2008 ../ser_to_par.vhd
read_vhdl -vhdl2008 ../serdes_wrap.vhd
read_vhdl -vhdl2008 ../sync_delay.vhd
read_vhdl -vhdl2008 ../sync_div.vhd

read_vhdl -vhdl2008 ../axi3_lite_pkg.vhd
read_vhdl -vhdl2008 ../axi3_pkg.vhd
read_vhdl -vhdl2008 ../fifo_pkg.vhd
read_vhdl -vhdl2008 ../helper_pkg.vhd
read_vhdl -vhdl2008 ../reduce_pkg.vhd
read_vhdl -vhdl2008 ../vivado_pkg.vhd
# read_vhdl -vhdl2008 ../minmax.vhd
read_vhdl -vhdl2008 ../top.vhd

# read_xdc ../pmod_debug.xdc
# read_xdc ../pmod_logic.xdc
# read_xdc ../hdmi.xdc
read_xdc ../top.xdc
read_xdc ../pin_hdmi_north.xdc
read_xdc ../pin_hdmi_south.xdc
read_xdc ../pin_i2c.xdc
read_xdc ../pin_spi.xdc
read_xdc ../pin_cmv.xdc
read_xdc ../pin_debug.xdc

# set_property vhdl_version vhdl_2008 [current_fileset]

set_property PART xc7z020clg400-1 [current_project]
set_property BOARD_PART em.avnet.com:microzed_7020:part0:1.0 [current_project]
set_property TARGET_LANGUAGE VHDL [current_project]


# STEP#1.1: setup IP cores

# create_ip -vlnv xilinx.com:ip:axi_protocol_checker:1.1 -module_name checker
# set_property CONFIG.PROTOCOL {AXI3} [get_ips checker]
# set_property CONFIG.READ_WRITE_MODE {READ_WRITE} [get_ips checker]
# set_property CONFIG.DATA_WIDTH {32} [get_ips checker]
# set_property CONFIG.MAX_RD_BURSTS {4} [get_ips checker]
# set_property CONFIG.MAX_WR_BURSTS {4} [get_ips checker]
# set_property CONFIG.HAS_SYSTEM_RESET {1} [get_ips checker]


# report_property -all [get_ips checker]
# set_property GENERATE_SYNTH_CHECKPOINT false \
# 	[get_files [get_property IP_FILE [get_ips checker]]]
# generate_target {synthesis} [get_ips checker]

# STEP#2: run synthesis, write checkpoint design

#synth_design -top top -flatten rebuilt -directive RuntimeOptimized
synth_design -top top -flatten rebuilt
write_checkpoint -force $ODIR/post_synth
# write_verilog -force -quiet -mode timesim -sdf_anno true post_synth.v
# write_sdf -force -quiet post_synth.sdf

set_operating_conditions -ambient_temp 25
set_operating_conditions -board_temp 45
set_operating_conditions -board_layers 8to11
set_operating_conditions -airflow 100
set_operating_conditions -heatsink medium

# STEP#3: run placement and logic optimzation, write checkpoint design

# opt_design -resynth_area
# opt_design -resynth_seq_area -propconst -sweep -retarget -remap

opt_design -propconst -sweep -retarget -remap
# opt_design -directive RuntimeOptimized
# power_opt_design

write_checkpoint -force $ODIR/post_opt
# write_verilog -force -quiet -mode timesim -sdf_anno true post_opt.v
# write_sdf -force -quiet post_opt.sdf

if { [file exists $ODIR/post_route.dcp] == 1 } {
    read_checkpoint -incremental $ODIR/post_route.dcp
}

# place_design -directive Quick
# place_design -directive RuntimeOptimized
place_design -directive Explore
# place_design -directive ExtraNetDelay_high
# place_design -directive SpreadLogic_high

# phys_opt_design -placement_opt -critical_pin_opt -hold_fix -rewire -retime
phys_opt_design -critical_cell_opt -critical_pin_opt -placement_opt -hold_fix -rewire -retime
power_opt_design
write_checkpoint -force $ODIR/post_place
# write_verilog -force -quiet -mode timesim -sdf_anno true post_place.v
# write_sdf -force -quiet post_place.sdf

# STEP#4: run router, write checkpoint design

# route_design
# route_design -directive Quick
route_design -directive Explore
# route_design -directive RuntimeOptimized
# route_design -directive NoTimingRelaxation -free_resource_mode
# route_design -directive HigherDelayCost
# route_design -directive HigherDelayCost -free_resource_mode
# route_design -directive AdvancedSkewModeling
write_checkpoint -force $ODIR/post_route
# write_verilog -force -quiet -mode timesim -sdf_anno true post_route.v
# write_sdf -force -quiet post_route.sdf

#
# STEP#4b: rerun router
# place_design -directive ExtraNetDelay_high
# place_design -directive ExtraPostPlacementOpt
# place_design -post_place_opt
# phys_opt_design -directive ExploreWithHoldFix
# route_design -directive HigherDelayCost
# route_design -directive NoTimingRelaxation -free_resource_mode
# route_design -directive AdvancedSkewModeling -free_resource_mode
# route_design -directive MoreGlobalIterations -free_resource_mode



# STEP#5: generate a bitstream

set_property BITSTREAM.GENERAL.COMPRESS True [current_design]
set_property BITSTREAM.CONFIG.USERID "DEADC0DE" [current_design]
set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]
set_property BITSTREAM.READBACK.ACTIVERECONFIG Yes [current_design]

# write_bitstream -force -bin_file $ODIR/cmv_io.bit
write_bitstream -force $ODIR/cmv_hdmi3.bit


# STEP#6: generate reports

report_clocks

report_utilization -hierarchical -file utilization.rpt
report_clock_utilization -file utilization.rpt -append
report_datasheet -file datasheet.rpt
report_timing_summary -file timing.rpt

report_operating_conditions -file conditions.rpt
report_power -file power.rpt

report_timing -no_header -path_type summary -max_paths 1000 -slack_lesser_than 0 -setup
report_timing -no_header -path_type summary -max_paths 1000 -slack_lesser_than 0 -hold

# highlight_objects -rgb {128 128 128} [get_cells]
# highlight_objects -rgb {64 64 64} [get_nets]

# highlight_objects -rgb {128 0 255}	[get_cells reg_delay_inst/*]
# highlight_objects -rgb {255 0 0}	[get_cells ser_to_par_inst/*]
# highlight_objects -rgb {255 64 0}	[get_cells par_match_inst/*]
# highlight_objects -rgb {255 128 0}	[get_cells fifo_chop_inst/*]

# source ../vivado_program.tcl
# start_gui
