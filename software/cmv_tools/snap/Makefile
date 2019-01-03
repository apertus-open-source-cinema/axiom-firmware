
.SUFFIXES: .c .o .asm .hex .bin

TARGETS = snap

all : $(TARGETS)

CC = gcc
STRIP = strip
CFLAGS += -ggdb -Wall -std=gnu99 -O2
LDFLAGS += -lm -lpthread

train.o : train.c cmv_reg.h
snap.o : snap.c cmv_reg.h scn_reg.h
perf.o : perf.c cmv_reg.h scn_reg.h
rcn.o : rcn.c cmv_reg.h scn_reg.h

perf : perf.o
	$(CC) $(CFLAGS) -lrt -o $@ $^

pong : pong.o
	$(CC) $(CFLAGS) -lrt -lm -o $@ $^

snap.static : snap.o
	$(CC) $(CFLAGS) -static $(LDFLAGS) -o $@ $^

hist.static : hist.o
	$(CC) $(CFLAGS) -static $(LDFLAGS) -o $@ $^

lut_conf.static : lut_conf.o
	$(CC) $(CFLAGS) -static -o $@ $^ $(LDFLAGS)

install:
	$(STRIP) $(TARGETS)
	for TARGET in $(TARGETS); do ln -sf $$(pwd)/$$TARGET /opt/axiom/bin/axiom-$$TARGET; done

clean:
	rm -f *.o
	rm -f $(TARGETS)
	rm -f *~ *.orig

# launching multiple copies of snap should just work
# without locking up the entire system
# (it should capture 3 images, in any order, without conflicts)
snap_sem_test:
	. /root/cmv.func; fil_reg 15 0
	for i in `seq 100`; do \
		./snap -2 -b -e 1ms -z & \
		./snap -2 -b -e 10ms -z & \
		./snap -2 -b -e 100ms -z ; \
		wait; \
	done

snap_asm: snap.o
	objdump -d -M reg-names-raw --section=.dump_asm snap.o

# 	block normal .c -> .o
# %.o : %.c

