ARCH = arm
CROSS = arm-linux-gnueabi-

build/boot.fs/BOOT.bin: build/BOOT-$(DEVICE).bin
	cp $< $@

build/BOOT-beta.bin: build/linux-xlnx.git/arch/arm/boot/zImage build/u-boot-xlnx.git/u-boot.elf build/devicetree.dtb \
			   build/zynq-mkbootimage.git/mkbootimage \
			   boot/boot.bif boot/fsbl.elf boot/axiom-$(DEVICE)/uEnv.txt
	mkdir -p build/boot.fs
	cp boot/boot.bif build/boot.fs/
	cp boot/fsbl.elf build/boot.fs/
	cp boot/axiom-$(DEVICE)/uEnv.txt build/boot.fs/
	cp build/devicetree.dtb build/boot.fs/

	cp build/u-boot-xlnx.git/u-boot.elf build/boot.fs/
	cp build/linux-xlnx.git/arch/arm/boot/zImage build/boot.fs

	(cd build/boot.fs/; ../zynq-mkbootimage.git/mkbootimage boot.bif ../BOOT-beta.bin)

build/BOOT-micro.bin: boot/axiom-micro/BOOT.bin
	cp $< $@ # this is a dirty hack; TODO: really build to BOOT.bin



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



build/devicetree.dtb: boot/axiom-$(DEVICE)/devicetree.dts
	mkdir -p build/
	dtc -I dts -O dtb -o $@ $<
