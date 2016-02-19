
# HDMI Signals

# LVDS_3 [JX2_22] (inverted)
set_property PACKAGE_PIN M14 [get_ports hdmi_south_clk_p]
set_property PACKAGE_PIN M15 [get_ports hdmi_south_clk_n]
set_property IOSTANDARD LVDS_25 [get_ports hdmi_south_clk_*]

# LVDS_2 [BANK13_06] (non inverted)
set_property PACKAGE_PIN V6 [get_ports {hdmi_south_d_p[2]}]
set_property PACKAGE_PIN W6 [get_ports {hdmi_south_d_n[2]}]
# LVDS_1 [BANK13_04] (non inverted)
set_property PACKAGE_PIN Y12 [get_ports {hdmi_south_d_p[1]}]
set_property PACKAGE_PIN Y13 [get_ports {hdmi_south_d_n[1]}]
# LVDS_0 [BANK13_05] (inverted)
set_property PACKAGE_PIN V11 [get_ports {hdmi_south_d_p[0]}]
set_property PACKAGE_PIN V10 [get_ports {hdmi_south_d_n[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {hdmi_south_d_*}]

# LVDS_5A [JX2_18_P]
set_property PACKAGE_PIN N15 [get_ports hdmi_south_scl]
set_property IOSTANDARD LVCMOS25 [get_ports hdmi_south_scl]

# LVDS_5B [JX2_18_N]
set_property PACKAGE_PIN N16 [get_ports hdmi_south_sda]
set_property IOSTANDARD LVCMOS25 [get_ports hdmi_south_sda]

