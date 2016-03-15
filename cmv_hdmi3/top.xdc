
# create_clock -period 10.000 -name clk_100 -waveform {0.000 5.000} [get_signals clk_100]

set_operating_conditions -airflow 0
set_operating_conditions -heatsink low

create_clock -period 10.000 -name clk_100 -waveform {0.000 5.000} [get_pins */PS7_inst/FCLKCLK[0]]
# create_clock -period 8.000 -name lvds_clk_125 -waveform {0.000 4.000} [get_port cmv_lvds_outclk_*]



set_false_path -from [get_cells -hierarchical reg_ba_reg*]
set_false_path -from [get_cells -hierarchical reg_ab_reg*]

set_false_path -from [get_cells -hierarchical ping_a_d_reg*]
set_false_path -from [get_cells -hierarchical pong_b_d_reg*]

set_false_path -from [get_pins fifo_reset_inst*/shift_*/C]

set_false_path -from [get_pins reg_file_inst*/oreg_*/C]
set_false_path -to [get_pins reg_file_inst*/rdata_*/D]

set_false_path -to [get_pins sync_*_inst*/shift_*/D]
# set_false_path -to [get_pins sync_*_inst/shift_*/PRE]

# set_multicycle_path 2 -from [get_pins phase_*/C] -to [get_pins shift_*/D]
# set_multicycle_path 1 -from [get_pins phase_*/C] -to [get_pins shift_*/D] -hold

# set_multicycle_path 2 -from [get_pins iserdes_push*/C] -to [get_pins FIFO_ser_inst/*/S]
# set_multicycle_path 1 -from [get_pins iserdes_push*/C] -to [get_pins FIFO_ser_inst/*/S] -hold

# set_multicycle_path 2 -from [get_pins iserdes_push*/C] -to [get_pins FIFO_ser_inst/*/D]
# set_multicycle_path 1 -from [get_pins iserdes_push*/C] -to [get_pins FIFO_ser_inst/*/D] -hold

# set_multicycle_path 2 -from [get_pins GEN_LVDS*/data_out*/C] -to [get_pins FIFO_ser_inst/*/D]
# set_multicycle_path 1 -from [get_pins GEN_LVDS*/data_out*/C] -to [get_pins FIFO_ser_inst/*/D] -hold

create_pblock pblock_reader
add_cells_to_pblock [get_pblocks pblock_reader] [get_cells axihp_reader_inst]
resize_pblock [get_pblocks pblock_reader] -add {SLICE_X26Y50:SLICE_X31Y59}
# resize_pblock [get_pblocks pblock_reader] -add {SLICE_X26Y40:SLICE_X31Y49}

create_pblock pblock_ragen
add_cells_to_pblock [get_pblocks pblock_ragen] [get_cells raddr_gen_inst]
add_cells_to_pblock [get_pblocks pblock_ragen] [get_cells sync_rblock_inst]
add_cells_to_pblock [get_pblocks pblock_ragen] [get_cells sync_rreset_inst]
add_cells_to_pblock [get_pblocks pblock_ragen] [get_cells sync_rload_inst]
add_cells_to_pblock [get_pblocks pblock_ragen] [get_cells sync_rswitch_inst*]
add_cells_to_pblock [get_pblocks pblock_ragen] [get_cells sync_rbuf*_inst]
resize_pblock [get_pblocks pblock_ragen] -add {SLICE_X32Y25:SLICE_X37Y49}
resize_pblock [get_pblocks pblock_ragen] -add {DSP48_X2Y14:DSP48_X2Y19}
#resize_pblock [get_pblocks pblock_ragen] -add {SLICE_X32Y40:SLICE_X37Y49}
#resize_pblock [get_pblocks pblock_ragen] -add {DSP48_X2Y16:DSP48_X2Y19}
# resize_pblock [get_pblocks pblock_ragen] -add {SLICE_X20Y35:SLICE_X23Y39}
# resize_pblock [get_pblocks pblock_ragen] -add {DSP48_X1Y14:DSP48_X1Y15}
# resize_pblock [get_pblocks pblock_ragen] -add {SLICE_X36Y25:SLICE_X39Y29}
# resize_pblock [get_pblocks pblock_ragen] -add {DSP48_X2Y10:DSP48_X2Y11}
# resize_pblock [get_pblocks pblock_ragen] -add {SLICE_X32Y35:SLICE_X35Y39}
# resize_pblock [get_pblocks pblock_ragen] -add {DSP48_X2Y14:DSP48_X2Y15}
# resize_pblock [get_pblocks pblock_ragen] -add {SLICE_X22Y40:SLICE_X25Y44}
# resize_pblock [get_pblocks pblock_ragen] -add {DSP48_X2Y20:DSP48_X2Y21}

