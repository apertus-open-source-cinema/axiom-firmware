This file lists major or notable changes to the AXIOM Beta Firmware in chronological order (YYYY-MM-DD format). This is not
a complete change list, only those that may directly interest or affect users.


# 2024-04-11

##latest additions are:

* memtool updated to latest version
* latest gateware bin file added (now supports HDMI Data Islands)
* python scripts added to fill HDMI Data Islands with metadata
* added pseudo random number generator tool (prng)
* login via root user now possible
* pvim, pnano, pcat commands added to access scripts and tools without having to care about their location
* axiom_grow_fs.sh added to expand primary partition size to size of microsd card
* hashdeep package replaced with rhash package
* bash-completion added
* axiom_gateware_version.sh script added to output generation date of loaded gateware
* root user ssh login with password now enabled by default

firmware release: fillme


# 2021-11-17

## CHANGES.md file crated, recent additions are:

* snap_neon added: This tool to capture single images on the AXIOM Beta utilizing the Zynq NEON acceleration engine making the process significantly faster.
* HDMI raw output mode added for transfering A&B frames over HDMI at double framerate, documentation on wiki will follow soon. (currently in Google Doc for those interested)
* axiom_start.sh and axiom_halt.sh now warn the user and exit if not executed as root (would before crash the camera)
* mimg and memtool updated to latest versions

Nightly Build:
https://github.com/apertus-open-source-cinema/axiom-firmware/releases/tag/nightly%2F4b9d54a2
