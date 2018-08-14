# AXIOM Beta Software

Firmware required to boot & operate the [apertus° AXIOM Beta Camera](https://www.apertus.org/axiom-beta).

Detailed instructions on how to use the Firmware can be found in the [wiki](https://wiki.apertus.org/index.php/AXIOM_Beta/Manual)

## Download Nightly Firmware
If you want to experiment with the latest changes and dont mind, when the camera isnt working, you try use the untested nightly firmware images.
```diff
- Warning! The nightly images are not veryfied by a human and might damage your camera permanently. 
- Only continue, if you know, what you are doing!
```
To try this anyway, you
1. Have to [download etcher](https://etcher.io/) & install it
2. [Download the latest nightly firmware image](https://gitlab.com/apertus/beta-software/-/jobs/artifacts/master/download?job=assemble_image)
3. Select the `.zip` file of the image in etcher and flash it on a microsd card with at least 8GB.

## Building & hacking around
A great way to start hacking on the Beta Frimware is building it.
Build instructions can be found in the [`makefiles/README.md`](makefiles/README.md) file.
There you will also find instructions for running the firmware inside qemu for development purposes.

## Structure of this Repository
The Repository is divided in the following Parts:

### `software/`
Linux user-space tools and scripts used to operate the AXIOM Beta hardware.

### `gateware/`
Contains the VHDL sources for the various Programmable Logic devices on the board. (Currently not everything is contained)

### `boot/`
Files needed in the boot process.


### `makefiles/`
Contains all the other stuff that is needed for creating a Beta firmware image.