create_pblock pblock_rfifo
add_cells_to_pblock [get_pblocks pblock_rfifo] [get_cells fifo_reset_inst1]
add_cells_to_pblock [get_pblocks pblock_rfifo] [get_cells FIFO_hdmi_inst]
# resize_pblock [get_pblocks pblock_rfifo] -add {SLICE_X36Y40:SLICE_X49Y49}
resize_pblock [get_pblocks pblock_rfifo] -add {SLICE_X26Y35:SLICE_X31Y44}
resize_pblock [get_pblocks pblock_rfifo] -add {RAMB18_X2Y14:RAMB18_X2Y17}
resize_pblock [get_pblocks pblock_rfifo] -add {RAMB36_X2Y7:RAMB36_X2Y8}
# resize_pblock [get_pblocks pblock_rfifo] -add {SLICE_X32Y30:SLICE_X35Y39}
# resize_pblock [get_pblocks pblock_rfifo] -add {RAMB18_X2Y12:RAMB18_X2Y15}
# resize_pblock [get_pblocks pblock_rfifo] -add {RAMB36_X2Y6:RAMB36_X2Y7}
# resize_pblock [get_pblocks pblock_rfifo] -add {SLICE_X54Y15:SLICE_X57Y24}
# resize_pblock [get_pblocks pblock_rfifo] -add {RAMB18_X3Y6:RAMB18_X3Y9}
# resize_pblock [get_pblocks pblock_rfifo] -add {RAMB36_X3Y3:RAMB36_X3Y4}
# resize_pblock [get_pblocks pblock_rfifo] -add {SLICE_X32Y40:SLICE_X35Y49}
# resize_pblock [get_pblocks pblock_rfifo] -add {RAMB18_X2Y16:RAMB18_X2Y19}
# resize_pblock [get_pblocks pblock_rfifo] -add {RAMB36_X2Y8:RAMB36_X2Y9}


create_pblock pblock_writer
add_cells_to_pblock [get_pblocks pblock_writer] [get_cells axihp_writer_inst]
resize_pblock [get_pblocks pblock_writer] -add {SLICE_X26Y65:SLICE_X31Y74}
#resize_pblock [get_pblocks pblock_writer] -add {SLICE_X26Y75:SLICE_X31Y84}
#resize_pblock [get_pblocks pblock_writer] -add {SLICE_X26Y65:SLICE_X31Y74}
# resize_pblock [get_pblocks pblock_writer] -add {SLICE_X26Y50:SLICE_X31Y59}

create_pblock pblock_wagen
add_cells_to_pblock [get_pblocks pblock_wagen] [get_cells waddr_gen_inst]
add_cells_to_pblock [get_pblocks pblock_wagen] [get_cells sync_wblock_inst]
add_cells_to_pblock [get_pblocks pblock_wagen] [get_cells sync_wreset_inst]
add_cells_to_pblock [get_pblocks pblock_wagen] [get_cells sync_wload_inst]
add_cells_to_pblock [get_pblocks pblock_wagen] [get_cells sync_wswitch_inst*]
add_cells_to_pblock [get_pblocks pblock_wagen] [get_cells sync_wbuf*_inst]
resize_pblock [get_pblocks pblock_wagen] -add {SLICE_X32Y60:SLICE_X37Y79}
resize_pblock [get_pblocks pblock_wagen] -add {DSP48_X2Y24:DSP48_X2Y27}
# resize_pblock [get_pblocks pblock_wagen] -add {SLICE_X22Y45:SLICE_X25Y49}
# resize_pblock [get_pblocks pblock_wagen] -add {DSP48_X2Y20:DSP48_X2Y21}

