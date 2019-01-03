#!/bin/env python3

# Copyright (C) 2016 Herbert Poetzl

def rev(s):
    return s[::-1]

def h2b(s):
    return ''.join([format(int(_,16),"04b") for _ in s])
    
def b2h(s):
    return ''.join([format(int(''.join(_),2),"X") for _ in zip(*[iter(s)]*4)])


ISC_DATA_SHIFT          = h2b("0A")
ISC_ERASE               = h2b("0E")
ISC_DISCHARGE           = h2b("14")
EXTEST                  = h2b("15")
HIGHZ                   = h2b("18")
UIDCODE_PUB             = h2b("19")
PRELOAD                 = h2b("1C")
SAMPLE                  = h2b("1C")
ISC_ERASE_DONE          = h2b("24")
ISC_DISABLE             = h2b("26")
ISC_NOOP                = h2b("30")
LSC_RESET_CRC           = h2b("3B")
LSC_READ_STATUS         = h2b("3C")
ISC_ADDRESS_SHIFT       = h2b("42")
LSC_INIT_ADDRESS        = h2b("46")
LSC_INIT_ADDR_UFM       = h2b("47")
ISC_PROGRAM_DONE        = h2b("5E")
LSC_READ_CRC            = h2b("60")
ISC_PROGRAM             = h2b("67")
LSC_PROG_INCR_NV        = h2b("70")
LSC_READ_INCR_NV        = h2b("73")
LSC_ENABLE_X            = h2b("74")
CLAMP                   = h2b("78")
LSC_REFRESH             = h2b("79")
LSC_BITSTREAM_BURST     = h2b("7A")
LSC_DEVICE_CTRL         = h2b("7D")
ISC_READ                = h2b("80")
LSC_PROG_INCR_RTI       = h2b("82")
LSC_WRITE_ADDRESS       = h2b("B4")
LSC_PROG_INCR_ENC       = h2b("B6")
LSC_PROG_INCR_CMP       = h2b("B8")
LSC_PROG_INCR_CNE       = h2b("BA")
LSC_SHIFT_PASSWORD      = h2b("BC")
USERCODE                = h2b("C0")
ISC_PROGRAM_USERCODE    = h2b("C2")
ISC_ENABLE              = h2b("C6")
LSC_PROG_TAG            = h2b("C9")
LSC_READ_TAG            = h2b("CA")
LSC_ERASE_TAG           = h2b("CB")
ISC_PROGRAM_SECURITY    = h2b("CE")
LSC_PROGRAM_SECPLUS     = h2b("CF")
IDCODE                  = h2b("E0")
LSC_PROG_FEATURE        = h2b("E4")
LSC_READ_FEATURE        = h2b("E7")
LSC_CHECK_BUSY          = h2b("F0")
LSC_PROG_PASSWORD       = h2b("F1")
LSC_READ_PASSWORD       = h2b("F2")
LSC_PROG_CIPHER_KEY     = h2b("F3")
LSC_READ_CIPHER_KEY     = h2b("F4")
LSC_PROG_FEABITS        = h2b("F8")
LSC_PROG_OTP            = h2b("F9")
LSC_READ_OTP            = h2b("FA")
LSC_READ_FEABITS        = h2b("FB")
BYPASS                  = h2b("FF")

DEVID = { 
    "00000000000000000000000000000000" : ("<zeros>",        0,   0,    0),
    "00000001001010111001000001000011" : ("MXO2-640HC",  1151, 192, 19*8),
    "00000001001010111010000001000011" : ("MXO2-1200HC", 2175, 512, 26*8),
    "00000001001010111011000001000011" : ("MXO2-2000HC", 3198, 640, 53*8) }

SBITS = [
    ( 0, 1, "TRAN"),
    ( 1, 3, ["CFG", "SRAM", "EFUSE", "?", "?", "?", "?", "?", "?"]),
    ( 4, 1, "JTAG"),
    ( 5, 1, "PWDPROT"),
    ( 6, 1, "OTP"),
    ( 7, 1, "DECRYPT"),
    ( 8, 1, "DONE"),
    ( 9, 1, "ISC"),
    (10, 1, "WRITE"),
    (11, 1, "READ"),
    (12, 1, "BUSY"),
    (13, 1, "FAIL"),
    (14, 1, "FEAOTP"),
    (15, 1, "DONLY"),
    (16, 1, "PWDEN"),
    (17, 1, "UFMOTP"),
    (18, 1, "ASSP"),
    (19, 1, "SDMEN"),
    (20, 1, "EPREAM"),
    (21, 1, "PREAM"),
    (22, 1, "SPIFAIL"),
    (23, 3, ["BSE", "OK", "ID", "CMD", "CRC", "PRMB", "ABRT", "OVFL", "SDM"]),
    (26, 1, "EEXEC"),
    (27, 1, "EID"),
    (28, 1, "INVCMD"),
    (29, 1, "ESED"),
    (30, 1, "BYPASS"),
    (31, 1, "FTM") ]

FBITS = [
    (  0, 32, "IDCODE"),
    ( 32, 8, "TRACEID"),
    ( 40, 8, "I2CADDR"),
    ( 48, 1, "SECPWD"),
    ( 49, 1, "DECONLY"),
    ( 50, 1, "PWDFLASH"),
    ( 51, 1, "PWDALL"),
    ( 52, 1, "MYASSP"),
    ( 53, 1, "PROGRAM"),
    ( 54, 1, "INIT"),
    ( 55, 1, "DONE"),
    ( 56, 1, "JTAG"),
    ( 57, 1, "SSPI"),
    ( 58, 1, "I2C"),
    ( 59, 1, "MSPI"),
    ( 60, 1, "BOOTS1"),
    ( 61, 1, "BOOTS2"),
    ( 62, 2, "RSVD") ]

def status(jtag):
    status = jtag.cmdout(LSC_READ_STATUS, 32)
    hr = []
    for (sbit, blen, name) in SBITS:
        bits = rev(status)[sbit:sbit+blen]
        if blen == 1:
            if bits == "1":
                hr.append(name)
        else:
            bval = int(bits, 2)
            hr.append("%s=%s" % (name[0], name[bval+1]))
    print("status %s [%s] %s" %
        (b2h(status), status, " ".join(hr)))
    
def wnbusy(jtag, debug=True):
    if debug:
        print("wnbusy ", end="")
    while True:
        busy = jtag.cmdout(LSC_CHECK_BUSY, 8)
        if busy.endswith("0"):
            if debug:
                print(".")
            break
        else:
            if debug:
                print(".", end="")
