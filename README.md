# Axiom Beta Software
[![pipeline status](https://gitlab.com/apertus/beta-software/badges/master/pipeline.svg)](https://gitlab.com/apertus/beta-software/pipelines/)

Firmware required to boot & operate the [Apertus Axiom Beta Camera](https://www.apertus.org/axiom-beta).

Detailed instructions on how to use the Firmware can be found in the [wiki](https://wiki.apertus.org/index.php/AXIOM_Beta/AXIOM_Beta_Software)

## Building & hacking around
A great way to start hacking on the Beta Frimware is building it.
Build instructions can be found in the [`build_tools/README.md`](build_tools/README.md) file

## Structure of this Repository
The Repository is divided in the following Parts:

### `software/`
Linux user-space tools and scripts used to operate the Axiom Beta hardware.

### `gateware/`
Contains the VHDL sources for the various Programmable Logic devices on the board. (Currently not everything is contained)


### `build_tools/`
Contains all the other stuff that is needed for creating a Beta firmware image.
