
// i2c_slave.c
//
// simple i2c slave interface

/*  Copyright (C) 2015 H.Poetzl
**	
**  This program is free software: you can redistribute it and/or
**  modify it under the terms of the GNU General Public License
**  as published by the Free Software Foundation, either version
**  2 of the License, or (at your option) any later version.
*/

// ------------------------------------------------
// configuration

#define NO_BIT_DEFINES
#include <pic16f1718.h>

#define CONFIG(k, n) __code static char __at _ ## k __ ## k = n

CONFIG(CONFIG1,  _FOSC_INTOSC & _WDTE_OFF & _MCLRE_ON & _BOREN_ON);
CONFIG(CONFIG2,  _PPS1WAY_OFF & _BORV_HI & _LPBOR_ON & _PLLEN_ON);

#define SCL_TRIS	TRISBbits.TRISB6
#define SCL_RPPS	RB6PPS
#define SCL_PPS		0b10000
#define SCL_PPSP	0b01110

#define SDA_TRIS	TRISBbits.TRISB7
#define SDA_RPPS	RB7PPS
#define SDA_PPS		0b10001
#define SDA_PPSP	0b01111

#define TMS_PORT	PORTCbits.RC3
#define TDI_PORT	PORTCbits.RC1
#define TDO_PORT	PORTCbits.RC0
#define TCK_PORT	PORTCbits.RC2


static unsigned volatile char buf[32] = { 0 };
static unsigned volatile char v = 0;
static unsigned volatile char i = 0;
static unsigned volatile char c = 0;


void tms_out(unsigned char val, unsigned char cnt)
{
    while (cnt) {
        TCK_PORT = 0;
	if (val & 1) {
	    TMS_PORT = 1;
	} else {
	    TMS_PORT = 0;
	}
	val = val >> 1;
	TCK_PORT = 1;
	cnt--;
    }
}

void tdi_out(unsigned char val, unsigned char cnt, unsigned char tms)
{
    TMS_PORT = 0;
    while (--cnt) {
        TCK_PORT = 0;
	if (val & 1) {
	    TDI_PORT = 1;
	} else {
	    TDI_PORT = 0;
	}
	val = val >> 1;
	TCK_PORT = 1;
    }
    TCK_PORT = 0;
    if (val & 1) {
        TDI_PORT = 1;
    } else {
        TDI_PORT = 0;
    }
    TMS_PORT = tms;
    TCK_PORT = 1;
}

unsigned char tdo_in(unsigned char cnt, unsigned char tms)
{
    unsigned char val = 0;
    unsigned char bit = 0;

    TMS_PORT = 0;
    while (--cnt) {
	val = val << 1;
        TCK_PORT = 0;
	val = val | bit;
	bit = TDO_PORT;
	TCK_PORT = 1;
    }
    val = val << 1;
    TCK_PORT = 0;
    val = val | bit;
    bit = TDO_PORT;
    TMS_PORT = tms;
    TCK_PORT = 1;
    val = val << 1 | bit;
    return val;
}

void tdi_tdo(unsigned char val, unsigned char cnt, unsigned char tms)
{
    unsigned char bit = 0;

    TMS_PORT = 0;
    while (--cnt) {
        v = (v << 1) | bit;
        TCK_PORT = 0;
	if (val & 1) {
	    TDI_PORT = 1;
	} else {
	    TDI_PORT = 0;
	}
	bit = TDO_PORT;
	val = val >> 1;
	TCK_PORT = 1;
    }
    v = (v << 1) | bit;
    TCK_PORT = 0;
    if (val & 1) {
        TDI_PORT = 1;
    } else {
        TDI_PORT = 0;
    }
    bit = TDO_PORT;
    TMS_PORT = tms;
    TCK_PORT = 1;
    v = v << 1 | bit;
}


