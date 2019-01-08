
.SUFFIXES: .c .o .asm .hex .bin

TARGETS = perf

all : $(TARGETS)

CC = gcc
STRIP = strip
CFLAGS += -ggdb -Wall -std=gnu99 -O2
LDFLAGS += -lm

perf.o : perf.c cmv_reg.h scn_reg.h

perf : perf.o
	$(CC) $(CFLAGS) -lrt -o $@ $^

install:
	$(STRIP) $(TARGETS)
	for TARGET in $(TARGETS); do ln -sf $$(pwd)/$$TARGET /usr/axiom/bin/axiom-$$TARGET; chmod u+s $$TARGET; done

clean:
	rm -f *.o
	rm -f $(TARGETS)
	rm -f *~ *.orig



