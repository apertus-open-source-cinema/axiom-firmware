ARCH = arm
CROSS = arm-linux-gnueabi-

LINUX_VERSION = v4.20.4
LINUX_SOURCE = build/linux-$(LINUX_VERSION).git

UBOOT_VERSION = xilinx-v2018.3
UBOOT_SOURCE = build/u-boot-xlnx-$(UBOOT_VERSION).git

build/boot.fs/BOOT.bin: $(LINUX_SOURCE)/arch/arm/boot/zImage $(UBOOT_SOURCE)/u-boot.elf build/boot.fs/devicetree.dtb \
			   build/zynq-mkbootimage.git/mkbootimage boot/boot.bif boot/axiom-$(DEVICE)/fsbl.elf boot/axiom-$(DEVICE)/uEnv.txt \
			   build/boot.fs/devicetree.dts
	mkdir -p $(@D)

ifeq ($(DEVICE),micro)
	cp -a boot/axiom-micro/bitstream.bit build/boot.fs/bitstream.bit
endif

	cp boot/axiom-$(DEVICE)/uEnv.txt boot/axiom-$(DEVICE)/fsbl.elf boot/boot.bif $(UBOOT_SOURCE)/u-boot.elf $(LINUX_SOURCE)/arch/arm/boot/zImage $(@D)

	(cd $(@D) && ../zynq-mkbootimage.git/mkbootimage boot.bif BOOT.bin)


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
# TODO use mainline uboot -> profit (use `--depth 1` again)
U_BOOT_MAKE = $(MAKE) -C $(UBOOT_SOURCE) CROSS_COMPILE=$(CROSS) ARCH=$(ARCH)
$(UBOOT_SOURCE): 
	@mkdir -p $(@D)
	git clone --branch $(UBOOT_VERSION) --depth 1 https://github.com/Xilinx/u-boot-xlnx $@

$(UBOOT_SOURCE)/u-boot.elf: boot/axiom-$(DEVICE)/u-boot.config $(UBOOT_SOURCE) boot/axiom-micro/devicetree_uboot.dts boot/axiom-beta/devicetree_uboot.dts
	# copy the devicetree's (done here to avoid redownload on changed devicetree)
	cp boot/axiom-micro/devicetree_uboot.dts $(UBOOT_SOURCE)/arch/arm/dts/zynq-zturn-myir.dts
	cp boot/axiom-beta/devicetree_uboot.dts $(UBOOT_SOURCE)/arch/arm/dts/zynq-microzed.dts
	# configure u-boot
	cp $< $(UBOOT_SOURCE)/.config
	+$(U_BOOT_MAKE) olddefconfig

	# finally make it
	+$(U_BOOT_MAKE) u-boot.elf
	touch $@

build/boot.fs/devicetree.dtb: boot/axiom-$(DEVICE)/devicetree.dts
	@mkdir -p $(@D)
	dtc -I dts -O dtb -o $@ $<

build/boot.fs/devicetree.dts: boot/axiom-$(DEVICE)/devicetree.dts
	@mkdir -p $(@D)
	cp $< $@

# tool for generating BOOT.bin
build/zynq-mkbootimage.git/mkbootimage:
	git clone --depth 1 https://github.com/antmicro/zynq-mkbootimage build/zynq-mkbootimage.git
	+$(MAKE) -C $(@D) 

	touch $@
