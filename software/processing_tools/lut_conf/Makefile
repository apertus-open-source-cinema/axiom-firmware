
.SUFFIXES: .c .o .asm .hex .bin

TARGETS = lut_conf

all : $(TARGETS)

CC = gcc
STRIP = strip
CFLAGS += -ggdb -Wall -std=gnu99 -O2
LDFLAGS += -lm

lut_conf.static : lut_conf.o
	$(CC) $(CFLAGS) -static -o $@ $^ $(LDFLAGS)

install:
	$(STRIP) $(TARGETS)
	for TARGET in $(TARGETS); do ln -sf $$(pwd)/$$TARGET /usr/local/bin/axiom-$$TARGET; chmod u+s $$TARGET; done

clean:
	rm -f *.o
	rm -f $(TARGETS)
	rm -f *~ *.orig
