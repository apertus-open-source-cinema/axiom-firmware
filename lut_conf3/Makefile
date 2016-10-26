
.SUFFIXES: .c .o .asm .hex .bin

TARGETS = lut_conf3

all : $(TARGETS)

CC = gcc
STRIP = strip
CFLAGS += -ggdb -Wall -std=gnu99 -O2
LDFLAGS += -lm

lut_conf3.static : lut_conf3.o
	$(CC) $(CFLAGS) -static -o $@ $^ $(LDFLAGS)

install:
	$(STRIP) $(TARGETS)
	cp -va $(TARGETS) /root/

clean:
	rm -f *.o
	rm -f $(TARGETS)
	rm -f *~ *.orig


