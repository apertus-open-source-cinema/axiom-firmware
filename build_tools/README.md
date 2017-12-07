# build_tools
This directory contains tools for building the main firmware image, that gets put on the sdcard.

The `inner/` and `outer/` directories seperate those scripts, that are run inside a chroot of the beta firmware, and those, that run on the host build machine. For example the kernel build ant the image assembly are done by scripts in the `outside/` directory, while the build of the tools is done `inside/` the chroot.

Generally the build currently consists of 2 build stages and one test stage:
1. Build the Filetrees of the Partitions
    1. bootfs (partition 1) 
    2. extract the archlinux rootfs and run the `inside/` scripts in a chroot of the rootfs
2. assemble the file trees to an image
3. test the image using qemu. Therfore, you first need to build qemu with `build_tools/outside/build_qemu.sh` and then run it with `(cd build/ && qemu-xlnx.git/aarch64-softmmu/qemu-system-aarch64 -M arm-generic-fdt-7series -machine linux=on -serial /dev/null -serial mon:stdio -nographic -dtb BOOT.fs/devicetree.dtb -kernel BOOT.fs/BOOT.bin -drive if=sd,format=raw,index=0,file=IMAGE.dd -boot mode=5 -append "root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4")`. You could also run `(cd build/ && ../build_tools/outside/run_qemu.expect)` to have a fully automated rough testing process with qemu.

## Build It!
### ... with docker
The build scripts are intendet to be run inside a docker container with `ubuntu:17.04` and the dependencies in the `dependencies.txt` file installed. 

First you have to get a shell in your docker container:
```
docker run -it --privileged ubuntu:17.04 /bin/bash
```
After this, install git and clone this repo inside the container:
```
apt get update && apt install -y git
git clone https://github.com/apertus-open-source-cinema/beta-software
cd beta-software
```
Then install the missing dependencies and start the build process:
```
build_tools/full_build_ubuntu.sh
```


### ... without containerisation
The preffered and tested build environment is Ubuntu 17.04.
Other Ubuntu installations should work as well, as long as they are new enough that `mke2fs` has a `-d` option (Ubuntu 16.04 and below dont work).

To run the build, follow instructions of the docker section without creating the container.

## Test It!
Assuming you have already build the Image and have a `build/` directory, you can follow the following steps:
- Build Qemu: `build_tools/outside/build_qemu.sh`
- Run Qemu: `(cd build/ && qemu-xlnx.git/aarch64-softmmu/qemu-system-aarch64 -M arm-generic-fdt-7series -machine linux=on -serial /dev/null -serial mon:stdio -nographic -dtb BOOT.fs/devicetree.dtb -kernel BOOT.fs/BOOT.bin -drive if=sd,format=raw,index=0,file=IMAGE.dd -boot mode=5 -append "root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4")`
- Alternatively you can use the automated test (which only checks for very basic funcionality): `(cd build/ && ../build_tools/outside/run_qemu.expect)`