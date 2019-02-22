# AXIOM Beta Software
[![Build Status](https://api.cirrus-ci.com/github/apertus-open-source-cinema/axiom-beta-firmware.svg?branch=master)](https://cirrus-ci.com/github/apertus-open-source-cinema/axiom-beta-firmware)
[![download nightly image](https://img.shields.io/badge/download-nightly%20image-blue.svg)](INSTALL.md)


Firmware required to boot & operate the [apertus° AXIOM Beta Camera](https://www.apertus.org/axiom-beta).  
Detailed instructions on how to use the Firmware & operate the camera can be found in the [wiki](https://wiki.apertus.org/index.php/AXIOM_Beta/Manual)

## Download Nightly Firmware
If you want to experiment with the latest changes and don't mind if the camera isn't working, you can [try to use the untested nightly firmware images](INSTALL.md).

## Building & hacking around
A great way to start hacking on the Beta Firmware is by building it.
Build instructions can be found in the [`makefiles/README.md`](makefiles/README.md) file.
There you will also find instructions to run the firmware inside qemu for development purposes.

## Structure of this Repository
The Repository is divided in the following parts:

### `software/`
Linux user-space tools and scripts used to operate the AXIOM Beta hardware.

### `peripherals/soc_main/`
Contains the VHDL sources for the various Programmable Logic Devices on the board. (Currently not everything is contained)

### `boot/`
Files needed in the boot process.


### `makefiles/`
Contains all the other stuff that is needed for creating a Beta Firmware image.
