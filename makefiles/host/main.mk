include config.mk

.DEFAULT_GOAL := build/$(IMAGE)

include assemble.mk
include qemu.mk


# util targets
.PHONY: build-shell
build-shell:
	-bash

.PHONY: chroot-shell
chroot-shell: build/root.fs/.install_stamp
	./makefiles/host/run_in_chroot.sh /bin/bash

.PHONY: qemu-shell
qemu-shell: $(QEMU_SOURCE)/aarch64-softmmu/qemu-system-aarch64 build/boot.fs/devicetree.dtb $(UBOOT_SOURCE)/u-boot.elf build/$(IMAGE)
	$(QEMU_SOURCE)/aarch64-softmmu/qemu-system-aarch64 -M arm-generic-fdt-7series -machine linux=on -serial /dev/null -serial mon:stdio -nographic -dtb build/boot.fs/devicetree.dtb -kernel $(UBOOT_SOURCE)/u-boot.elf -drive if=sd,format=raw,index=0,file=build/$(IMAGE) -boot mode=5

# test targets
.PHONY: test
test: $(QEMU_SOURCE)/aarch64-softmmu/qemu-system-aarch64 build/boot.fs/devicetree.dtb $(UBOOT_SOURCE)/u-boot.elf build/$(IMAGE) makefiles/host/run_qemu.expect
	QEMU_SOURCE=$(QEMU_SOURCE) IMAGE=$(IMAGE) makefiles/host/run_qemu.expect

# cleaning rules
clean: clean-rootfs clean-kernel clean-u-boot clean-qemu

.PHONY: clean-rootfs
clean-rootfs:
	rm -r build/root.fs/

.PHONY: clean-bootfs
clean-bootfs:
	rm -r build/boot.fs/

.PHONY: clean-kernel
clean-kernel:
	+$(KERNEL_MAKE) clean

.PHONY: clean-u-boot
clean-u-boot:
	+$(UBOOT_MAKE) clean

.PHONY: clean-qemu
clean-qemu:
	+$(QEMU_MAKE) clean

mrproper: clean-all

.PHONY: clean-all
clean-all:
	rm -rf build/
