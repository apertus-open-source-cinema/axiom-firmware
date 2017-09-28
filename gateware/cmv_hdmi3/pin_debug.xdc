
# LVDS_3 [BANK13_03] (non inverted)
# set_property PACKAGE_PIN U5 [get_ports {debug_tmds[3]}]
set_property PACKAGE_PIN T5 [get_ports {debug_tmds[3]}]
# LVDS_2 [JX1_23] (non inverted)
# set_property PACKAGE_PIN P16 [get_ports {debug_tmds[2]}]
set_property PACKAGE_PIN P15 [get_ports {debug_tmds[2]}]
# LVDS_1 [JX1_21] (non inverted)
# set_property PACKAGE_PIN W19 [get_ports {debug_tmds[1]}]
set_property PACKAGE_PIN W18 [get_ports {debug_tmds[1]}]
# LVDS_0 [JX1_19] (non inverted)
# set_property PACKAGE_PIN R18 [get_ports {debug_tmds[0]}]
set_property PACKAGE_PIN T17 [get_ports {debug_tmds[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {debug_tmds[*]}]
set_property DRIVE 12 [get_ports {debug_tmds[*]}]
set_property SLEW SLOW [get_ports {debug_tmds[*]}]


# LVDS_4A [BANK13_02_N]
set_property PACKAGE_PIN W8 [get_ports {debug[2]}]

# LVDS_4B [BANK13_02_P]
set_property PACKAGE_PIN V8 [get_ports {debug[3]}]

# LVDS_5A [BANK13_00_P]
set_property PACKAGE_PIN U7 [get_ports {debug[1]}]

# LVDS_5B [BANK13_00_N]
set_property PACKAGE_PIN V7 [get_ports {debug[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {debug[*]}]
set_property DRIVE 12 [get_ports {debug[*]}]
set_property SLEW SLOW [get_ports {debug[*]}]

# set_output_delay -clock pll_hdmi_clk -max -2 [get_ports {debug[*]}]
# set_output_delay -clock pll_hdmi_clk -min -3 [get_ports {debug[*]}]

# set_output_delay -clock pll_hdmi_clk -max -7 [get_ports {debug_tmds[*]}]
# set_output_delay -clock pll_hdmi_clk -min -8 [get_ports {debug_tmds[*]}]

