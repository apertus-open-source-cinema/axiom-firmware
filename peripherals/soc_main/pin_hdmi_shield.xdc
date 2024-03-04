
# HDMI Signals

# XX4 [JX2_02] (non inverted)
set_property PACKAGE_PIN E17 [get_ports hdmi_shield_clk_p]
set_property PACKAGE_PIN D18 [get_ports hdmi_shield_clk_n]
set_property IOSTANDARD LVDS_25 [get_ports hdmi_shield_clk_*]

# XX3 [JX2_00] (inverted)
set_property PACKAGE_PIN C20 [get_ports {hdmi_shield_d_p[2]}]
set_property PACKAGE_PIN B20 [get_ports {hdmi_shield_d_n[2]}]
# XX1 [JX1_01] (not inverted)
set_property PACKAGE_PIN T12 [get_ports {hdmi_shield_d_p[1]}]
set_property PACKAGE_PIN U12 [get_ports {hdmi_shield_d_n[1]}]
# XX2 [JX1_03] (inverted)
set_property PACKAGE_PIN V12 [get_ports {hdmi_shield_d_p[0]}]
set_property PACKAGE_PIN W13 [get_ports {hdmi_shield_d_n[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {hdmi_shield_d_*}]

