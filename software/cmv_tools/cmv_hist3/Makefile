
.SUFFIXES: .c .o .asm .hex .bin

TARGETS = cmv_hist3 

all : $(TARGETS)

CC = gcc
STRIP = strip
CFLAGS += -ggdb -Wall -std=gnu99 -O2
LDFLAGS += -lm

cmv_hist3.static : cmv_hist3.o
	$(CC) $(CFLAGS) -static $(LDFLAGS) -o $@ $^

install:
	$(STRIP) $(TARGETS)
	for TARGET in $(TARGETS); do ln -sf $$(pwd)/$$TARGET /usr/local/bin/axiom-$$TARGET; chmod u+s $$TARGET; done

clean:
	rm -f *.o
	rm -f $(TARGETS)
	rm -f *~ *.orig