create_pblock pblock_wfifo
add_cells_to_pblock [get_pblocks pblock_wfifo] [get_cells fifo_reset_inst0]
add_cells_to_pblock [get_pblocks pblock_wfifo] [get_cells FIFO_data_inst]
resize_pblock [get_pblocks pblock_wfifo] -add {SLICE_X32Y70:SLICE_X43Y79}
resize_pblock [get_pblocks pblock_wfifo] -add {RAMB18_X2Y28:RAMB18_X2Y31}
resize_pblock [get_pblocks pblock_wfifo] -add {RAMB36_X2Y14:RAMB36_X2Y15}
#resize_pblock [get_pblocks pblock_wfifo] -add {SLICE_X38Y65:SLICE_X49Y74}
#resize_pblock [get_pblocks pblock_wfifo] -add {RAMB18_X2Y26:RAMB18_X2Y29}
#resize_pblock [get_pblocks pblock_wfifo] -add {RAMB36_X2Y13:RAMB36_X2Y14}

# create_pblock pblock_filter
# add_cells_to_pblock [get_pblocks pblock_filter] [get_cells data_filter_inst]
# resize_pblock [get_pblocks pblock_filter] -add {SLICE_X50Y95:SLICE_X53Y99}
# resize_pblock [get_pblocks pblock_filter] -add {SLICE_X32Y75:SLICE_X35Y79}

create_pblock pblock_rcn
add_cells_to_pblock [get_pblocks pblock_rcn] [get_cells rc_noise_inst]
# resize_pblock [get_pblocks pblock_rcn] -add {SLICE_X32Y95:SLICE_X37Y104}
# resize_pblock [get_pblocks pblock_rcn] -add {DSP48_X2Y38:DSP48_X2Y41}
resize_pblock [get_pblocks pblock_rcn] -add {SLICE_X32Y90:SLICE_X37Y99}
resize_pblock [get_pblocks pblock_rcn] -add {DSP48_X2Y36:DSP48_X2Y39}
# resize_pblock [get_pblocks pblock_rcn] -add {SLICE_X32Y100:SLICE_X37Y109}
# resize_pblock [get_pblocks pblock_rcn] -add {DSP48_X2Y40:DSP48_X2Y43}


create_pblock pblock_file0
add_cells_to_pblock [get_pblocks pblock_file0] [get_cells reg_file_inst0]
resize_pblock [get_pblocks pblock_file0] -add {SLICE_X38Y80:SLICE_X49Y99}
#resize_pblock [get_pblocks pblock_file0] -add {SLICE_X32Y90:SLICE_X49Y99}
# resize_pblock [get_pblocks pblock_file0] -add {SLICE_X32Y125:SLICE_X49Y149}

create_pblock pblock_file1
add_cells_to_pblock [get_pblocks pblock_file1] [get_cells reg_file_inst1]
resize_pblock [get_pblocks pblock_file1] -add {SLICE_X16Y25:SLICE_X19Y49}
resize_pblock [get_pblocks pblock_file1] -add {SLICE_X30Y25:SLICE_X33Y49}
resize_pblock [get_pblocks pblock_file1] -add {SLICE_X24Y25:SLICE_X25Y49}
resize_pblock [get_pblocks pblock_file1] -add {SLICE_X42Y0:SLICE_X47Y24}
# resize_pblock [get_pblocks pblock_file1] -add {SLICE_X36Y25:SLICE_X39Y39}
# resize_pblock [get_pblocks pblock_file1] -add {SLICE_X60Y0:SLICE_X67Y24}
# resize_pblock [get_pblocks pblock_file1] -add {SLICE_X32Y0:SLICE_X49Y9}

