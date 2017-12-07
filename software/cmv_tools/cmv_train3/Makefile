
.SUFFIXES: .c .o .asm .hex .bin

TARGETS = cmv_train3 

all : $(TARGETS)

CC = gcc
STRIP = strip
CFLAGS += -ggdb -Wall -std=gnu99 -O2
LDFLAGS += -lm

cmv_train3.o : cmv_train3.c cmv_reg.h

install:
	$(STRIP) $(TARGETS)
	for TARGET in $(TARGETS); do ln -sf $$(pwd)/$$TARGET /usr/local/bin/axiom-$$TARGET; done

clean:
	rm -f *.o
	rm -f $(TARGETS)
	rm -f *~ *.orig


