#!/bin/bash
# set gain x1, full 12-bit range
axiom_set_gain.sh 1

# set HDMI 4K experimental mode: 
# 10 delayed mode:  Rs/Rs', G1s/G2s, Bs/Bs'
axiom_scn_reg 31 0xA01

# nearly optimal parameters for gain x1
gamma=0.52
gain=0.85
offset=55

# set matrix and gamma
axiom_mat4_conf.sh 0 $gain 0 0  0 0 0 $gain  0 0 $gain 0  $gain 0 0 0  0 0 0 0
axiom_gamma_conf.sh $gamma

# set RCN parameters from dark frame
axiom_rcn_darkframe.py $offset

# tip: to check the pattern noise on a dark frame, try this:
#axiom_mat4_conf.sh 0 20 0 0  0 0 0 20  0 0 20 0  20 0 0 0  0 0 0 0
