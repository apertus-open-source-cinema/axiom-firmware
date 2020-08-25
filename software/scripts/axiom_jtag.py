#!/bin/env python3

# Copyright (C) 2015-2016 Herbert Poetzl

from smbus import SMBus
from time import sleep
from bitarray import bitarray
from itertools import product

def leba(bits):
    return bitarray(bits, endian='little')

def crev(bits, cond):
    return bits[::-1] if cond else bits

def bit_split(bits):
    total = bits.length()
    data, mod, val = [], total % 8, 0
    for p in range(0, total, 8):
        seq = bits[p:min(p+8, total)]
        val = ord(seq.tobytes())
        if total - p > 8:
            data.append(val)
    return data, mod, val

def bit_combine(data, mod, val):
    total = len(data) * 8 + (mod if mod > 0 else 8)
    cval = (val << ((8 - mod) % 8)) & 0xFF
    bits = bitarray(endian='big')
    bits.frombytes(bytes(data + [cval]))
    bits = bits[:total]
    bits.reverse()
    return bits


def jtag_on(i2c, base):
    trisc = i2c.read_byte(base + 0x28) 
    trisc = (trisc & ~0x4F) | 0x01
    i2c.write_byte(base + 0x28, trisc)
    latc = i2c.read_byte(base + 0x29)
    latc = (latc & ~0x4F) | 0x40
    i2c.write_byte(base + 0x29, latc)
    pupc = i2c.read_byte(base + 0x2A)
    pupc = (pupc & ~0x4F) | 0x01
    i2c.write_byte(base + 0x2A, pupc)
    
def jtag_off(i2c, base):
    trisc = i2c.read_byte(base + 0x28) 
    trisc = (trisc & ~0x4F) | 0x4F
    i2c.write_byte(base + 0x28, trisc)
    latc = i2c.read_byte(base + 0x29)
    latc = (latc & ~0x4F) | 0x00
    i2c.write_byte(base + 0x29, latc)
    pupc = i2c.read_byte(base + 0x2A)
    pupc = (pupc & ~0x4F) | 0x4F
    i2c.write_byte(base + 0x2A, pupc)
    

def jtag_seq(i2c, base, addr, data, mod, val):
    norm, last = base + addr[0], base + addr[1]

    while len(data) > 0:
        car, cdr, data = data[0], data[1:16], data[16:]
        if len(cdr) > 0:
            i2c.write_i2c_block_data(norm, car, cdr)
        else:
            i2c.write_byte(norm, car) 

    if mod > 0:
        i2c.write_i2c_block_data(last + 1, mod, [val])
    else:
        i2c.write_byte(last, val)

def jtag_rseq(i2c, base, addr, count):
    norm, last = base + addr[0], base + addr[1]
    data, mod = [], count % 8

    while count > 8:
        data.append(i2c.read_byte(norm))
        count -= 8

    if mod > 0:
        val = i2c.read_byte_data(last + 1, count)
    else:
        val = i2c.read_byte(last)
    return data, mod, val

def jtag_sseq(i2c, base, addr, data, mod, val):
    norm, last = base + addr[0], base + addr[1]
    res = []

    while len(data) > 0:
        car, data = data[0], data[1:]
        i2c.write_byte(norm, car)
        res.append(i2c.read_byte(norm))

    if mod > 0:
        i2c.write_i2c_block_data(last + 1, mod, [val])
        val = i2c.read_byte_data(last + 1, mod)
    else:
        i2c.write_byte(last, val)
        val = i2c.read_byte(last)
    return res, mod, val
    
        
def jtag_tms(i2c, base, bits):
    data, mod, val = bit_split(leba(bits))
    jtag_seq(i2c, base, [0x02, 0x02], data, mod, val)
    #for bit in bits:
    #    print("(%c,0) -> X" % bit)
    #print("---")

def jtag_tds(i2c, base, bits, exit=True):
    data, mod, val = bit_split(leba(bits))
    last = 0x04 if exit else 0x08
    data, mod, val = jtag_sseq(i2c, base, [0x08, last], data, mod, val)
    return bit_combine(data, mod, val).to01()

def jtag_tdi(i2c, base, bits, exit=True):
    data, mod, val = bit_split(leba(bits))
    last = 0x06 if exit else 0x0A
    jtag_seq(i2c, base, [0x0A, last], data, mod, val)
    #for bit in bits[:-1]:
    #    print("(0,%c) -> X" % bit)
    #print("(%c,%c) -> X" % ('1' if exit else '0', bits[-1]))
    #print("---")

def jtag_tdo(i2c, base, count, exit=True):
    last = 0x06 if exit else 0x1A
    data, mod, val = jtag_rseq(i2c, base, [0x0A, last], count)
    bits = bit_combine(data, mod, val).to01()
    #for bit in bits[:-1]:
    #    print("(0,0) -> %c" % bit)
    #print("(%c,0) -> %c" % ('1' if exit else '0', bits[-1]))
    #print("---")
    return bits


