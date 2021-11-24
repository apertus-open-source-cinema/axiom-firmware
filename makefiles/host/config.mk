# SPDX-FileCopyrightText: © 2018 Jaro Habiger <jarohabiger@googlemail.com>
# SPDX-FileCopyrightText: © 2018 Robin Ole Heinemann <robin.ole.heinemann@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

# the device for which the image is build, possible values:
#   beta    for the axiom beta
#   micro   for the axiom micro
DEVICE ?= beta

# the cross compilation toolchain prefix
# (used by compilation of u-boot and linux)
CROSS ?= arm-linux-gnueabi-

IMAGE ?= axiom-$(DEVICE).img
