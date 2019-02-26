# makefiles
This directory contains tools for building and testing the main firmware image, that gets put on the sdcard.

The `host/` and `in_chroot/` directories separate those scripts, that are run inside a chroot of the axiom firmware, and those, that run on the host build machine. For example the kernel build and the image assembly are done by scripts in the `host/` directory, while the build of the tools is done `in_chroot/`.

Generally the build currently consists of 2 build stages and one test stage:
1. Build the file trees of the Partitions
    1. bootfs (partition 1) including kernel u-boot and first stage bootloader
    2. extract the archlinux rootfs and run the `in_chroot/` scripts in a chroot of the rootfs
2. assemble the file trees to an image
3. test the image using qemu.

## Build It!
The `docker-make.sh` script allows us to run the build scripts inside docker and manage
all the build dependencies.

Assuming that you have cloned this repository and all its submodules, have docker installed and can run docker as your current user, simply type
```
makefiles/docker-make.sh

```

```diff
- Warning!
- This Project uses submodules! when you clone without --recursive the build will fail!
```

The script will create a docker container and run the makefiles inside it.
This will result in the finished camera image with path `build/axiom.img`.

You can also run other targets, defined in the makefile, with `docker-make.sh`. You can for example
run:
* `docker-make.sh build-shell` to get a root shell inside the build container
* `docker-make.sh chroot-shell` to get a root shell inide a chroot of the camera
* `docker-make.sh qemu-shell` to boot the camera image inside qemu. currently the network is not working.
* `docker-make.sh test` to run automated tests of the image inside qemu.

### Rebuild
To run the build process again you need to first remove the current build files to start with a clean system: 
```
makefiles/docker-make.sh clean
makefiles/docker-make.sh clean-all
```
Then again follow the above build instructions.

## Customize it!
If you want to customize your image you can create a `overlay/` folder in the root of this repo.
An install.sh in this directory will be executed in a chroot of the camera. All the other contents 
will be copied to the `/` of the camera.

This is especially usefull for adding your ssh keys to the camera or to install your preffered tools
(ie. gnu/emacs).
