
.SUFFIXES: .c .o .asm .hex .bin

TARGETS = neon_remap

all : $(TARGETS)

CC = gcc
STRIP = strip
CFLAGS += -ggdb -Wall -std=gnu99 -O2 -mfpu=neon
LDFLAGS += -lm -lpthread

install:
	$(STRIP) $(TARGETS)
	for TARGET in $(TARGETS); do ln -sf $$(pwd)/$$TARGET /usr/axiom/bin/axiom_$$TARGET; chmod u+s $$TARGET; done

clean:
	rm -f *.o
	rm -f $(TARGETS)
	rm -f *~ *.orig
