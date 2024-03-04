
.SUFFIXES: .c .o .asm .hex .bin

TARGETS = prng

all : $(TARGETS)

CC = gcc
STRIP = strip
CFLAGS += -Wall -std=gnu99 -O3

install:
	$(STRIP) $(TARGETS)
	for TARGET in $(TARGETS); do ln -sf $$(pwd)/$$TARGET /usr/bin/$$TARGET; chmod u+s $$TARGET; done

clean:
	rm -f *.o
	rm -f $(TARGETS)
	rm -f *~ *.orig
