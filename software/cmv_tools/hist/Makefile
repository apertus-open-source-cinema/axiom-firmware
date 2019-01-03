
.SUFFIXES: .c .o .asm .hex .bin

TARGETS = hist

all : $(TARGETS)

CC = gcc
STRIP = strip
CFLAGS += -ggdb -Wall -std=gnu99 -O2
LDFLAGS += -lm

hist.static : hist.o
	$(CC) $(CFLAGS) -static $(LDFLAGS) -o $@ $^

install:
	$(STRIP) $(TARGETS)
	for TARGET in $(TARGETS); do ln -sf $$(pwd)/$$TARGET /opt/axiom/bin/axiom-$$TARGET; done

clean:
	rm -f *.o
	rm -f $(TARGETS)
	rm -f *~ *.orig