void irq(void) __interrupt 0
{
    static unsigned char a = 0;

    if (PIR1bits.SSP1IF) {
	PIR1bits.SSP1IF = 0;

	if (SSPSTATbits.BF) {
	    if (SSP1CON3bits.ACKTIM) {			/* (n)ack */
		// LED_PIN = 1;
		SSP1CON1bits.CKP = 1;
	    } else {
		if (SSP1STATbits.D_NOT_A) {		/* data */
		    if (SSP1STATbits.R_NOT_W) {		/* read */
			;
		    } else {				/* write */
			switch (a) {
			    case 0x10:			/* buf data */
				buf[i++] = SSPBUF;
				break;

			    case 0x12:
				tms_out(SSPBUF, 8);
				break;
			    case 0x13:
				if (i++)
				    tms_out(SSPBUF, c);
				else
				    c = SSPBUF;
				break;

			    case 0x14:
				tdi_tdo(SSPBUF, 8, 1);
				break;
			    case 0x15:
				if (i++)
				    tdi_tdo(SSPBUF, c, 1);
				else
				    c = SSPBUF;
				break;

			    case 0x16:
				tdi_out(SSPBUF, 8, 1);
				break;
			    case 0x17:
				if (i++)
				    tdi_out(SSPBUF, c, 1);
				else
				    c = SSPBUF;
				break;

			    case 0x18:
				tdi_tdo(SSPBUF, 8, 0);
				break;
			    case 0x19:
				if (i++)
				    tdi_tdo(SSPBUF, c, 0);
				else
				    c = SSPBUF;
				break;

			    case 0x1A:
				tdi_out(SSPBUF, 8, 0);
				break;
			    case 0x1B:
				if (i++)
				    tdi_out(SSPBUF, c, 0);
				else
				    c = SSPBUF;
				break;

			    case 0x30:			/* tris A */
				TRISA = SSPBUF;
				break;
			    case 0x31:			/* latch A */
				LATA = SSPBUF;
				break;
			    case 0x32:			/* pullup A */
				WPUA = SSPBUF;
				break;
			    case 0x33:			/* port A */
				PORTA = SSPBUF;
				break;

			    case 0x34:			/* tris B */
				TRISB = SSPBUF | 0xC0;
				break;
			    case 0x35:			/* latch B */
				LATB = SSPBUF;
				break;
			    case 0x36:			/* pullup B */
				WPUB = SSPBUF;
				break;
			    case 0x37:			/* port B */
				PORTB = SSPBUF;
				break;

			    case 0x38:			/* tris C */
				TRISC = SSPBUF;
				break;
			    case 0x39:			/* latch C */
				LATC = SSPBUF;
				break;
			    case 0x3A:			/* pullup C */
				WPUC = SSPBUF;
				break;
			    case 0x3B:			/* port C */
				PORTC = SSPBUF;
				break;

			    case 0x3C:
				RC2PPS = SSPBUF;
				break;
			    case 0x3E:
				NCO1CON = SSPBUF;
				break;
			    case 0x3F:
				NCO1CLK = SSPBUF;
				break;
			}
			SSP1CON1bits.CKP = 1;
		    }
		} else {				/* address */
		    a = SSPBUF >> 1;
		    i = 0;
		    if (SSP1STATbits.R_NOT_W) {		/* read */
			switch (a) {
			    case 0x10:			/* buf data */
				SSPBUF = buf[i++];
				break;

			    case 0x14:
			    case 0x15:
				SSPBUF = v;
				break;

			    case 0x16:
				SSPBUF = tdo_in(8, 1);
				break;
			    case 0x17:
				SSPBUF = tdo_in(c, 1);
				break;

			    case 0x18:
			    case 0x19:
				SSPBUF = v;
				break;

			    case 0x1A:
				SSPBUF = tdo_in(8, 0);
				break;
			    case 0x1B:
				SSPBUF = tdo_in(c, 0);
				break;

			    case 0x30:			/* tris A */
				SSPBUF = TRISA;
				break;
			    case 0x31:			/* latch A */
				SSPBUF = LATA;
				break;
			    case 0x32:			/* pullup A */
				SSPBUF = WPUA;
				break;
			    case 0x33:			/* port A */
				SSPBUF = PORTA;
				break;

			    case 0x34:			/* tris B */
				SSPBUF = TRISB;
				break;
			    case 0x35:			/* latch B */
				SSPBUF = LATB;
				break;
			    case 0x36:			/* pullup B */
				SSPBUF = WPUB;
				break;
			    case 0x37:			/* port B */
				SSPBUF = PORTB;
				break;

			    case 0x38:			/* tris C */
				SSPBUF = TRISC;
				break;
			    case 0x39:			/* latch C */
				SSPBUF = LATC;
				break;
			    case 0x3A:			/* pullup C */
				SSPBUF = WPUC;
				break;
			    case 0x3B:			/* port C */
				SSPBUF = PORTC;
				break;

			    case 0x3C:
				SSPBUF = RC2PPS;
				break;
			    case 0x3E:
				SSPBUF = NCO1CON;
				break;
			    case 0x3F:
				SSPBUF = NCO1CLK;
				break;

			    default:
				SSPBUF = 0xA5;		/* default */
			}
			SSP1CON1bits.CKP = 1;
		    } else {				/* write */
			;
		    }
		}
	    }
	}
	
	// LED_PIN = SSPCON1bits.SSPOV;
	// LED_PIN = SSP1STATbits.D_NOT_A;
	// LED_PIN = SSP1STATbits.R_NOT_W;
    }
}

// --------------------------------------------------
// and our main entry point

void main()
{
    OSCCONbits.SPLLEN = 1;
    OSCCONbits.IRCF = 0b1110;	/* 8MHz */
    OSCCONbits.SCS = 0b00;	/* Fosc */

    // all digital
    ANSELA = 0;
    ANSELB = 0;
    ANSELC = 0;

    // set i2c pins to input
    SCL_TRIS = 1;
    SDA_TRIS = 1;

    PPSLOCKbits.PPSLOCKED = 0;

    SSPDATPPS = SDA_PPSP;
    SDA_RPPS = SDA_PPS;

    SSPCLKPPS = SCL_PPSP;
    SCL_RPPS = SCL_PPS;

    SSP1STATbits.SMP = 1;
    SSP1STATbits.CKE = 1;
    SSP1CON1bits.SSPM = 0b0110;	/* 7bit slave mode */
    SSP1CON1bits.SSPEN = 1;	/* enable I2C */
    SSP1CON1bits.CKP = 1;	/* enable I2C clock */
    SSP1CON2 = 0;
    SSP1CON2bits.SEN = 0;	/* clock stretching disabled */
    SSP1CON3 = 0;
    SSP1CON3bits.BOEN = 1;	/* buffer override enabled */

    SSPADD = 0b00100000;
    SSPMSK = 0b10100000;

    NCO1INCU = 0;
    NCO1INCH = 0x80;
    NCO1INCL = 0x00;
    
    NCO1CON = 0b10100000;

    // RC2PPS = 0b00011;		/* NCO to TCK_W */

    PIR1bits.SSP1IF = 0;	/* clear I2C irq */
    PIE1bits.SSP1IE = 1;	/* enable I2C irq */

    INTCONbits.PEIE = 1;	/* enable peripheral irq */
    INTCONbits.GIE = 1;		/* enable global irq */

    while (1);
}