class JTag:
    UNKNOWN             = "UNKNOWN"
    TEST_LOGIC_RESET    = "RESET"
    RUN_TEST_IDLE       = "IDLE"
    SELECT_DR_SCAN      = "DRSELECT"
    CAPTURE_DR          = "DRCAPTURE"
    SHIFT_DR            = "DRSHIFT"
    EXIT_1_DR           = "DREXIT1"
    PAUSE_DR            = "DRPAUSE"
    EXIT_2_DR           = "DREXIT2"
    UPDATE_DR           = "DRUPDATE"
    SELECT_IR_SCAN      = "IRSELECT"
    CAPTURE_IR          = "IRCAPTURE"
    SHIFT_IR            = "IRSHIFT"
    EXIT_1_IR           = "IREXIT1"
    PAUSE_IR            = "IRPAUSE"
    EXIT_2_IR           = "IREXIT2"
    UPDATE_IR           = "IRUPDATE"

    TR0 = [
        (TEST_LOGIC_RESET, RUN_TEST_IDLE),
        (SELECT_DR_SCAN, CAPTURE_DR, SHIFT_DR),
        (EXIT_1_DR, PAUSE_DR), (EXIT_2_DR, SHIFT_DR),
        (UPDATE_DR, RUN_TEST_IDLE),
        (SELECT_IR_SCAN, CAPTURE_IR, SHIFT_IR),
        (EXIT_1_IR, PAUSE_IR), (EXIT_2_IR, SHIFT_IR),
        (UPDATE_IR, RUN_TEST_IDLE) ]
    TR1 = [
        (RUN_TEST_IDLE, SELECT_DR_SCAN, SELECT_IR_SCAN, 
         TEST_LOGIC_RESET, TEST_LOGIC_RESET),
        (CAPTURE_DR, EXIT_1_DR, UPDATE_DR, SELECT_DR_SCAN),
        (CAPTURE_IR, EXIT_1_IR, UPDATE_IR, SELECT_DR_SCAN),
        (SHIFT_DR, EXIT_1_DR), (SHIFT_IR, EXIT_1_IR),
        (PAUSE_DR, EXIT_2_DR, UPDATE_DR),
        (PAUSE_IR, EXIT_2_IR, UPDATE_IR) ]

    TR = {(UNKNOWN, TEST_LOGIC_RESET):"11111"}
    STR = {}
    ST = []


    def __init__(self, i2c, le=True, base=0x40, debug=False):
        self.i2c = i2c
        self.base = base
        self.le = le
        self.state = JTag.UNKNOWN
        self.debug = debug

        for chain in JTag.TR0:
            for pair in zip(chain[:-1], chain[1:]):
                JTag.TR.update({pair:"0"})
            JTag.TR.update({(chain[-1:])*2:"0"})
        for chain in JTag.TR1:
            for pair in zip(chain[:-1], chain[1:]):
                JTag.TR.update({pair:"1"})
        JTag.ST = set([e for t in JTag.TR for e in t])
        for pair, bit in JTag.TR.items():
            JTag.STR.update({(pair[0], bit):pair[1]})

    def on(self):
        jtag_on(self.i2c, self.base)

    def off(self):
        jtag_off(self.i2c, self.base)

    def tmsseq(self, pair):
        for n in range(1, 8):
            if pair in JTag.TR:
                break
            seqs = ["".join(_) for _ in product("01", repeat=n)]
            for seq in seqs:
                s = pair[0]
                for bit in seq:
                    s = JTag.STR[(s, bit)]
                npair = (pair[0], s)
                if npair in JTag.TR:
                    if len(JTag.TR[npair]) > len(seq):
                        JTag.TR.update({npair:seq})
                else:
                    JTag.TR.update({npair:seq})
        return JTag.TR[pair]

    def transition(self, bits):
        for bit in bits:
            self.state = JTag.STR[(self.state, bit)]

    def advance(self, state):
        if self.state == JTag.UNKNOWN:
            seq = JTag.TR[(JTag.UNKNOWN, JTag.TEST_LOGIC_RESET)]
            seq += self.tmsseq((JTag.TEST_LOGIC_RESET, state))
        else:
            seq = self.tmsseq((self.state, state))
        jtag_tms(self.i2c, self.base, seq)
        if self.debug:
            print("%s -[%s]-> %s" % (self.state, seq, state))
        self.state = state

    def reset(self):
        self.advance(JTag.TEST_LOGIC_RESET)

    def runtest(self, count=1):
        self.advance(JTag.RUN_TEST_IDLE)
        jtag_tms(self.i2c, self.base, "0"*count)

    def idle(self, count=1):
        self.advance(JTag.RUN_TEST_IDLE)
        jtag_tms(self.i2c, self.base, "0"*count)

    def sir(self, bits, exit=True):
        self.advance(JTag.SHIFT_IR)
        self.shiftin(bits, exit)

    def tdi(self, bits, exit=True):
        self.advance(JTag.SHIFT_DR)
        self.shiftin(bits, exit)

    def tdo(self, count, exit=True):
        self.advance(JTag.SHIFT_DR)
        return self.shiftout(count, exit)

    def tdio(self, bits, exit=True):
        self.advance(JTag.SHIFT_DR)
        return self.shift(bits, exit)

    def shift(self, bits, exit=True):
        bits = crev(bits, self.le)
        bits = jtag_tds(self.i2c, self.base, bits, exit)
        if exit:
            self.transition("1")
        return crev(bits, not self.le)

    def shiftin(self, bits, exit=True):
        bits = crev(bits, self.le)
        jtag_tdi(self.i2c, self.base, bits, exit)
        if exit:
            self.transition("1")

    def shiftout(self, count, exit=True):
        bits = jtag_tdo(self.i2c, self.base, count, exit)
        if exit:
            self.transition("1")
        return crev(bits, not self.le)
        
    def cmd(self, ibits, idle=1):
        self.sir(ibits)
        if idle > 0:
            self.idle(idle)

    def cmdin(self, ibits, dbits, idle=1):
        self.sir(ibits)
        self.tdi(dbits)
        if idle > 0:
            self.idle(idle)

    def cmdout(self, ibits, count=8, idle=1):
        self.sir(ibits)
        out = self.tdo(count)
        if idle > 0:
            self.idle(idle)
        return out
        
    def cmdshift(self, ibits, dbits, idle=1):
        self.sir(ibits)
        out = self.tdio(dbits)
        if idle > 0:
            self.idle(idle)
        return out
        
