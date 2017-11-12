.SUFFIXES: .c .o .asm .hex .bin

TARGETS = mimg

all : $(TARGETS)

CC = $(CROSS_COMPILE)gcc
STRIP = strip
CFLAGS += -ggdb -Wall -std=gnu99 -O2
LDLIBS += -lm

install:
	$(STRIP) $(TARGETS)
	for TARGET in $(TARGETS); do ln -sf $(pwd)/$$TARGET /usr/local/bin/axiom-$$TARGET; done
	ln -sf $(pwd)/overlays/ /opt/overlays

clean:
	rm -f *.o
	rm -f $(TARGETS)
	rm -f *~ *.orig




