
.SUFFIXES: .c .o .asm .hex .bin

TARGETS = cmv_perf3

all : $(TARGETS)

CC = gcc
STRIP = strip
CFLAGS += -ggdb -Wall -std=gnu99 -O2
LDFLAGS += -lm

cmv_perf3.o : cmv_perf3.c cmv_reg.h scn_reg.h

cmv_perf3 : cmv_perf3.o
	$(CC) $(CFLAGS) -lrt -o $@ $^

install:
	$(STRIP) $(TARGETS)
	for TARGET in $(TARGETS); do ln -sf $$(pwd)/$$TARGET /usr/local/bin/axiom-$$TARGET; chmod u+s $$TARGET; done

clean:
	rm -f *.o
	rm -f $(TARGETS)
	rm -f *~ *.orig