create_pblock pblock_file2
add_cells_to_pblock [get_pblocks pblock_file2] [get_cells reg_file_inst2]
resize_pblock [get_pblocks pblock_file2] -add {SLICE_X34Y0:SLICE_X35Y24}
resize_pblock [get_pblocks pblock_file2] -add {SLICE_X48Y0:SLICE_X49Y49}
resize_pblock [get_pblocks pblock_file2] -add {SLICE_X52Y0:SLICE_X53Y49}
#resize_pblock [get_pblocks pblock_file2] -add {SLICE_X20Y0:SLICE_X21Y24}
#resize_pblock [get_pblocks pblock_file2] -add {SLICE_X34Y0:SLICE_X35Y49}
# resize_pblock [get_pblocks pblock_file2] -add {SLICE_X26Y0:SLICE_X27Y24}
# resize_pblock [get_pblocks pblock_file2] -add {SLICE_X32Y25:SLICE_X35Y39}
# resize_pblock [get_pblocks pblock_file2] -add {SLICE_X36Y25:SLICE_X39Y39}
# resize_pblock [get_pblocks pblock_file2] -add {SLICE_X32Y15:SLICE_X49Y24}

create_pblock pblock_file3
add_cells_to_pblock [get_pblocks pblock_file3] [get_cells reg_file_inst3]
resize_pblock [get_pblocks pblock_file3] -add {SLICE_X54Y13:SLICE_X59Y49}
#resize_pblock [get_pblocks pblock_file3] -add {SLICE_X54Y13:SLICE_X57Y49}
resize_pblock [get_pblocks pblock_file3] -add {SLICE_X84Y0:SLICE_X87Y49}
# resize_pblock [get_pblocks pblock_file3] -add {SLICE_X54Y25:SLICE_X69Y44}
# resize_pblock [get_pblocks pblock_file3] -add {SLICE_X54Y30:SLICE_X67Y49}

create_pblock pblock_file4
add_cells_to_pblock [get_pblocks pblock_file4] [get_cells reg_file_inst4]
resize_pblock [get_pblocks pblock_file4] -add {SLICE_X54Y50:SLICE_X59Y79}

create_pblock pblock_file5
add_cells_to_pblock [get_pblocks pblock_file5] [get_cells reg_file_inst5]
resize_pblock [get_pblocks pblock_file5] -add {SLICE_X44Y50:SLICE_X53Y79}
resize_pblock [get_pblocks pblock_file5] -add {SLICE_X40Y50:SLICE_X43Y59}

create_pblock pblock_scan
add_cells_to_pblock [get_pblocks pblock_scan] [get_cells hdmi_scan_inst]
add_cells_to_pblock [get_pblocks pblock_scan] [get_cells scan_event_inst]
resize_pblock [get_pblocks pblock_scan] -add {SLICE_X36Y0:SLICE_X39Y24}
resize_pblock [get_pblocks pblock_scan] -add {DSP48_X2Y0:DSP48_X2Y9}
# resize_pblock [get_pblocks pblock_scan] -add {SLICE_X84Y0:SLICE_X101Y24}

create_pblock pblock_clut
add_cells_to_pblock [get_pblocks pblock_clut] [get_cells reg_lut_inst0]
resize_pblock [get_pblocks pblock_clut] -add {SLICE_X54Y100:SLICE_X57Y124}
resize_pblock [get_pblocks pblock_clut] -add {RAMB18_X3Y40:RAMB18_X3Y49}
resize_pblock [get_pblocks pblock_clut] -add {RAMB36_X3Y20:RAMB36_X3Y25}

