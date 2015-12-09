
# create_clock -period 6.666 -name lvds_outclk -waveform {0.000 3.333} [get_ports cmv_lvds_outclk*]
# create_clock -period 7.5 -name lvds_outclk -waveform {0.000 3.75} [get_ports cmv_lvds_outclk*]
create_clock -period 8.000 -name lvds_outclk -waveform {0.000 4.000} [get_ports cmv_lvds_outclk_p]

# set_input_delay -clock pll_lvds_clk -max  3.0 [get_ports cmv_lvds_data*]
# set_input_delay -clock pll_lvds_clk -max  3.0 [get_ports cmv_lvds_data*] -clock_fall -add_delay
# set_input_delay -clock pll_lvds_clk -min  2.0 [get_ports cmv_lvds_data*]
# set_input_delay -clock pll_lvds_clk -min  2.0 [get_ports cmv_lvds_data*] -clock_fall -add_delay

# set_input_delay -clock pll_lvds_clk -max  3.0 [get_ports cmv_lvds_ctrl*]
# set_input_delay -clock pll_lvds_clk -max  3.0 [get_ports cmv_lvds_ctrl*] -clock_fall -add_delay
# set_input_delay -clock pll_lvds_clk -min  2.0 [get_ports cmv_lvds_ctrl*]
# set_input_delay -clock pll_lvds_clk -min  2.0 [get_ports cmv_lvds_ctrl*] -clock_fall -add_delay

# set_input_delay -clock pll_lvds_clk -network_latency_included 3.333 [get_ports cmv_lvds_data*]

# set_input_delay -clock pll_lvds_clk -max -1.0 [get_ports cmv_lvds_data_p*]
# set_input_delay -clock pll_lvds_clk -min -1.5 [get_ports cmv_lvds_data_p*]

# set_max_delay -from [get_ports cmv_lvds_data*] 0.5

set_property PACKAGE_PIN V13 [get_ports cmv_clk]
# dummy exp1 JX1_SE_1
set_property PACKAGE_PIN T19 [get_ports cmv_t_exp1]
# dummy exp2 BANK13_SE_0
set_property PACKAGE_PIN V5  [get_ports cmv_t_exp2]
set_property PACKAGE_PIN W13 [get_ports cmv_frame_req]
set_property PACKAGE_PIN U13 [get_ports cmv_sys_res_n]

set_property IOSTANDARD LVCMOS25 [get_ports cmv_*]


set_property PACKAGE_PIN P18 [get_ports cmv_lvds_clk_n]
set_property PACKAGE_PIN N17 [get_ports cmv_lvds_clk_p]

set_property PACKAGE_PIN N20 [get_ports cmv_lvds_outclk_p]
set_property PACKAGE_PIN P20 [get_ports cmv_lvds_outclk_n]

set_property PACKAGE_PIN L15 [get_ports cmv_lvds_ctrl_n]
set_property PACKAGE_PIN L14 [get_ports cmv_lvds_ctrl_p]

set_property PACKAGE_PIN G15 [get_ports {cmv_lvds_data_n[0]}]
set_property PACKAGE_PIN J16 [get_ports {cmv_lvds_data_n[1]}]
set_property PACKAGE_PIN H20 [get_ports {cmv_lvds_data_n[2]}]
set_property PACKAGE_PIN G20 [get_ports {cmv_lvds_data_n[3]}]
set_property PACKAGE_PIN F20 [get_ports {cmv_lvds_data_n[4]}]
set_property PACKAGE_PIN G18 [get_ports {cmv_lvds_data_n[5]}]
set_property PACKAGE_PIN H18 [get_ports {cmv_lvds_data_n[6]}]
set_property PACKAGE_PIN K18 [get_ports {cmv_lvds_data_n[7]}]
set_property PACKAGE_PIN L17 [get_ports {cmv_lvds_data_n[8]}]
set_property PACKAGE_PIN J19 [get_ports {cmv_lvds_data_n[9]}]
set_property PACKAGE_PIN M18 [get_ports {cmv_lvds_data_n[10]}]
set_property PACKAGE_PIN M20 [get_ports {cmv_lvds_data_n[11]}]
set_property PACKAGE_PIN L20 [get_ports {cmv_lvds_data_n[12]}]
set_property PACKAGE_PIN A20 [get_ports {cmv_lvds_data_n[13]}]
set_property PACKAGE_PIN F17 [get_ports {cmv_lvds_data_n[14]}]
set_property PACKAGE_PIN D20 [get_ports {cmv_lvds_data_n[15]}]
set_property PACKAGE_PIN W16 [get_ports {cmv_lvds_data_n[16]}]
set_property PACKAGE_PIN W20 [get_ports {cmv_lvds_data_n[17]}]
set_property PACKAGE_PIN H17 [get_ports {cmv_lvds_data_n[18]}]
set_property PACKAGE_PIN V18 [get_ports {cmv_lvds_data_n[19]}]
set_property PACKAGE_PIN R17 [get_ports {cmv_lvds_data_n[20]}]
set_property PACKAGE_PIN Y19 [get_ports {cmv_lvds_data_n[21]}]
set_property PACKAGE_PIN U20 [get_ports {cmv_lvds_data_n[22]}]
set_property PACKAGE_PIN P19 [get_ports {cmv_lvds_data_n[23]}]
set_property PACKAGE_PIN U15 [get_ports {cmv_lvds_data_n[24]}]
set_property PACKAGE_PIN U17 [get_ports {cmv_lvds_data_n[25]}]
set_property PACKAGE_PIN U19 [get_ports {cmv_lvds_data_n[26]}]
set_property PACKAGE_PIN W15 [get_ports {cmv_lvds_data_n[27]}]
set_property PACKAGE_PIN Y14 [get_ports {cmv_lvds_data_n[28]}]
set_property PACKAGE_PIN T10 [get_ports {cmv_lvds_data_n[29]}]
set_property PACKAGE_PIN Y17 [get_ports {cmv_lvds_data_n[30]}]
set_property PACKAGE_PIN T15 [get_ports {cmv_lvds_data_n[31]}]

