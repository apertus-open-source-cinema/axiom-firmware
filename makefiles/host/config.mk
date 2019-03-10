# the device for which the image is build, possible values:
#   beta    for the axiom beta
#   micro   for the axiom micro
DEVICE ?= beta

# the cross compilation toolchain prefix
# (used by compilation of u-boot and linux)
CROSS ?= arm-linux-gnueabi-

IMAGE ?= axiom-$(DEVICE).img
