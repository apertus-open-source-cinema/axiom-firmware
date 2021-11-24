#!/bin/env python3

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

from time import sleep


def ser_read(ser, rlen):
    res = ser.read(rlen)
    cnt = 0
    while len(res) < rlen:
        # print("%d/%d " % (len(res), rlen))
        ser.write(b' ')
        cnt += 1
        res += ser.read(rlen - len(res))
    while cnt > 0:
        ser.read(1)
        cnt -= 1
    # print(res)
    return res

def icsp_m2i(val):
    return (int(val,16) >> 1) & 0x3FFF

def icsp_i2m(val):
    return "%04X" % ((val & 0x3FFF) << 1)

def icsp_i2p(val):
    return "%06X" % ((val & 0x3FFFFF) << 1)

def icsp_cmd(ser, cmd, rlen=None):
    # print("%s" % cmd)
    # FIXME: add CRC
    rlen = len(cmd) if rlen == None else rlen
    while len(cmd) > 0:
        scmd, cmd = cmd[:32], cmd[32:]
        # print(">%s< >%s<" % (scmd, cmd))
        ser.write(scmd)
    res = ser_read(ser, rlen)
    if len(res) != rlen:
        print("[%s] %d/%d = %s" % (cmd, len(res), rlen, res));
    # fixme, update crc
    return res

def icsp_addr(ser, addr):
    icsp_cmd(ser, b'[16!]', 0)      # reset address
    req = b'[' + b'+'*addr + b']'
    icsp_cmd(ser, req, 0)           # advance

def icsp_read(ser, postinc=True):
    if postinc:
        res = icsp_cmd(ser, b'[R?+]', 4)
    else:
        res = icsp_cmd(ser, b'[R?]', 4)
    print("res=%s" % res)
    return icsp_m2i(res)

def icsp_readn(ser, count=16):
    req = b'[' + b'R?+'*count + b']'
    res = icsp_cmd(ser, req, 4*count)
    return [res[i*4:(i+1)*4] for i in range(count)]

def icsp_read_data(ser, count, block=16):
    data = []
    while count > 0:
        if count > block:
            res = icsp_readn(ser, block)
            count -= block
        else:
            res = icsp_readn(ser, count)
            count = 0
        data.extend(res)
        # sleep(0.1)
    return [icsp_m2i(_) for _ in data]
    
def icsp_load(ser, val, first=False):
    inc = b'' if first else b'+'
    req = b'[%sW%s=]' % (inc, icsp_i2m(val))
    icsp_cmd(ser, req, 0)

def icsp_loadn(ser, vals, first=False):
    req = b'['
    inc = b'' if first else b'+'
    for val in vals:
        req += b'%sW%s=' % (inc, icsp_i2m(val).encode("ASCII"))
        inc = b'+'
    req += b']'
    icsp_cmd(ser, req, 0)

def icsp_enter_lvp(ser):
    req = b'[^]'
    icsp_cmd(ser, req, 0)

def icsp_advance(ser, offset=0):
    inc = b'+' * offset
    req = b'[%s]' % (inc)
    icsp_cmd(ser, req, 0)

def icsp_load_data(ser, val=0, offset=0):
    inc = b'+' * offset
    req = b'[%sW%s=]' % (inc, icsp_i2m(val).encode("ASCII"))
    icsp_cmd(ser, req, 0)

def icsp_load_conf(ser, val=0, offset=0):
    inc = b'+' * offset
    req = b'[X%s=%s]' % (icsp_i2m(val).encode("ASCII"), inc)
    icsp_cmd(ser, req, 0)

def icsp_iprog(ser, delay=2.5):
    idly = int(delay * 2500)
    icsp_cmd(ser, b'[8!%X.]' % idly, 0)     # prog and wait
    sleep(delay/1000)

def icsp_bulk_erase(ser, delay=5.0):
    idly = int(delay * 2500)
    icsp_cmd(ser, b'[9!%X.]' % idly, 0)     # erase and wait
    sleep(delay/1000)

def icsp_row_erase(ser, delay=2.5):
    idly = int(delay * 2500)
    icsp_cmd(ser, b'[11!%X.]' % idly, 0)    # erase and wait
    sleep(delay/1000)
    
def icsp_reset_addr(ser):
    icsp_cmd(ser, b'[16!]', 0)

