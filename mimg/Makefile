.SUFFIXES: .c .o .asm .hex .bin

TARGETS = mimg

all : $(TARGETS)

CC = gcc
STRIP = strip
CFLAGS += -ggdb -Wall -std=gnu99 -O2
LDFLAGS += -lm

install:
	$(STRIP) $(TARGETS)
	cp -va $(TARGETS) /root/

clean:
	rm -f *.o
	rm -f $(TARGETS)
	rm -f *~ *.orig




