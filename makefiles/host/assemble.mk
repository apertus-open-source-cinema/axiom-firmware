# This makefile creates images for the Apertus AXIOM cameras

include rootfs.mk
include bootfs.mk

# define the layout of the image
BLKOFFS = (8)
BLKSIZE = (2*1024*1024*2)
BLKBOOT = (50*1024*2)
BLKROOT = ($(BLKSIZE) - $(BLKBOOT) - $(BLKOFFS))
BLKSEEK = ($(BLKSIZE) - 1)
BLKOFF2 = ($(BLKOFFS) + $(BLKBOOT))


.ONESHELL:
build/axiom.img: build/boot.part build/root.part
	echo "building image for AXIOM $(DEVICE)"

	# create the image file
	rm -rf $@
	dd if=/dev/zero of=$@ bs=512 seek=$$(echo "$(BLKSEEK)" | bc) count=1

	# write the partition table
	sfdisk -uS $@ << EOF
		part1 : start= $$(echo "$(BLKOFFS)" | bc), size= $$(echo "$(BLKBOOT)" | bc), Id=  c
		part2 : start= $$(echo "$(BLKOFF2)" | bc), size= $$(echo "$(BLKROOT)" | bc), Id= 83
		part3 : start=        0, size=        0, Id=  0
		part4 : start=        0, size=        0, Id=  0
	EOF

	# assamble the partitions into the full image
	dd if=build/boot.part of=$@ bs=512 seek=$$(echo "$(BLKOFFS)" | bc) count=$$(echo "$(BLKBOOT)" | bc) conv=sparse,notrunc
	dd if=build/root.part of=$@ bs=512 seek=$$(echo "$(BLKOFF2)" | bc) count=$$(echo "$(BLKROOT)" | bc) conv=sparse,notrunc


build/boot.part: build/boot.fs/BOOT.bin
	rm -f build/boot.part
	dd if=/dev/zero of=build/boot.part bs=512 seek=$$(echo "$(BLKBOOT) - 1" | bc) count=1
	mkfs.vfat -n "BOOT" -F 32 build/boot.part $$(echo "$(BLKBOOT) / 2" | bc)
	mcopy -i build/boot.part build/boot.fs/* ::

build/root.part: build/root.fs/etc/motd build/linux-xlnx.git/arch/arm/boot/zImage
	rsync -aK build/kernel_modules.fs/ build/root.fs
	rm -f build/root.part
	echo $$(echo "$(BLKROOT) - 1" | bc)
	echo $$(echo "$(BLKROOT) / 2" | bc)
	dd if=/dev/zero of=build/root.part bs=512 seek=$$(echo "$(BLKROOT) - 1" | bc) count=1
	mkfs.ext4 -d build/root.fs build/root.part $$(echo "$(BLKROOT) / 2" | bc)
