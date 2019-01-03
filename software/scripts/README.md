# Scripts
This directory contains different unserspace tools for interacting with the hardware of the camera.


## *.func
bash includes


## *_init.sh 
are initialisation scripts


## gpio.py
Is a script to initialize ("init" as argument) power board GPIOs and display their states (no arguments).


## mxo2.py
is a library for Lattice MACH XO2 FPGA related stuff


## *_pll.sh
are used to reconfigure the FPGA PLL - was an attempt to allow switching between 30/60 Hz video output without changing Zynq bitstream - did not work reliably


## Programming PIC (2 microcontrollers: PIC16F1718) on the Mainboard
Both PICs have their programming interfaces connected via the I2C bus. The programming protocoll is ICSP.
To set a PIC into programming mode the reset (MCLR# - separate lanes) needs to be triggered (*mclr_*.sh* scripts) followed by a programming sequence. 
For this there are the *icsp_** scripts and the ICSP FPGA bitstream (*icsp.bit*) running over I2C and UART.
Over UART commands can be sent to the PICs eg. to program the PIC but also to switch between I2C and ICSP.
The PICs can be turn off (shut down of current) individually throught the GPIO extenders allowing to also program any PIC selectively in case it behaves unexpectedly. Once the PIC is programmed it has an I2C interface containing JTAG microcode i.e. it can output bit sequences that are JTAG compatible - this is utilized by the *pic_jtag_** scripts together with *jtag.py* (JTAG state engine).

The most important icsp_ commands/scripts are:

**icsp_id.py** (identify pic by reading hdid/config)

**icsp_uid.py** for the user ID of a PIC

**icsp_prog.py** to program a PIC with a hex files

**icsp_echo.py** to test the ICSP UART interfaces

**icsp_dump.py** to read/dump hex file from a PIC

**rf_sel.py** to select one of the PICs


## Programming Lattice FPGAs (2x LCMXO2-1200HC-6TG100C) on the Mainboard
Each PIC (see above) is connected to one Lattice FPGA. The JTAG interface as described above is required to programm the FPGAs.

The following scripts are relevant in this regard:

**pic_jtag_id** read FPGA IDs

**pic_jtag_erase** erase FPGAs

**pic_jtag_prog** program FPGAs

**pic_jtag_dump** flash dump of the FPGAs

**pic_jtag_feat** program FPGA feature bits - dangerous!

**pic_jtag_extest** FPGA pin matrix test

**pic_jtag_shld/pcie/cso** scripts are extest GPIO for the corresponding lanes

**power_init/on/off** turn the power board GPIOs on/off or initialize them

**power_sensor_off.sh** and **power_vio.sh** deal with specific power related GPIO

The **prep_*** scripts are helpers to create a predefined environment for testing:

**prep_icsp.sh** prepares everything for ICPS related tasks

**prep_extest.sh** prepares everything for FPGA extest matrix tests related tasks 

**prep_chkpin.sh** prepares everything for I/O loopback tests

**rf_*** scripts are for 'routing fabric' selection


## *_conf scripts/tools 
are used to modify memory registers in the FPGA (LUTs, Color Matrix, etc)


**svf2cfg.gawk & svf2ufm.gawk** 
are required to convert the Lattice .svf format into: .cfg and .ufm files (those files are used to pogram a Lattice FPGA - careful as the total programming cycles are limited). A future goal is to have a basic programm in Lattice FPGA flash only and read the active bitstream into the Lattice SRAM.


## pac1720_info.sh
outputs an overview of power sensing values on all rails 


## zynq_info.sh
display all kinds of analog values from the Zynq (temperatures, etc.)


## rectest.sh 
is a script used to initialize the experimental 4k raw mode


## rgbhsv.sh 
was a matrix conversion script (outdated?)


## ingmar.sh 
are the cmv12000 register settings as benchmarked by Ingmar


## kick.sh and halt.sh 
are the scripts called by the cmv12k.service (to initialize image sensor communication - LVDS training - and video stream output) on boot up


## kick_manual.sh and halt_manual.sh
are the scripts called by kick.sh and halt.sh


## Further documentation
Have a look at the [wiki](https://wiki.apertus.org/index.php/AXIOM_Beta/Manual) for more details for some of the scripts.