create_pblock pblock_llut
add_cells_to_pblock [get_pblocks pblock_llut] [get_cells reg_lut_inst2]
# add_cells_to_pblock [get_pblocks pblock_llut] [get_cells llut_dout*reg]
resize_pblock [get_pblocks pblock_llut] -add {SLICE_X32Y100:SLICE_X35Y124}
resize_pblock [get_pblocks pblock_llut] -add {SLICE_X54Y125:SLICE_X57Y149}
resize_pblock [get_pblocks pblock_llut] -add {RAMB18_X3Y50:RAMB18_X3Y59}
resize_pblock [get_pblocks pblock_llut] -add {RAMB36_X3Y25:RAMB36_X3Y29}
resize_pblock [get_pblocks pblock_llut] -add {RAMB18_X2Y40:RAMB18_X2Y49}
resize_pblock [get_pblocks pblock_llut] -add {RAMB36_X2Y20:RAMB36_X2Y24}

create_pblock pblock_shuffle
add_cells_to_pblock [get_pblocks pblock_shuffle] [get_cells shuffle_inst]
resize_pblock [get_pblocks pblock_shuffle] -add {SLICE_X36Y25:SLICE_X45Y34}
# resize_pblock [get_pblocks pblock_shuffle] -add {SLICE_X36Y25:SLICE_X45Y36}

create_pblock pblock_matrix
add_cells_to_pblock [get_pblocks pblock_matrix] [get_cells matrix_inst]
resize_pblock [get_pblocks pblock_matrix] -add {SLICE_X94Y0:SLICE_X97Y49}
resize_pblock [get_pblocks pblock_matrix] -add {DSP48_X3Y10:DSP48_X3Y19}
resize_pblock [get_pblocks pblock_matrix] -add {DSP48_X4Y10:DSP48_X4Y19}

create_pblock pblock_glut
add_cells_to_pblock [get_pblocks pblock_glut] [get_cells reg_lut_inst1]
resize_pblock [get_pblocks pblock_glut] -add {SLICE_X90Y0:SLICE_X91Y49}
resize_pblock [get_pblocks pblock_glut] -add {RAMB18_X4Y0:RAMB18_X4Y19}
resize_pblock [get_pblocks pblock_glut] -add {RAMB36_X4Y0:RAMB36_X4Y9}



create_pblock pblock_spi
add_cells_to_pblock [get_pblocks pblock_spi] [get_cells reg_spi_inst]
resize_pblock [get_pblocks pblock_spi] -add {SLICE_X32Y125:SLICE_X49Y129}
# resize_pblock [get_pblocks pblock_spi] -add {SLICE_X32Y115:SLICE_X49Y119}


create_pblock pblock_axi0
add_cells_to_pblock [get_pblocks pblock_axi0] [get_cells axi_lite_inst0]
add_cells_to_pblock [get_pblocks pblock_axi0] [get_cells axi_split_inst0]
resize_pblock [get_pblocks pblock_axi0] -add {SLICE_X26Y100:SLICE_X31Y124}

create_pblock pblock_axi1
add_cells_to_pblock [get_pblocks pblock_axi1] [get_cells axi_lite_inst1]
add_cells_to_pblock [get_pblocks pblock_axi1] [get_cells axi_split_inst1]
resize_pblock [get_pblocks pblock_axi1] -add {SLICE_X40Y35:SLICE_X45Y49}
#resize_pblock [get_pblocks pblock_axi1] -add {SLICE_X20Y40:SLICE_X23Y49}
# resize_pblock [get_pblocks pblock_axi1] -add {SLICE_X26Y25:SLICE_X31Y39}
# resize_pblock [get_pblocks pblock_axi1] -add {SLICE_X26Y0:SLICE_X31Y24}


create_pblock pblock_dly
add_cells_to_pblock [get_pblocks pblock_dly] [get_cells reg_delay_inst]
resize_pblock [get_pblocks pblock_dly] -add {SLICE_X52Y125:SLICE_X53Y139}
resize_pblock [get_pblocks pblock_dly] -add {SLICE_X112Y50:SLICE_X113Y149}
#resize_pblock [get_pblocks pblock_dly] -add {SLICE_X50Y100:SLICE_X53Y104}
# resize_pblock [get_pblocks pblock_dly] -add {SLICE_X108Y50:SLICE_X109Y149}

