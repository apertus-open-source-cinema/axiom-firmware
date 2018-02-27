.DEFAULT_GOAL := build/axiom.img
DEVICE ?= beta

include assemble.mk
include qemu.mk


# util targets
.PHONY: contaner-shell
build-shell:
	-bash

chroot-shell: build/root.fs/etc/motd
	# really execute the inner steps
	cp -f $$(which qemu-arm-static) build/root.fs/usr/bin
	cp -f $$(which qemu-aarch64-static) build/root.fs/usr/bin

	$(MAKE) -f makefiles/host/main.mk mount

	cat build/root.fs/etc/resolv.conf.bak || readlink -v build/root.fs/etc/resolv.conf > build/root.fs/etc/resolv.conf.bak
	rm -f build/root.fs/etc/resolv.conf
	echo "nameserver 185.121.177.177" > build/root.fs/etc/resolv.conf
	-chroot build/root.fs /bin/bash
	ln -sf $(cat build/root.fs/etc/resolv.conf.bak) build/root.fs/etc/resolv.conf

	$(MAKE) -f makefiles/host/main.mk umount



SD_INDEX = 
SD_INDEX_NULL = 
ifeq ($(DEVICE), beta)
	SD_INDEX = 0
	SD_INDEX_NULL = 1
else
	SD_INDEX = 1
	SD_INDEX_NULL = 0
endif


qemu-shell: build/qemu-xlnx.git/aarch64-softmmu/qemu-system-aarch64 build/devicetree.dtb build/u-boot-xlnx.git/u-boot.elf build/axiom.img
	build/qemu-xlnx.git/aarch64-softmmu/qemu-system-aarch64 -M arm-generic-fdt-7series -machine linux=on -serial /dev/null -serial mon:stdio -nographic -dtb build/devicetree.dtb -kernel build/u-boot-xlnx.git/u-boot.elf -drive if=sd,format=raw,index=$(SD_INDEX),file=build/axiom.img -drive if=sd,format=raw,index=$(SD_INDEX_NULL),file=/dev/null -boot mode=5


# test targets
.PHONY: test
test: build/qemu-xlnx.git/aarch64-softmmu/qemu-system-aarch64 build/devicetree.dtb build/u-boot-xlnx.git/u-boot.elf build/axiom.img makefiles/host/run_qemu.expect
	SD_INDEX=$(SD_INDEX) makefiles/host/run_qemu.expect

.PHONY: ci-test 
ci-test: makefiles/host/run_qemu.expect
	! [ -e build/axiom.img ] && echo "axiom.img missing, maybe you should run 'make' first"
	SD_INDEX=$(SD_INDEX) makefiles/host/run_qemu.expect

# cleaning roules
.PHONY: clean
clean: clean-rootfs

.PHONY: clean-rootfs
clean-rootfs: umount
	rm -r build/root.fs

.PHONY: clean-kernel
clean-kernel:
	(cd build/linux-xlnx.git/; make clean)

.PHONY: clean-u-boot
clean-u-boot:
	(cd build/u-boot-xlnx.git/; make clean)



clean-all:
	rm -rf build/
