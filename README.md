# AXIOM Beta Software
[![pipeline status](https://gitlab.com/apertus/beta-software/badges/master/pipeline.svg)](https://gitlab.com/apertus/beta-software/pipelines/) [![download nightly image](https://img.shields.io/badge/download-nightly%20image-blue.svg)](https://gitlab.com/apertus/beta-software/-/jobs/artifacts/master/download?job=assemble_image) Pull requests: [![Build Status](https://travis-ci.org/apertus-open-source-cinema/beta-software.svg?branch=master)](https://travis-ci.org/apertus-open-source-cinema/beta-software)

Firmware required to boot & operate the [apertus° AXIOM Beta Camera](https://www.apertus.org/axiom-beta).

Detailed instructions on how to use the Firmware can be found in the [wiki](https://wiki.apertus.org/index.php/AXIOM_Beta/AXIOM_Beta_Software)

## Download Nightly Firmware
If you want to experiment with the latest changes and don't mind if the camera stops working, you can try to use the untested nightly firmware images.
```diff
- Warning! The nightly images are not verified by a human and might damage your camera permanently. 
- Only continue, if you know, what you are doing!
```
To try this anyway, you
1. Have to [download etcher](https://etcher.io/) & install it
2. [Download the latest nightly firmware image](https://gitlab.com/apertus/beta-software/-/jobs/artifacts/master/download?job=assemble_image)
3. Select the `.zip` file of the image in etcher and flash it on a MicroSD card with at least 8GB.

## Building & hacking around
A great way to start hacking on the Beta firmware is building it.
Build instructions can be found in the [`makefiles/README.md`](makefiles/README.md) file.
There you will also find instructions for running the firmware inside QEMU for development purposes.

## Structure of this Repository
The repository is divided in the following Parts:

### `software/`
Linux user-space tools and scripts used to operate the AXIOM Beta hardware.

### `gateware/`
Contains the VHDL sources for the various Programmable Logic Devices on the board. (Currently not everything is contained)

### `boot/`
Files needed in the boot process.


### `makefiles/`
Contains all the other stuff that is needed for creating a Beta firmware image.
