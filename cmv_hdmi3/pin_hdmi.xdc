
#			North		South
# LVDS_3 -> clock(P)	BANK13_03(P)	JX2_22(N)
# LVDS_2 -> data 0(P)	JX1_23(P)	BANK13_06(N)
# LVDS_1 -> data 1(P)	JX1_21(P)	BANK13_04(P)
# LVDS_0 -> data 2(P)	JX1_19(P)	BANK13_05(P)

# HDMI Signals
# IO_L13P_T2_MRCC_35, IO_L13N_T2_MRCC_35
# set_property PACKAGE_PIN Y12 [get_ports hdmi_clk_p]
# set_property PACKAGE_PIN Y13 [get_ports hdmi_clk_n]
# (inverted)
set_property PACKAGE_PIN M14 [get_ports hdmi_clk_p]
set_property PACKAGE_PIN M15 [get_ports hdmi_clk_n]
set_property IOSTANDARD LVDS_25 [get_ports hdmi_clk_*]

# (normal)
set_property PACKAGE_PIN V6 [get_ports {hdmi_d_p[2]}]
set_property PACKAGE_PIN W6 [get_ports {hdmi_d_n[2]}]
# (normal)
set_property PACKAGE_PIN Y12 [get_ports {hdmi_d_p[1]}]
set_property PACKAGE_PIN Y13 [get_ports {hdmi_d_n[1]}]
# (inverted)
set_property PACKAGE_PIN V11 [get_ports {hdmi_d_p[0]}]
set_property PACKAGE_PIN V10 [get_ports {hdmi_d_n[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {hdmi_d_*}]

