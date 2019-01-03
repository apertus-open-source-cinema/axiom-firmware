# Scripts
This directory contains different unserspace tools for interacting with the hardware of the camera.


## *.func
bash includes


## *_init.sh 
are initialisation scripts


## gpio.py
Is a script to initialize ("init" as argument) power board GPIOs and display their states (no arguments).


## Programming PIC (2 microcontrollers: PIC16F1718) on the Mainboard
Both PICs have their programming interfaces connected via the I2C bus. The programming protocoll is ICSP.
To set a PIC into programming mode the reset (MCLR# - separate lanes) needs to be triggered followed by a programming sequence. 
For this there are the icsp_* scripts and the ICSP FPGA bitstream (icsp.bit) running over I2C and UART.
Over UART commands can be sent to the PICs eg. to program the PIC but also to switch between I2C and ICSP.
The PICs can be turn off (shut down of current) individually throught the GPIO extenders allowing to also program any PIC selectively in case it behaves unexpectedly.

The most important icsp_ commands/scripts are:

**icsp_id.py** (identify pic by reading hdid/config)

**icsp_uid.py** for the user ID of a PIC

**icsp_prog.py** to program a PIC with a hex files

**icsp_echo.py** to test the ICSP UART interfaces

**icsp_dump.py** to read/dump hex file from a PIC

**rf_sel.py** to select one of the PICs


## *_conf scripts/tools 
are used to modify memory registers in the FPGA (LUTs, Color Matrix, etc)


## Further documentation
Have a look at the [wiki](https://wiki.apertus.org/index.php/AXIOM_Beta/Manual) for more details for some of the scripts.
