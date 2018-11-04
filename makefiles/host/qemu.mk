build/qemu-xlnx.git:
	@mkdir -p $(@D)
	git clone --depth 1 https://github.com/Xilinx/qemu.git build/qemu-xlnx.git
	(cd build/qemu-xlnx.git; git submodule update --init dtc)

build/qemu-xlnx.git/aarch64-softmmu/qemu-system-aarch64: build/qemu-xlnx.git
	(cd build/qemu-xlnx.git; ./configure --target-list="aarch64-softmmu" --enable-fdt --disable-kvm --disable-xen)
	(cd build/qemu-xlnx.git; make -j -l $$(nproc))
