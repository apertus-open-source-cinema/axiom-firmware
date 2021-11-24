# SPDX-FileCopyrightText: © 2018 Jaro Habiger <jarohabiger@googlemail.com>
# SPDX-FileCopyrightText: © 2018 Robin Ole Heinemann <robin.ole.heinemann@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

ARCH = arm

LINUX_VERSION = v5.8.1
LINUX_SOURCE = build/linux-$(LINUX_VERSION).git

UBOOT_VERSION = v2020.07
UBOOT_SOURCE = build/u-boot-$(UBOOT_VERSION).git

build/boot.fs/.install_stamp: $(LINUX_SOURCE)/arch/arm/boot/zImage $(UBOOT_SOURCE)/u-boot.img $(UBOOT_SOURCE)/spl/boot.bin build/boot.fs/devicetree.dtb \
			   boot/axiom-$(DEVICE)/uEnv.txt build/boot.fs/devicetree.dts build/boot.fs/boot.scr
	mkdir -p $(@D)

ifeq ($(DEVICE),micro)
	cp -a boot/axiom-micro/bitstream.bit $(@D)/bitstream.bit
endif

	cp boot/axiom-$(DEVICE)/uEnv.txt $(UBOOT_SOURCE)/u-boot.img $(UBOOT_SOURCE)/spl/boot.bin $(LINUX_SOURCE)/arch/arm/boot/zImage $(@D)

	touch $@


### Kernel
KERNEL_MAKE = $(MAKE) -C $(LINUX_SOURCE) CROSS_COMPILE=$(CROSS) ARCH=$(ARCH)
LINUX_PATCHES = $(wildcard patches/linux/*.patch)

$(LINUX_SOURCE): $(LINUX_PATCHES)
	@mkdir -p $(@D)
	rm -rf $@
	git clone --branch $(LINUX_VERSION) --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git $@

	./makefiles/host/patch_wrapper.sh $@ $(LINUX_PATCHES)
	# remove + at end of kernel version (indicates dirty tree)
	touch $@/.scmversion


$(LINUX_SOURCE)/arch/arm/boot/zImage: boot/kernel.config $(LINUX_SOURCE)
	# first configure the kernel
	cp $< $(LINUX_SOURCE)/.config
	+$(KERNEL_MAKE) olddefconfig

	# then build the kernel
	+$(KERNEL_MAKE)
	+$(KERNEL_MAKE) modules

	# finally install the kernel modules
	mkdir -p build/kernel_modules.fs
	+$(KERNEL_MAKE) INSTALL_MOD_PATH=../kernel_modules.fs modules_install

	touch $@

# u-boot
U_BOOT_MAKE = $(MAKE) -C $(UBOOT_SOURCE) CROSS_COMPILE=$(CROSS) ARCH=$(ARCH)
U_BOOT_PATCHES = $(wildcard patches/u-boot/*.patch)
$(UBOOT_SOURCE)/.config: export DEVICE_TREE = $(U_BOOT_DEVICE_TREE)
$(UBOOT_SOURCE)/.config: $(U_BOOT_PATCHES)
	@mkdir -p $(@D)
	rm -rf $(@D)
	git clone --branch $(UBOOT_VERSION) --depth 1 https://gitlab.denx.de/u-boot/u-boot.git $(@D)

	./makefiles/host/patch_wrapper.sh $(@D) $(U_BOOT_PATCHES)
	# remove -dirty from version
	touch $(@D)/.scmversion

	# configure u-boot
	+$(U_BOOT_MAKE) xilinx_zynq_virt_defconfig
	touch $@

$(UBOOT_SOURCE)/u-boot.img: export DEVICE_TREE = $(U_BOOT_DEVICE_TREE)
$(UBOOT_SOURCE)/u-boot.img: $(UBOOT_SOURCE)/.config
	+$(U_BOOT_MAKE) u-boot.img
	touch $@

$(UBOOT_SOURCE)/spl/boot.bin: export DEVICE_TREE = $(U_BOOT_DEVICE_TREE)
$(UBOOT_SOURCE)/spl/boot.bin: $(UBOOT_SOURCE)/.config $(UBOOT_SOURCE)/u-boot.img
	+$(U_BOOT_MAKE) spl/boot.bin
	touch $@

build/boot.fs/boot.scr: boot/sdboot.cmd $(UBOOT_SOURCE)/spl/boot.bin
	./$(UBOOT_SOURCE)/tools/mkimage -c none -A arm -T script -d $< $@

build/boot.fs/devicetree.dtb: boot/axiom-$(DEVICE)/devicetree.dts
	@mkdir -p $(@D)
	dtc -@ -I dts -O dtb -o $@ $<

build/boot.fs/devicetree.dts: boot/axiom-$(DEVICE)/devicetree.dts
	@mkdir -p $(@D)
	cp $< $@
