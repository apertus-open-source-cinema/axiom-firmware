
// i2c_slave.c
//
// simple i2c slave interface

/*
 * SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
 * SPDX-License-Identifier: GPL-2.0-or-later
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

#define	MB_V034

#ifdef	MB_V034
#define TDI2_PORT	PORTAbits.RA3
#define TCK2_PORT	PORTAbits.RA4
#else
#define TDI2_PORT	PORTAbits.RA0
#define TCK2_PORT	PORTAbits.RA1
#endif
#define TDO2_PORT	PORTBbits.RB3
#define TMS2_PORT	PORTBbits.RB4


static unsigned volatile char buf[32] = { 0 };
static unsigned volatile char v = 0;
static unsigned volatile char i = 0;
static unsigned volatile char c = 0;
static unsigned volatile char f = 0;


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


void tms_out2(unsigned char val, unsigned char cnt)
{
    while (cnt) {
        TCK2_PORT = 0;
	if (val & 1) {
	    TMS2_PORT = 1;
	} else {
	    TMS2_PORT = 0;
	}
	val = val >> 1;
	TCK2_PORT = 1;
	cnt--;
    }
}

void tdi_out2(unsigned char val, unsigned char cnt, unsigned char tms)
{
    TMS2_PORT = 0;
    while (--cnt) {
        TCK2_PORT = 0;
	if (val & 1) {
	    TDI2_PORT = 1;
	} else {
	    TDI2_PORT = 0;
	}
	val = val >> 1;
	TCK2_PORT = 1;
    }
    TCK2_PORT = 0;
    if (val & 1) {
        TDI2_PORT = 1;
    } else {
        TDI2_PORT = 0;
    }
    TMS2_PORT = tms;
    TCK2_PORT = 1;
}

unsigned char tdo_in2(unsigned char cnt, unsigned char tms)
{
    unsigned char val = 0;
    unsigned char bit = 0;

    TMS2_PORT = 0;
    while (--cnt) {
	val = val << 1;
        TCK2_PORT = 0;
	val = val | bit;
	bit = TDO2_PORT;
	TCK2_PORT = 1;
    }
    val = val << 1;
    TCK2_PORT = 0;
    val = val | bit;
    bit = TDO2_PORT;
    TMS2_PORT = tms;
    TCK2_PORT = 1;
    val = val << 1 | bit;
    return val;
}

void tdi_tdo2(unsigned char val, unsigned char cnt, unsigned char tms)
{
    unsigned char bit = 0;

    TMS2_PORT = 0;
    while (--cnt) {
        v = (v << 1) | bit;
        TCK2_PORT = 0;
	if (val & 1) {
	    TDI2_PORT = 1;
	} else {
	    TDI2_PORT = 0;
	}
	bit = TDO2_PORT;
	val = val >> 1;
	TCK2_PORT = 1;
    }
    v = (v << 1) | bit;
    TCK2_PORT = 0;
    if (val & 1) {
        TDI2_PORT = 1;
    } else {
        TDI2_PORT = 0;
    }
    bit = TDO2_PORT;
    TMS2_PORT = tms;
    TCK2_PORT = 1;
    v = v << 1 | bit;
}


void feat_update(void)
{
    if (f & 2) {
	TRISCbits.TRISC4 = 0;
	TRISCbits.TRISC5 = 0;

	CLC1CONbits.LC1EN = 1;
	CLC2CONbits.LC2EN = 1;
    } else {
	TRISCbits.TRISC4 = 1;
	TRISCbits.TRISC5 = 1;

	CLC1CONbits.LC1EN = 0;
	CLC2CONbits.LC2EN = 0;
    }
}


#define	COND	(f & 1)

#define	TDO_IN(c, t)	\
	(COND ? tdo_in2(c, t) : tdo_in(c, t))

#define	TMS_OUT(v, c)	\
	(COND ? tms_out2(v, c) : tms_out(v, c))

#define	TDI_OUT(v, c, t)	\
	(COND ? tdi_out2(v, c, t) : tdi_out(v, c, t))

#define	TDI_TDO(v, c, t)	\
	(COND ? tdi_tdo2(v, c, t) : tdi_tdo(v, c, t))


void irq(void) __interrupt 0
{
    static unsigned char a = 0;
    static unsigned char t = 0;

    if (PIR1bits.SSP1IF) {
	PIR1bits.SSP1IF = 0;

	if (SSPSTATbits.BF) {
	    if (SSP1CON3bits.ACKTIM) {			/* (n)ack */
		// LED_PIN = 1;
	    } else {
		if (SSP1STATbits.D_NOT_A) {		/* data */
		    if (SSP1STATbits.R_NOT_W) {		/* read */
			SSPBUF = 0x5A;			/* default */
		    } else {				/* write */
			switch (a & 0x2F) {
			    case 0x00:			/* buf data */
				buf[i++] = SSPBUF;
				break;

			    case 0x02:
				TMS_OUT(SSPBUF, 8);
				break;
			    case 0x03:
				if (i++)
				    TMS_OUT(SSPBUF, c);
				else
				    c = SSPBUF;
				break;

			    case 0x04:
				TDI_TDO(SSPBUF, 8, 1);
				break;
			    case 0x05:
				if (i++)
				    TDI_TDO(SSPBUF, c, 1);
				else
				    c = SSPBUF;
				break;

			    case 0x06:
				TDI_OUT(SSPBUF, 8, 1);
				break;
			    case 0x07:
				if (i++)
				    TDI_OUT(SSPBUF, c, 1);
				else
				    c = SSPBUF;
				break;

			    case 0x08:
				TDI_TDO(SSPBUF, 8, 0);
				break;
			    case 0x09:
				if (i++)
				    TDI_TDO(SSPBUF, c, 0);
				else
				    c = SSPBUF;
				break;

			    case 0x0A:
				TDI_OUT(SSPBUF, 8, 0);
				break;
			    case 0x0B:
				if (i++)
				    TDI_OUT(SSPBUF, c, 0);
				else
				    c = SSPBUF;
				break;

			    case 0x0F:
				f = SSPBUF;		/* features */
				feat_update();
				break;

			    case 0x20:			/* tris A */
				TRISA = SSPBUF;
				break;
			    case 0x21:			/* latch A */
				LATA = SSPBUF;
				break;
			    case 0x22:			/* pullup A */
				WPUA = SSPBUF;
				break;
			    case 0x23:			/* port A */
				PORTA = SSPBUF;
				break;

			    case 0x24:			/* tris B */
				TRISB = SSPBUF | 0xC0;
				break;
			    case 0x25:			/* latch B */
				LATB = SSPBUF;
				break;
			    case 0x26:			/* pullup B */
				WPUB = SSPBUF;
				break;
			    case 0x27:			/* port B */
				PORTB = SSPBUF;
				break;

			    case 0x28:			/* tris C */
				TRISC = SSPBUF;
				break;
			    case 0x29:			/* latch C */
				LATC = SSPBUF;
				break;
			    case 0x2A:			/* pullup C */
				WPUC = SSPBUF;
				break;
			    case 0x2B:			/* port C */
				PORTC = SSPBUF;
				break;

			    case 0x2C:
				RC2PPS = SSPBUF;
				break;
			    case 0x2E:
				NCO1CON = SSPBUF;
				break;
			    case 0x2F:
				NCO1CLK = SSPBUF;
				break;

			    default:
				t = SSPBUF;
				break;
			}
		    }
		} else {				/* address */
		    a = SSPBUF >> 1;
		    i = 0;
		    if (SSP1STATbits.R_NOT_W) {		/* read */
			switch (a & 0x2F) {
			    case 0x00:			/* buf data */
				SSPBUF = buf[i++];
				break;

			    case 0x04:
			    case 0x05:
				SSPBUF = v;
				break;

			    case 0x06:
				SSPBUF = TDO_IN(8, 1);
				break;
			    case 0x07:
				SSPBUF = TDO_IN(c, 1);
				break;

			    case 0x08:
			    case 0x09:
				SSPBUF = v;
				break;

			    case 0x0A:
				SSPBUF = TDO_IN(8, 0);
				break;
			    case 0x0B:
				SSPBUF = TDO_IN(c, 0);
				break;

			    case 0x0F:
				SSPBUF = f;
				break;

			    case 0x20:			/* tris A */
				SSPBUF = TRISA;
				break;
			    case 0x21:			/* latch A */
				SSPBUF = LATA;
				break;
			    case 0x22:			/* pullup A */
				SSPBUF = WPUA;
				break;
			    case 0x23:			/* port A */
				SSPBUF = PORTA;
				break;

			    case 0x24:			/* tris B */
				SSPBUF = TRISB;
				break;
			    case 0x25:			/* latch B */
				SSPBUF = LATB;
				break;
			    case 0x26:			/* pullup B */
				SSPBUF = WPUB;
				break;
			    case 0x27:			/* port B */
				SSPBUF = PORTB;
				break;

			    case 0x28:			/* tris C */
				SSPBUF = TRISC;
				break;
			    case 0x29:			/* latch C */
				SSPBUF = LATC;
				break;
			    case 0x2A:			/* pullup C */
				SSPBUF = WPUC;
				break;
			    case 0x2B:			/* port C */
				SSPBUF = PORTC;
				break;

			    case 0x2C:
				SSPBUF = RC2PPS;
				break;
			    case 0x2E:
				SSPBUF = NCO1CON;
				break;
			    case 0x2F:
				SSPBUF = NCO1CLK;
				break;

			    default:
				SSPBUF = 0xA5;		/* default */
			}
		    } else {				/* write */
			;
		    }
		}
	    }
	} else {
	    if (SSP1STATbits.R_NOT_W) {			/* read */
		switch (a & 0x2F) {
		    case 0x00:				/* buf data */
			SSPBUF = buf[i++];
			break;
		    default:
			SSPBUF = 0xAB;			/* default */
			break;
		}
	    }
	}
	SSP1CON1bits.CKP = 1;
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
    SSP1CON2bits.SEN = 1;	/* clock stretching disabled */
    SSP1CON3 = 0;
    SSP1CON3bits.BOEN = 1;	/* buffer override enabled */

    SSPADD = 0b10000000;
    SSPMSK = 0b10100000;

    NCO1INCU = 0;
    NCO1INCH = 0x80;
    NCO1INCL = 0x00;
    
    NCO1CON = 0b10100000;

    // RC2PPS = 0b00011;	/* NCO to TCK_W */


    CLC1CON = 0;

    CLC1SEL0 = 0b00010;		/* CLCIN2 */
    CLC1SEL1 = 0b00010;		/* CLCIN2 */
    CLC1SEL2 = 0b00010;		/* CLCIN2 */
    CLC1SEL3 = 0b00010;		/* CLCIN2 */

    CLC1GLS0 = 0b01010101;	/* AND */
    CLC1GLS1 = 0b01010101;	/* AND */
    CLC1GLS2 = 0b01010101;	/* AND */
    CLC1GLS3 = 0b01010101;	/* AND */

    CLC1POL = 0b00001111;	/* AND */
    CLC1CON = 0b00000010;	/* AND-4 */

    CLCIN2PPS = 0b01110;	/* RB6 */
    RC4PPS = 0b00100;		/* *_SCL */

    CLC2CON = 0;

    CLC2SEL0 = 0b00011;		/* CLCIN3 */
    CLC2SEL1 = 0b00011;		/* CLCIN3 */
    CLC2SEL2 = 0b00011;		/* CLCIN3 */
    CLC2SEL3 = 0b00011;		/* CLCIN3 */

    CLC2GLS0 = 0b01010101;	/* AND */
    CLC2GLS1 = 0b01010101;	/* AND */
    CLC2GLS2 = 0b01010101;	/* AND */
    CLC2GLS3 = 0b01010101;	/* AND */

    CLC2POL = 0b00001111;	/* AND */
    CLC2CON = 0b00000010;	/* AND-4 */

    CLCIN3PPS = 0b01111;	/* RB7 */
    RC5PPS = 0b00101;		/* *_SDA */


    PIR1bits.SSP1IF = 0;	/* clear I2C irq */
    PIE1bits.SSP1IE = 1;	/* enable I2C irq */

    INTCONbits.PEIE = 1;	/* enable peripheral irq */
    INTCONbits.GIE = 1;		/* enable global irq */

    while (1);
}

