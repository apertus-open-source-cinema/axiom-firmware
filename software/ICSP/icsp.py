#!/bin/env python3

# Copyright (C) 2015 Herbert Poetzl


from time import sleep


def icsp_m2i(val):
    return (int(val,16) >> 1) & 0x3FFF

def icsp_i2m(val):
    return "%04X" % ((val & 0x3FFF) << 1)

def icsp_cmd(ser, cmd, rlen=None):
    # print("[%s]" % cmd)
    # FIXME: add CRC
    ser.write(cmd)
    rlen = len(cmd) if rlen == None else rlen
    res = ser.read(rlen)
    # print(res, len(res), rlen);
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
    # print("res=%s" % res)
    return icsp_m2i(res)

def icsp_readn(ser, count=16):
    req = b'[' + b'R?+'*count + b']'
    res = icsp_cmd(ser, req, 4*count)
    return [res[i*4:(i+1)*4] for i in range(count)]

def icsp_read_data(ser, count, block=256):
    data = []
    while count > 0:
        if count > block:
            res = icsp_readn(ser, block)
            count -= block
        else:
            res = icsp_readn(ser, count)
            count = 0
        data.extend(res)
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

def icsp_load_data(ser, data, first=False, config=False):
    icsp_loadn(ser, data, first)

def icsp_load_conf(ser, val, offset=0):
    inc = b'+' * offset
    req = b'[X%s=%s]' % (icsp_i2m(val).encode("ASCII"), inc)
    icsp_cmd(ser, req, 0)

def icsp_iprog(ser, delay=2.5):
    idly = int(delay * 2500)
    icsp_cmd(ser, b'8!%X.' % idly)  # prog and wait
    sleep(delay/1000)

