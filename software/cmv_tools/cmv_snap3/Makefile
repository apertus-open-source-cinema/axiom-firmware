
.SUFFIXES: .c .o .asm .hex .bin

TARGETS = cmv_snap3

all : $(TARGETS)

CC = gcc
STRIP = strip
CFLAGS += -ggdb -Wall -std=gnu99 -O2
LDFLAGS += -lm -lpthread

cmv_train3.o : cmv_train3.c cmv_reg.h
cmv_snap3.o : cmv_snap3.c cmv_reg.h scn_reg.h
cmv_perf3.o : cmv_perf3.c cmv_reg.h scn_reg.h
cmv_rcn3.o : cmv_rcn3.c cmv_reg.h scn_reg.h

cmv_perf3 : cmv_perf3.o
	$(CC) $(CFLAGS) -lrt -o $@ $^

pong : pong.o
	$(CC) $(CFLAGS) -lrt -lm -o $@ $^

cmv_snap3.static : cmv_snap3.o
	$(CC) $(CFLAGS) -static $(LDFLAGS) -o $@ $^

cmv_hist3.static : cmv_hist3.o
	$(CC) $(CFLAGS) -static $(LDFLAGS) -o $@ $^

lut_conf3.static : lut_conf3.o
	$(CC) $(CFLAGS) -static -o $@ $^ $(LDFLAGS)

install:
	$(STRIP) $(TARGETS)
	for TARGET in $(TARGETS); do ln -sf $$(pwd)/$$TARGET /usr/local/bin/axiom-$$TARGET; chmod u+s $$TARGET; done

clean:
	rm -f *.o
	rm -f $(TARGETS)
	rm -f *~ *.orig

# launching multiple copies of cmv_snap3 should just work
# without locking up the entire system
# (it should capture 3 images, in any order, without conflicts)
cmv_snap3_sem_test:
	. /root/cmv.func; fil_reg 15 0
	for i in `seq 100`; do \
		./cmv_snap3 -2 -b -e 1ms -z & \
		./cmv_snap3 -2 -b -e 10ms -z & \
		./cmv_snap3 -2 -b -e 100ms -z ; \
		wait; \
	done

cmv_snap3_asm: cmv_snap3.o
	objdump -d -M reg-names-raw --section=.dump_asm cmv_snap3.o

# 	block normal .c -> .o
# %.o : %.c