create_pblock pblock_par
add_cells_to_pblock [get_pblocks pblock_par] [get_cells ser_to_par_inst]
resize_pblock [get_pblocks pblock_par] -add {SLICE_X98Y50:SLICE_X99Y89}
resize_pblock [get_pblocks pblock_par] -add {SLICE_X98Y110:SLICE_X99Y149}

create_pblock pblock_pat
add_cells_to_pblock [get_pblocks pblock_pat] [get_cells par_match_inst]
resize_pblock [get_pblocks pblock_pat] -add {SLICE_X102Y50:SLICE_X103Y89}
resize_pblock [get_pblocks pblock_pat] -add {SLICE_X102Y110:SLICE_X103Y149}
# resize_pblock [get_pblocks pblock_pat] -add {SLICE_X102Y50:SLICE_X105Y99}

create_pblock pblock_reme
add_cells_to_pblock [get_pblocks pblock_reme] [get_cells pixel_remap_even_inst]
resize_pblock [get_pblocks pblock_reme] -add {RAMB36_X4Y25:RAMB36_X4Y29}
resize_pblock [get_pblocks pblock_reme] -add {RAMB18_X4Y50:RAMB18_X4Y59}
resize_pblock [get_pblocks pblock_reme] -add {SLICE_X90Y110:SLICE_X91Y149}
resize_pblock [get_pblocks pblock_reme] -add {SLICE_X84Y110:SLICE_X87Y149}
resize_pblock [get_pblocks pblock_reme] -add {SLICE_X80Y110:SLICE_X81Y149}
resize_pblock [get_pblocks pblock_reme] -add {SLICE_X62Y110:SLICE_X63Y139}
#resize_pblock [get_pblocks pblock_reme] -add {SLICE_X62Y110:SLICE_X63Y139}
#resize_pblock [get_pblocks pblock_reme] -add {SLICE_X66Y120:SLICE_X83Y149}
#resize_pblock [get_pblocks pblock_reme] -add {SLICE_X90Y105:SLICE_X93Y139}
#resize_pblock [get_pblocks pblock_reme] -add {RAMB36_X4Y25:RAMB36_X4Y29}
#resize_pblock [get_pblocks pblock_reme] -add {RAMB18_X4Y50:RAMB18_X4Y59}
# resize_pblock [get_pblocks pblock_reme] -add {SLICE_X80Y75:SLICE_X97Y99}
# resize_pblock [get_pblocks pblock_reme] -add {SLICE_X80Y75:SLICE_X101Y99}
# resize_pblock [get_pblocks pblock_reme] -add {RAMB36_X4Y15:RAMB36_X4Y19}
# resize_pblock [get_pblocks pblock_reme] -add {RAMB18_X4Y30:RAMB18_X4Y39}

create_pblock pblock_remo
add_cells_to_pblock [get_pblocks pblock_remo] [get_cells pixel_remap_odd_inst]
resize_pblock [get_pblocks pblock_remo] -add {RAMB36_X4Y10:RAMB36_X4Y14}
resize_pblock [get_pblocks pblock_remo] -add {RAMB18_X4Y20:RAMB18_X4Y29}
resize_pblock [get_pblocks pblock_remo] -add {SLICE_X90Y50:SLICE_X91Y89}
resize_pblock [get_pblocks pblock_remo] -add {SLICE_X84Y50:SLICE_X87Y89}
resize_pblock [get_pblocks pblock_remo] -add {SLICE_X80Y50:SLICE_X81Y89}
resize_pblock [get_pblocks pblock_remo] -add {SLICE_X62Y60:SLICE_X63Y89}
#resize_pblock [get_pblocks pblock_remo] -add {SLICE_X62Y60:SLICE_X63Y89}
#resize_pblock [get_pblocks pblock_remo] -add {SLICE_X66Y50:SLICE_X83Y79}
#resize_pblock [get_pblocks pblock_remo] -add {SLICE_X90Y60:SLICE_X93Y94}
#resize_pblock [get_pblocks pblock_remo] -add {RAMB36_X4Y10:RAMB36_X4Y14}
#resize_pblock [get_pblocks pblock_remo] -add {RAMB18_X4Y20:RAMB18_X4Y29}
# resize_pblock [get_pblocks pblock_remo] -add {SLICE_X80Y50:SLICE_X97Y74}
# resize_pblock [get_pblocks pblock_remo] -add {SLICE_X80Y50:SLICE_X101Y74}
# resize_pblock [get_pblocks pblock_remo] -add {RAMB36_X4Y10:RAMB36_X4Y14}
# resize_pblock [get_pblocks pblock_remo] -add {RAMB18_X4Y20:RAMB18_X4Y29}

