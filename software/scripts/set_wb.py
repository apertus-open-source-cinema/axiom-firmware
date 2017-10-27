#!/usr/bin/python
import os, sys
from mat4_conf import *
import numpy as np
import numpy.linalg as linalg

# average of a dark frame, assuming you did the RCN calibration
# note: it changes with exposure time
black_level = 128

num_args = len(sys.argv) - 1
kelvin = None
color_matrix = np.eye(3)

if num_args == 1:
    kelvin      = int(sys.argv[1])
    green       = 1
elif num_args == 2:
    kelvin      = int(sys.argv[1])
    green       = int(sys.argv[2])
elif num_args == 3:
    gain_red    = float(sys.argv[1])
    gain_green  = float(sys.argv[2])
    gain_blue   = float(sys.argv[3])
elif num_args == 4:
    gain_red    = float(sys.argv[1]) * float(sys.argv[4])
    gain_green  = float(sys.argv[2]) * float(sys.argv[4])
    gain_blue   = float(sys.argv[3]) * float(sys.argv[4])
elif num_args == 5:
    gain_red    = float(sys.argv[1]) * float(sys.argv[4])
    gain_green  = float(sys.argv[2]) * float(sys.argv[4])
    gain_blue   = float(sys.argv[3]) * float(sys.argv[4])
    black_level = float(sys.argv[5])
elif num_args == 6:
    gain_red    = float(sys.argv[1]) * float(sys.argv[4])
    gain_green  = float(sys.argv[2]) * float(sys.argv[4])
    gain_blue   = float(sys.argv[3]) * float(sys.argv[4])
    black_level = float(sys.argv[5])
    cm_index    = int(sys.argv[6])
    if cm_index == 1:
        # to match 60D, after applying WB
        # computed from IT8 under Tungsten light
        # for some reason, it looks ugly
        color_matrix = np.array(
            [[  1.777141, -0.065062, -0.712079],
             [ -0.979460,  3.245220, -1.265761],
             [ -0.849095, -1.162445,  3.011540]]
        )
    elif cm_index == 2:
        # to match 60D raw, after applying WB
        # computed from IT8 under Tungsten light
        color_matrix = np.array(
            [[  0.693741,  0.991963, -0.685704],
             [ -0.706135,  2.027586, -0.321451],
             [ -0.806344, -0.075798,  1.882142]]
        )

else:
    print("Set white balance for HDMI output.")
    print("Usage:")
    print("  ./set_wb.py 5000                # kelvin")
    print("  ./set_wb.py 5000 1.1            # kelvin and green")
    print("  ./set_wb.py 1 1.5 2.8           # RGB multipliers")
    print("  ./set_wb.py 1 1.5 2.8 0.5       # RGB multipliers with scaling factor")
    print("  ./set_wb.py 1 1.5 2.8 0.5 128   # RGB multipliers with scaling factor and black level")
    print("  ./set_wb.py 1 1.5 2.8 0.5 128 1 # RGB multipliers with scaling factor, black level and color matrix")

if kelvin:
    print("Setting white balance to %dK,green=%.2f ..." % (kelvin, green))
    # compute multipliers
else:
    print("Setting white balance to R%.2f G%.2f B%.2f ..." % (gain_red, gain_blue, gain_green))

black = black_level / 4095.0

wb_matrix = np.array(
    [[gain_red, 0,          0        ],
     [0,        gain_green, 0        ],
     [0,        0,          gain_blue]]
)

black_offset = [
    -black * gain_red,
    -black * gain_green,
    -black * gain_blue
]

M = mat3_to4(np.dot(color_matrix, wb_matrix))
off = off3_to4(black_offset)

mat_set(M)
off_set(off)

# activate high+low clipping
os.system("scn_reg 28 0x30")
