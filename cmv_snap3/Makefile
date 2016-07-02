
.SUFFIXES: .c .o .asm .hex .bin

TARGETS = cmv_train4 cmv_snap3 cmv_train3 cmv_hist3 cmv_perf3 lut_conf3 cmv_rcn3 pmem mimg
TARGETS += cmv_snap3.static cmv_hist3.static lut_conf3.static
TARGETS += smbget pong track paint

all : $(TARGETS)

CC = gcc
STRIP = strip
CFLAGS += -ggdb -Wall -std=gnu99 -O2
LDFLAGS += -lm

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
	cp -va $(TARGETS) /root/

clean:
	rm -f *.o
	rm -f $(TARGETS)
	rm -f *~ *.orig


# 	block normal .c -> .o
# %.o : %.c

