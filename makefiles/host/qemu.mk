# SPDX-FileCopyrightText: © 2018 Jaro Habiger <jarohabiger@googlemail.com>
# SPDX-FileCopyrightText: © 2018 Robin Ole Heinemann <robin.ole.heinemann@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

QEMU_VERSION = xilinx-v2021.1
QEMU_SOURCE = build/qemu-$(QEMU_VERSION).git

QEMU_MAKE = $(MAKE) -C $(QEMU_SOURCE)


QEMU_PATCHES = $(wildcard patches/qemu/*.patch)

$(QEMU_SOURCE): $(QEMU_PATCHES)
	@mkdir -p $(@D)
	rm -rf $@
	git clone --branch $(QEMU_VERSION) --depth 1 https://github.com/Xilinx/qemu.git $@
	(cd $(QEMU_SOURCE) && git submodule update --init dtc)
	./makefiles/host/patch_wrapper.sh $@ $(QEMU_PATCHES)

$(QEMU_SOURCE)/aarch64-softmmu/qemu-system-aarch64: $(QEMU_SOURCE)
	# disable werror due to upstream bugs
	(cd $(QEMU_SOURCE) && ./configure --target-list="aarch64-softmmu" --enable-fdt --disable-kvm --disable-xen --disable-werror)
	+$(QEMU_MAKE)
