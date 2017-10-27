# Axiom Beta Software
[![pipeline status](https://gitlab.com/apertus/beta-software/badges/master/pipeline.svg)](https://gitlab.com/apertus/beta-software/commits/master)

Firmware required to boot & operate the [Apertus Axiom Beta Camera](https://www.apertus.org/axiom-beta).

Detailed instructions on how to use the Firmware can be found in the [wiki](https://wiki.apertus.org/index.php/AXIOM_Beta/AXIOM_Beta_Software)

## Building & hacking around
A great way to start hacking on the Beta Frimware is building it.

The easiest way to build the Axiom Beta Firmware is to download the `gitlab-ci-multi-runner` and do a containerized build. When you have the [gitlab-ci-multi-runner installed](https://docs.gitlab.com/runner/install/) simply run:
```
gitlab-ci-multi-runner exec docker build
```


## Structure of this Repository
The Repository is divided in the following Parts:

### `software/`
Linux user-space tools and scripts used to operate the Axiom Beta hardware.

### `gateware/`
Contains the VHDL sources for the various Programmable Logic devices on the board. (Currently not everything is contained)


### `build_tools/`
Contains all the other stuff that is needed for creating a Beta firmware image.
