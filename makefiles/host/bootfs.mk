ARCH = arm
CROSS = arm-linux-gnueabi-

build/boot.fs/BOOT.bin: build/linux-xlnx.git/arch/arm/boot/zImage build/u-boot-xlnx.git/u-boot.elf build/boot.fs/devicetree.dtb \
			   build/zynq-mkbootimage.git/mkbootimage \
			   boot/boot.bif boot/fsbl.elf boot/uEnv.txt
	@mkdir -p $(@D)
	
	cp boot/uEnv.txt boot/fsbl.elf boot/boot.bif build/u-boot-xlnx.git/u-boot.elf build/linux-xlnx.git/arch/arm/boot/zImage $(@D) 

	(cd  $(@D); ../zynq-mkbootimage.git/mkbootimage boot.bif BOOT.bin)
	[ "$(DEVICE)" = "micro" ] && echo "micro" && cp boot/axiom-micro/BOOT.bin $@ # evil hack; TODO: remove


### Kernel
build/linux-xlnx.git: boot/axiom-$(DEVICE)/kernel.config
	git clone --branch xilinx-v2016.4 --depth 1 https://github.com/Xilinx/linux-xlnx.git build/linux-xlnx.git
	cp boot/axiom-$(DEVICE)/kernel.config build/linux-xlnx.git/.config

KERNEL_MAKE = make CROSS_COMPILE=$(CROSS) ARCH=$(ARCH)
build/linux-xlnx.git/arch/arm/boot/zImage: build/linux-xlnx.git build/devicetree.dtb
	(cd build/linux-xlnx.git; yes "" | $(KERNEL_MAKE) oldconfig || true)
	(cd build/linux-xlnx.git; $(KERNEL_MAKE) -j -l $$(nproc) )
	(cd build/linux-xlnx.git; $(KERNEL_MAKE) ../../build/devicetree.dtb )
	(cd build/linux-xlnx.git; $(KERNEL_MAKE) -j -l $$(nproc) modules)

	mkdir -p build/kernel_modules.fs
	(cd build/linux-xlnx.git; $(KERNEL_MAKE) INSTALL_MOD_PATH=../kernel_modules.fs modules_install )
	touch $@


### u-boot

build/u-boot-xlnx.git: boot/axiom-$(DEVICE)/u-boot.config
	git clone --depth 1 https://github.com/Xilinx/u-boot-xlnx $@
	cp boot/axiom-$(DEVICE)/u-boot.config build/u-boot-xlnx.git/.config

U_BOOT_MAKE = make CROSS_COMPILE=$(CROSS) ARCH=$(ARCH)
build/u-boot-xlnx.git/u-boot.elf: build/u-boot-xlnx.git
	(cd build/u-boot-xlnx.git; $(U_BOOT_MAKE) olddefconfig)
	(cd build/u-boot-xlnx.git; $(U_BOOT_MAKE) u-boot.elf)


build/zynq-mkbootimage.git/mkbootimage:
	git clone --depth 1 https://github.com/antmicro/zynq-mkbootimage build/zynq-mkbootimage.git

	(cd build/zynq-mkbootimage.git; make -j -l $$(nproc))



build/boot.fs/devicetree.dtb: boot/axiom-$(DEVICE)/devicetree.dts
	@mkdir -p $(@D)
	dtc -I dts -O dtb -o $@ $<
