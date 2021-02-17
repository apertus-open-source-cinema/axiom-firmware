
.SUFFIXES: .c .o .asm .hex .bin


all : i2c_slave.hex 

SDFLAGS = --use-non-free -mpic14 -ppic16f1718 --opt-code-speed --fverbose-asm -Wl-C

clean:
	rm -f *.o
	rm -f *.cof *.cod 
	rm -f *.lst *.map
	rm -f *.hex
	rm -f *.bin
	rm -f *.asm
	rm -f *~ *.orig

# 	block normal .c -> .o
%.o : %.c

%.asm : %.c
	sdcc $(SDFLAGS) -c $< |& ./cc.sh

%.o : %.asm
	gpasm -c $< |& ./cc.sh
	@./stat.sh $@

%.bin : %.hex
	objcopy -I ihex -O binary $< $@

%.hex : %.c
	sdcc $(SDFLAGS) $< |& ./cc.sh
	@./stat.sh $*.o