set_property PACKAGE_PIN H15 [get_ports {cmv_lvds_data_p[0]}]
set_property PACKAGE_PIN K16 [get_ports {cmv_lvds_data_p[1]}]
set_property PACKAGE_PIN J20 [get_ports {cmv_lvds_data_p[2]}]
set_property PACKAGE_PIN G19 [get_ports {cmv_lvds_data_p[3]}]
set_property PACKAGE_PIN F19 [get_ports {cmv_lvds_data_p[4]}]
set_property PACKAGE_PIN G17 [get_ports {cmv_lvds_data_p[5]}]
set_property PACKAGE_PIN J18 [get_ports {cmv_lvds_data_p[6]}]
set_property PACKAGE_PIN K17 [get_ports {cmv_lvds_data_p[7]}]
set_property PACKAGE_PIN L16 [get_ports {cmv_lvds_data_p[8]}]
set_property PACKAGE_PIN K19 [get_ports {cmv_lvds_data_p[9]}]
set_property PACKAGE_PIN M17 [get_ports {cmv_lvds_data_p[10]}]
set_property PACKAGE_PIN M19 [get_ports {cmv_lvds_data_p[11]}]
set_property PACKAGE_PIN L19 [get_ports {cmv_lvds_data_p[12]}]
set_property PACKAGE_PIN B19 [get_ports {cmv_lvds_data_p[13]}]
set_property PACKAGE_PIN F16 [get_ports {cmv_lvds_data_p[14]}]
set_property PACKAGE_PIN D19 [get_ports {cmv_lvds_data_p[15]}]
set_property PACKAGE_PIN V16 [get_ports {cmv_lvds_data_p[16]}]
set_property PACKAGE_PIN V20 [get_ports {cmv_lvds_data_p[17]}]
set_property PACKAGE_PIN H16 [get_ports {cmv_lvds_data_p[18]}]
set_property PACKAGE_PIN V17 [get_ports {cmv_lvds_data_p[19]}]
set_property PACKAGE_PIN R16 [get_ports {cmv_lvds_data_p[20]}]
set_property PACKAGE_PIN Y18 [get_ports {cmv_lvds_data_p[21]}]
set_property PACKAGE_PIN T20 [get_ports {cmv_lvds_data_p[22]}]
set_property PACKAGE_PIN N18 [get_ports {cmv_lvds_data_p[23]}]
set_property PACKAGE_PIN U14 [get_ports {cmv_lvds_data_p[24]}]
set_property PACKAGE_PIN T16 [get_ports {cmv_lvds_data_p[25]}]
set_property PACKAGE_PIN U18 [get_ports {cmv_lvds_data_p[26]}]
set_property PACKAGE_PIN V15 [get_ports {cmv_lvds_data_p[27]}]
set_property PACKAGE_PIN W14 [get_ports {cmv_lvds_data_p[28]}]
set_property PACKAGE_PIN T11 [get_ports {cmv_lvds_data_p[29]}]
set_property PACKAGE_PIN Y16 [get_ports {cmv_lvds_data_p[30]}]
set_property PACKAGE_PIN T14 [get_ports {cmv_lvds_data_p[31]}]
	
set_property IOSTANDARD LVDS_25 [get_ports cmv_lvds_*]

