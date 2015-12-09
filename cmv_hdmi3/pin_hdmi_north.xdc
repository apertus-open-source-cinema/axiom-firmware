
# HDMI Signals

# LVDS_3 [BANK13_03] (non inverted)
set_property PACKAGE_PIN T5 [get_ports hdmi_north_clk_p]
set_property PACKAGE_PIN U5 [get_ports hdmi_north_clk_n]
set_property IOSTANDARD LVDS_25 [get_ports hdmi_north_clk_*]

# LVDS_2 [JX1_23] (non inverted)
set_property PACKAGE_PIN P15 [get_ports {hdmi_north_d_p[2]}]
set_property PACKAGE_PIN P16 [get_ports {hdmi_north_d_n[2]}]
# LVDS_1 [JX1_21] (non inverted)
set_property PACKAGE_PIN W18 [get_ports {hdmi_north_d_p[1]}]
set_property PACKAGE_PIN W19 [get_ports {hdmi_north_d_n[1]}]
# LVDS_0 [JX1_19] (non inverted)
set_property PACKAGE_PIN T17 [get_ports {hdmi_north_d_p[0]}]
set_property PACKAGE_PIN R18 [get_ports {hdmi_north_d_n[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {hdmi_north_d_*}]

# LVDS_5A [BANK13_00_P]
set_property PACKAGE_PIN U7 [get_ports hdmi_north_scl]
set_property IOSTANDARD LVCMOS25 [get_ports hdmi_north_scl]

# LVDS_5B [BANK13_00_N]
set_property PACKAGE_PIN V7 [get_ports hdmi_north_sda]
set_property IOSTANDARD LVCMOS25 [get_ports hdmi_north_sda]