create_pblock pblock_chop
add_cells_to_pblock [get_pblocks pblock_chop] [get_cells fifo_chop_inst]
resize_pblock [get_pblocks pblock_chop] -add {SLICE_X64Y50:SLICE_X65Y91}
resize_pblock [get_pblocks pblock_chop] -add {SLICE_X80Y92:SLICE_X93Y95}
#resize_pblock [get_pblocks pblock_chop] -add {SLICE_X82Y88:SLICE_X85Y91}
resize_pblock [get_pblocks pblock_chop] -add {SLICE_X94Y50:SLICE_X95Y84}
# resize_pblock [get_pblocks pblock_chop] -add {SLICE_X80Y90:SLICE_X89Y91}
resize_pblock [get_pblocks pblock_chop] -add {SLICE_X64Y108:SLICE_X65Y149}
resize_pblock [get_pblocks pblock_chop] -add {SLICE_X80Y104:SLICE_X93Y107}
#resize_pblock [get_pblocks pblock_chop] -add {SLICE_X82Y108:SLICE_X85Y111}
resize_pblock [get_pblocks pblock_chop] -add {SLICE_X94Y115:SLICE_X95Y149}
# resize_pblock [get_pblocks pblock_chop] -add {SLICE_X80Y108:SLICE_X89Y109}
# resize_pblock [get_pblocks pblock_chop] -add {SLICE_X54Y80:SLICE_X55Y89}
# resize_pblock [get_pblocks pblock_chop] -add {SLICE_X54Y110:SLICE_X55Y119}
# resize_pblock [get_pblocks pblock_chop] -add {SLICE_X54Y50:SLICE_X61Y74}
# resize_pblock [get_pblocks pblock_chop] -add {SLICE_X54Y125:SLICE_X61Y149}
# resize_pblock [get_pblocks pblock_chop] -add {SLICE_X60Y50:SLICE_X61Y149}
# resize_pblock [get_pblocks pblock_chop] -add {SLICE_X66Y50:SLICE_X67Y99}
# resize_pblock [get_pblocks pblock_chop] -add {SLICE_X80Y50:SLICE_X81Y99}
# resize_pblock [get_pblocks pblock_chop] -add {SLICE_X64Y50:SLICE_X67Y99}

create_pblock pblock_div0
add_cells_to_pblock [get_pblocks pblock_div0] [get_cells -quiet [list div_lvds_inst0]]
resize_pblock [get_pblocks pblock_div0] -add {SLICE_X106Y43:SLICE_X109Y49}

create_pblock pblock_div1
add_cells_to_pblock [get_pblocks pblock_div1] [get_cells -quiet [list div_lvds_inst1]]
resize_pblock [get_pblocks pblock_div1] -add {SLICE_X110Y43:SLICE_X113Y49}

set_property LOC MMCME2_ADV_X1Y1 [get_cells cmv_pll_inst/mmcm_inst]
set_property LOC PLLE2_ADV_X1Y2 [get_cells lvds_pll_inst/pll_inst] 
# set_property LOC  MMCME2_ADV_X1Y0 [get_cells hdmi_pll_inst/mmcm_inst]

# set_property LOC PLLE2_ADV_X1Y1 [get_cells lvds_pll_inst/lvds_pll_inst]
# set_property LOC MMCME2_ADV_X1Y1 [get_cells lvds_pll_inst/lvds_mmcm_inst]

