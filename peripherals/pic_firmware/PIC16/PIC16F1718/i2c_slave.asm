;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.0 #9615 (Linux)
;--------------------------------------------------------
; PIC port for the 14-bit core
;--------------------------------------------------------
;	.file	"i2c_slave.c"
	list	p=16f1718
	radix dec
	include "p16f1718.inc"
;--------------------------------------------------------
; config word(s)
;--------------------------------------------------------
	__config _CONFIG1, 0x3fe4
	__config _CONFIG2, 0x33fb
;--------------------------------------------------------
; external declarations
;--------------------------------------------------------
	extern	_STATUSbits
	extern	_BSRbits
	extern	_INTCONbits
	extern	_PORTAbits
	extern	_PORTBbits
	extern	_PORTCbits
	extern	_PORTEbits
	extern	_PIR1bits
	extern	_PIR2bits
	extern	_PIR3bits
	extern	_T1CONbits
	extern	_T1GCONbits
	extern	_T2CONbits
	extern	_TRISAbits
	extern	_TRISBbits
	extern	_TRISCbits
	extern	_TRISEbits
	extern	_PIE1bits
	extern	_PIE2bits
	extern	_PIE3bits
	extern	_OPTION_REGbits
	extern	_PCONbits
	extern	_WDTCONbits
	extern	_OSCTUNEbits
	extern	_OSCCONbits
	extern	_OSCSTATbits
	extern	_ADCON0bits
	extern	_ADCON1bits
	extern	_ADCON2bits
	extern	_LATAbits
	extern	_LATBbits
	extern	_LATCbits
	extern	_CM1CON0bits
	extern	_CM1CON1bits
	extern	_CM2CON0bits
	extern	_CM2CON1bits
	extern	_CMOUTbits
	extern	_BORCONbits
	extern	_FVRCONbits
	extern	_DAC1CON0bits
	extern	_DAC1CON1bits
	extern	_DAC2CON0bits
	extern	_DAC2CON1bits
	extern	_DAC2REFbits
	extern	_ZCD1CONbits
	extern	_ANSELAbits
	extern	_ANSELBbits
	extern	_ANSELCbits
	extern	_PMCON1bits
	extern	_VREGCONbits
	extern	_RC1STAbits
	extern	_RCSTAbits
	extern	_RCSTA1bits
	extern	_TX1STAbits
	extern	_TXSTAbits
	extern	_TXSTA1bits
	extern	_BAUD1CONbits
	extern	_BAUDCONbits
	extern	_BAUDCON1bits
	extern	_BAUDCTLbits
	extern	_BAUDCTL1bits
	extern	_WPUAbits
	extern	_WPUBbits
	extern	_WPUCbits
	extern	_WPUEbits
	extern	_SSP1BUFbits
	extern	_SSPBUFbits
	extern	_SSP1ADDbits
	extern	_SSPADDbits
	extern	_SSP1MSKbits
	extern	_SSPMSKbits
	extern	_SSP1STATbits
	extern	_SSPSTATbits
	extern	_SSP1CONbits
	extern	_SSP1CON1bits
	extern	_SSPCONbits
	extern	_SSPCON1bits
	extern	_SSP1CON2bits
	extern	_SSPCON2bits
	extern	_SSP1CON3bits
	extern	_SSPCON3bits
	extern	_ODCONAbits
	extern	_ODCONBbits
	extern	_ODCONCbits
	extern	_CCP1CONbits
	extern	_ECCP1CONbits
	extern	_CCP2CONbits
	extern	_ECCP2CONbits
	extern	_CCPTMRSbits
	extern	_SLRCONAbits
	extern	_SLRCONBbits
	extern	_SLRCONCbits
	extern	_INLVLAbits
	extern	_INLVLBbits
	extern	_INLVLCbits
	extern	_INLVLEbits
	extern	_IOCAPbits
	extern	_IOCANbits
	extern	_IOCAFbits
	extern	_IOCBPbits
	extern	_IOCBNbits
	extern	_IOCBFbits
	extern	_IOCCPbits
	extern	_IOCCNbits
	extern	_IOCCFbits
	extern	_IOCEPbits
	extern	_IOCENbits
	extern	_IOCEFbits
	extern	_T4CONbits
	extern	_T6CONbits
	extern	_NCO1ACCLbits
	extern	_NCO1ACCHbits
	extern	_NCO1ACCUbits
	extern	_NCO1INCLbits
	extern	_NCO1INCHbits
	extern	_NCO1INCUbits
	extern	_NCO1CONbits
	extern	_NCO1CLKbits
	extern	_OPA1CONbits
	extern	_OPA2CONbits
	extern	_PWM3DCLbits
	extern	_PWM3DCHbits
	extern	_PWM3CONbits
	extern	_PWM3CON0bits
	extern	_PWM4DCLbits
	extern	_PWM4DCHbits
	extern	_PWM4CONbits
	extern	_PWM4CON0bits
	extern	_COG1PHRbits
	extern	_COG1PHFbits
	extern	_COG1BLKRbits
	extern	_COG1BLKFbits
	extern	_COG1DBRbits
	extern	_COG1DBFbits
	extern	_COG1CON0bits
	extern	_COG1CON1bits
	extern	_COG1RISbits
	extern	_COG1RSIMbits
	extern	_COG1FISbits
	extern	_COG1FSIMbits
	extern	_COG1ASD0bits
	extern	_COG1ASD1bits
	extern	_COG1STRbits
	extern	_PPSLOCKbits
	extern	_CLCDATAbits
	extern	_CLC1CONbits
	extern	_CLC1POLbits
	extern	_CLC1SEL0bits
	extern	_CLC1SEL1bits
	extern	_CLC1SEL2bits
	extern	_CLC1SEL3bits
	extern	_CLC1GLS0bits
	extern	_CLC1GLS1bits
	extern	_CLC1GLS2bits
	extern	_CLC1GLS3bits
	extern	_CLC2CONbits
	extern	_CLC2POLbits
	extern	_CLC2SEL0bits
	extern	_CLC2SEL1bits
	extern	_CLC2SEL2bits
	extern	_CLC2SEL3bits
	extern	_CLC2GLS0bits
	extern	_CLC2GLS1bits
	extern	_CLC2GLS2bits
	extern	_CLC2GLS3bits
	extern	_CLC3CONbits
	extern	_CLC3POLbits
	extern	_CLC3SEL0bits
	extern	_CLC3SEL1bits
	extern	_CLC3SEL2bits
	extern	_CLC3SEL3bits
	extern	_CLC3GLS0bits
	extern	_CLC3GLS1bits
	extern	_CLC3GLS2bits
	extern	_CLC3GLS3bits
	extern	_CLC4CONbits
	extern	_CLC4POLbits
	extern	_CLC4SEL0bits
	extern	_CLC4SEL1bits
	extern	_CLC4SEL2bits
	extern	_CLC4SEL3bits
	extern	_CLC4GLS0bits
	extern	_CLC4GLS1bits
	extern	_CLC4GLS2bits
	extern	_CLC4GLS3bits
	extern	_STATUS_SHADbits
	extern	_INDF0
	extern	_INDF1
	extern	_PCL
	extern	_STATUS
	extern	_FSR0
	extern	_FSR0L
	extern	_FSR0H
	extern	_FSR1
	extern	_FSR1L
	extern	_FSR1H
	extern	_BSR
	extern	_WREG
	extern	_PCLATH
	extern	_INTCON
	extern	_PORTA
	extern	_PORTB
	extern	_PORTC
	extern	_PORTE
	extern	_PIR1
	extern	_PIR2
	extern	_PIR3
	extern	_TMR0
	extern	_TMR1
	extern	_TMR1L
	extern	_TMR1H
	extern	_T1CON
	extern	_T1GCON
	extern	_TMR2
	extern	_PR2
	extern	_T2CON
	extern	_TRISA
	extern	_TRISB
	extern	_TRISC
	extern	_TRISE
	extern	_PIE1
	extern	_PIE2
	extern	_PIE3
	extern	_OPTION_REG
	extern	_PCON
	extern	_WDTCON
	extern	_OSCTUNE
	extern	_OSCCON
	extern	_OSCSTAT
	extern	_ADRES
	extern	_ADRESL
	extern	_ADRESH
	extern	_ADCON0
	extern	_ADCON1
	extern	_ADCON2
	extern	_LATA
	extern	_LATB
	extern	_LATC
	extern	_CM1CON0
	extern	_CM1CON1
	extern	_CM2CON0
	extern	_CM2CON1
	extern	_CMOUT
	extern	_BORCON
	extern	_FVRCON
	extern	_DAC1CON0
	extern	_DAC1CON1
	extern	_DAC2CON0
	extern	_DAC2CON1
	extern	_DAC2REF
	extern	_ZCD1CON
	extern	_ANSELA
	extern	_ANSELB
	extern	_ANSELC
	extern	_PMADR
	extern	_PMADRL
	extern	_PMADRH
	extern	_PMDAT
	extern	_PMDATL
	extern	_PMDATH
	extern	_PMCON1
	extern	_PMCON2
	extern	_VREGCON
	extern	_RC1REG
	extern	_RCREG
	extern	_RCREG1
	extern	_TX1REG
	extern	_TXREG
	extern	_TXREG1
	extern	_SP1BRG
	extern	_SP1BRGL
	extern	_SPBRG
	extern	_SPBRG1
	extern	_SPBRGL
	extern	_SP1BRGH
	extern	_SPBRGH
	extern	_SPBRGH1
	extern	_RC1STA
	extern	_RCSTA
	extern	_RCSTA1
	extern	_TX1STA
	extern	_TXSTA
	extern	_TXSTA1
	extern	_BAUD1CON
	extern	_BAUDCON
	extern	_BAUDCON1
	extern	_BAUDCTL
	extern	_BAUDCTL1
	extern	_WPUA
	extern	_WPUB
	extern	_WPUC
	extern	_WPUE
	extern	_SSP1BUF
	extern	_SSPBUF
	extern	_SSP1ADD
	extern	_SSPADD
	extern	_SSP1MSK
	extern	_SSPMSK
	extern	_SSP1STAT
	extern	_SSPSTAT
	extern	_SSP1CON
	extern	_SSP1CON1
	extern	_SSPCON
	extern	_SSPCON1
	extern	_SSP1CON2
	extern	_SSPCON2
	extern	_SSP1CON3
	extern	_SSPCON3
	extern	_ODCONA
	extern	_ODCONB
	extern	_ODCONC
	extern	_CCPR1
	extern	_CCPR1L
	extern	_CCPR1H
	extern	_CCP1CON
	extern	_ECCP1CON
	extern	_CCPR2
	extern	_CCPR2L
	extern	_CCPR2H
	extern	_CCP2CON
	extern	_ECCP2CON
	extern	_CCPTMRS
	extern	_SLRCONA
	extern	_SLRCONB
	extern	_SLRCONC
	extern	_INLVLA
	extern	_INLVLB
	extern	_INLVLC
	extern	_INLVLE
	extern	_IOCAP
	extern	_IOCAN
	extern	_IOCAF
	extern	_IOCBP
	extern	_IOCBN
	extern	_IOCBF
	extern	_IOCCP
	extern	_IOCCN
	extern	_IOCCF
	extern	_IOCEP
	extern	_IOCEN
	extern	_IOCEF
	extern	_TMR4
	extern	_PR4
	extern	_T4CON
	extern	_TMR6
	extern	_PR6
	extern	_T6CON
	extern	_NCO1ACC
	extern	_NCO1ACCL
	extern	_NCO1ACCH
	extern	_NCO1ACCU
	extern	_NCO1INC
	extern	_NCO1INCL
	extern	_NCO1INCH
	extern	_NCO1INCU
	extern	_NCO1CON
	extern	_NCO1CLK
	extern	_OPA1CON
	extern	_OPA2CON
	extern	_PWM3DCL
	extern	_PWM3DCH
	extern	_PWM3CON
	extern	_PWM3CON0
	extern	_PWM4DCL
	extern	_PWM4DCH
	extern	_PWM4CON
	extern	_PWM4CON0
	extern	_COG1PHR
	extern	_COG1PHF
	extern	_COG1BLKR
	extern	_COG1BLKF
	extern	_COG1DBR
	extern	_COG1DBF
	extern	_COG1CON0
	extern	_COG1CON1
	extern	_COG1RIS
	extern	_COG1RSIM
	extern	_COG1FIS
	extern	_COG1FSIM
	extern	_COG1ASD0
	extern	_COG1ASD1
	extern	_COG1STR
	extern	_PPSLOCK
	extern	_INTPPS
	extern	_T0CKIPPS
	extern	_T1CKIPPS
	extern	_T1GPPS
	extern	_CCP1PPS
	extern	_CCP2PPS
	extern	_COGINPPS
	extern	_SSPCLKPPS
	extern	_SSPDATPPS
	extern	_SSPSSPPS
	extern	_RXPPS
	extern	_CKPPS
	extern	_CLCIN0PPS
	extern	_CLCIN1PPS
	extern	_CLCIN2PPS
	extern	_CLCIN3PPS
	extern	_RA0PPS
	extern	_RA1PPS
	extern	_RA2PPS
	extern	_RA3PPS
	extern	_RA4PPS
	extern	_RA5PPS
	extern	_RA6PPS
	extern	_RA7PPS
	extern	_RB0PPS
	extern	_RB1PPS
	extern	_RB2PPS
	extern	_RB3PPS
	extern	_RB4PPS
	extern	_RB5PPS
	extern	_RB6PPS
	extern	_RB7PPS
	extern	_RC0PPS
	extern	_RC1PPS
	extern	_RC2PPS
	extern	_RC3PPS
	extern	_RC4PPS
	extern	_RC5PPS
	extern	_RC6PPS
	extern	_RC7PPS
	extern	_CLCDATA
	extern	_CLC1CON
	extern	_CLC1POL
	extern	_CLC1SEL0
	extern	_CLC1SEL1
	extern	_CLC1SEL2
	extern	_CLC1SEL3
	extern	_CLC1GLS0
	extern	_CLC1GLS1
	extern	_CLC1GLS2
	extern	_CLC1GLS3
	extern	_CLC2CON
	extern	_CLC2POL
	extern	_CLC2SEL0
	extern	_CLC2SEL1
	extern	_CLC2SEL2
	extern	_CLC2SEL3
	extern	_CLC2GLS0
	extern	_CLC2GLS1
	extern	_CLC2GLS2
	extern	_CLC2GLS3
	extern	_CLC3CON
	extern	_CLC3POL
	extern	_CLC3SEL0
	extern	_CLC3SEL1
	extern	_CLC3SEL2
	extern	_CLC3SEL3
	extern	_CLC3GLS0
	extern	_CLC3GLS1
	extern	_CLC3GLS2
	extern	_CLC3GLS3
	extern	_CLC4CON
	extern	_CLC4POL
	extern	_CLC4SEL0
	extern	_CLC4SEL1
	extern	_CLC4SEL2
	extern	_CLC4SEL3
	extern	_CLC4GLS0
	extern	_CLC4GLS1
	extern	_CLC4GLS2
	extern	_CLC4GLS3
	extern	_STATUS_SHAD
	extern	_WREG_SHAD
	extern	_BSR_SHAD
	extern	_PCLATH_SHAD
	extern	_FSR0L_SHAD
	extern	_FSR0H_SHAD
	extern	_FSR1L_SHAD
	extern	_FSR1H_SHAD
	extern	_STKPTR
	extern	_TOSL
	extern	_TOSH
	extern	__sdcc_gsinit_startup
;--------------------------------------------------------
; global declarations
;--------------------------------------------------------
	global	_tms_out
	global	_tdi_out
	global	_tdo_in
	global	_tdi_tdo
	global	_irq
	global	_main

	global PSAVE
	global SSAVE
	global WSAVE
	global STK12
	global STK11
	global STK10
	global STK09
	global STK08
	global STK07
	global STK06
	global STK05
	global STK04
	global STK03
	global STK02
	global STK01
	global STK00

sharebank udata_ovr 0x0070
PSAVE	res 1
SSAVE	res 1
WSAVE	res 1
STK12	res 1
STK11	res 1
STK10	res 1
STK09	res 1
STK08	res 1
STK07	res 1
STK06	res 1
STK05	res 1
STK04	res 1
STK03	res 1
STK02	res 1
STK01	res 1
STK00	res 1

;--------------------------------------------------------
; global definitions
;--------------------------------------------------------
;--------------------------------------------------------
; absolute symbol definitions
;--------------------------------------------------------
;--------------------------------------------------------
; compiler-defined variables
;--------------------------------------------------------
UDL_i2c_slave_0	udata
r0x1033	res	1
r0x1034	res	1
r0x102F	res	1
r0x1030	res	1
r0x1031	res	1
r0x1032	res	1
r0x102A	res	1
r0x102B	res	1
r0x102C	res	1
r0x102D	res	1
r0x102E	res	1
r0x1025	res	1
r0x1026	res	1
r0x1027	res	1
r0x1028	res	1
r0x1029	res	1
r0x1035	res	1
r0x1036	res	1
_irq_t_1_24	res	1
_irq_a_1_24	res	1
;--------------------------------------------------------
; initialized data
;--------------------------------------------------------

ID_i2c_slave_0	idata
_buf
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00
	db	0x00


ID_i2c_slave_1	idata
_v
	db	0x00


ID_i2c_slave_2	idata
_i
	db	0x00


ID_i2c_slave_3	idata
_c
	db	0x00

;--------------------------------------------------------
; overlayable items in internal ram 
;--------------------------------------------------------
;	udata_ovr
;--------------------------------------------------------
; reset vector 
;--------------------------------------------------------
STARTUP	code 0x0000
	nop
	pagesel __sdcc_gsinit_startup
	goto	__sdcc_gsinit_startup
;--------------------------------------------------------
; interrupt and initialization code
;--------------------------------------------------------
c_interrupt	code	0x0004
__sdcc_interrupt:
;***
;  pBlock Stats: dbName = I
;***
;functions called:
;   _tms_out
;   _tms_out
;   _tdi_tdo
;   _tdi_tdo
;   _tdi_out
;   _tdi_out
;   _tdi_tdo
;   _tdi_tdo
;   _tdi_out
;   _tdi_out
;   _tdo_in
;   _tdo_in
;   _tdo_in
;   _tdo_in
;   _tms_out
;   _tms_out
;   _tdi_tdo
;   _tdi_tdo
;   _tdi_out
;   _tdi_out
;   _tdi_tdo
;   _tdi_tdo
;   _tdi_out
;   _tdi_out
;   _tdo_in
;   _tdo_in
;   _tdo_in
;   _tdo_in
;4 compiler assigned registers:
;   r0x1035
;   r0x1036
;   STK00
;   STK01
;; Starting pCode block
_irq:
; 0 exit points
;	.line	139; "i2c_slave.c"	void irq(void) __interrupt 0
	CLRF	PCLATH
;	.line	144; "i2c_slave.c"	if (PIR1bits.SSP1IF) {
	BANKSEL	_PIR1bits
	BTFSS	_PIR1bits,3
	GOTO	END_OF_INTERRUPT
;	.line	145; "i2c_slave.c"	PIR1bits.SSP1IF = 0;
	BCF	_PIR1bits,3
;	.line	147; "i2c_slave.c"	if (SSPSTATbits.BF) {
	BANKSEL	_SSPSTATbits
	BTFSS	_SSPSTATbits,0
	GOTO	END_OF_INTERRUPT
;	.line	148; "i2c_slave.c"	if (SSP1CON3bits.ACKTIM) {			/* (n)ack */
	BTFSS	_SSP1CON3bits,7
	GOTO	_00227_DS_
;	.line	150; "i2c_slave.c"	SSP1CON1bits.CKP = 1;
	BSF	_SSP1CON1bits,4
	GOTO	END_OF_INTERRUPT
_00227_DS_:
;	.line	152; "i2c_slave.c"	if (SSP1STATbits.D_NOT_A) {		/* data */
	BANKSEL	_SSP1STATbits
	BTFSS	_SSP1STATbits,5
	GOTO	_00224_DS_
;	.line	153; "i2c_slave.c"	if (SSP1STATbits.R_NOT_W) {		/* read */
	BTFSC	_SSP1STATbits,2
	GOTO	END_OF_INTERRUPT
;	.line	156; "i2c_slave.c"	switch (a & 0x2F) {
	MOVLW	0x2f
	BANKSEL	_irq_a_1_24
	ANDWF	_irq_a_1_24,W
	BANKSEL	r0x1035
	MOVWF	r0x1035
;;     peep 1 - test/jump to test/skip
	MOVF	r0x1035,W
	BTFSC	STATUS,2
	GOTO	_00149_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x02
	BTFSC	STATUS,2
	GOTO	_00150_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x03
	BTFSC	STATUS,2
	GOTO	_00151_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x04
	BTFSC	STATUS,2
	GOTO	_00155_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x05
	BTFSC	STATUS,2
	GOTO	_00156_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x06
	BTFSC	STATUS,2
	GOTO	_00160_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x07
	BTFSC	STATUS,2
	GOTO	_00161_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x08
	BTFSC	STATUS,2
	GOTO	_00165_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x09
	BTFSC	STATUS,2
	GOTO	_00166_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x0a
	BTFSC	STATUS,2
	GOTO	_00170_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x0b
	BTFSC	STATUS,2
	GOTO	_00171_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x20
	BTFSC	STATUS,2
	GOTO	_00175_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x21
	BTFSC	STATUS,2
	GOTO	_00176_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x22
	BTFSC	STATUS,2
	GOTO	_00177_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x23
	BTFSC	STATUS,2
	GOTO	_00178_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x24
	BTFSC	STATUS,2
	GOTO	_00179_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x25
	BTFSC	STATUS,2
	GOTO	_00180_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x26
	BTFSC	STATUS,2
	GOTO	_00181_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x27
	BTFSC	STATUS,2
	GOTO	_00182_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x28
	BTFSC	STATUS,2
	GOTO	_00183_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x29
	BTFSC	STATUS,2
	GOTO	_00184_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x2a
	BTFSC	STATUS,2
	GOTO	_00185_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x2b
	BTFSC	STATUS,2
	GOTO	_00186_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x2c
	BTFSC	STATUS,2
	GOTO	_00187_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x2e
	BTFSC	STATUS,2
	GOTO	_00188_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x2f
	BTFSC	STATUS,2
	GOTO	_00189_DS_
	GOTO	_00190_DS_
_00149_DS_:
;	.line	158; "i2c_slave.c"	buf[i++] = SSPBUF;
	BANKSEL	_i
	MOVF	_i,W
	BANKSEL	r0x1035
	MOVWF	r0x1035
	BANKSEL	_i
	INCF	_i,F
	BANKSEL	r0x1035
	MOVF	r0x1035,W
	ADDLW	(_buf + 0)
	MOVWF	r0x1035
	MOVLW	high (_buf + 0)
	BTFSC	STATUS,0
	ADDLW	0x01
	MOVWF	r0x1036
	MOVF	r0x1035,W
	MOVWF	FSR0L
	MOVF	r0x1036,W
	MOVWF	FSR0H
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	MOVWF	INDF0
;	.line	159; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00150_DS_:
;	.line	162; "i2c_slave.c"	tms_out(SSPBUF, 8);
	MOVLW	0x08
	MOVWF	STK00
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	PAGESEL	_tms_out
	CALL	_tms_out
	PAGESEL	$
;	.line	163; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00151_DS_:
;	.line	165; "i2c_slave.c"	if (i++)
	BANKSEL	_i
	MOVF	_i,W
	BANKSEL	r0x1035
	MOVWF	r0x1035
	BANKSEL	_i
	INCF	_i,F
;;     peep 7 - Removed redundant move
	BANKSEL	r0x1035
	MOVF	r0x1035,W
	BTFSC	STATUS,2
	GOTO	_00153_DS_
;	.line	166; "i2c_slave.c"	tms_out(SSPBUF, c);
	BANKSEL	_c
	MOVF	_c,W
	MOVWF	STK00
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	PAGESEL	_tms_out
	CALL	_tms_out
	PAGESEL	$
	GOTO	_00191_DS_
_00153_DS_:
;	.line	168; "i2c_slave.c"	c = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	BANKSEL	_c
	MOVWF	_c
;	.line	169; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00155_DS_:
;	.line	172; "i2c_slave.c"	tdi_tdo(SSPBUF, 8, 1);
	MOVLW	0x01
	MOVWF	STK01
	MOVLW	0x08
	MOVWF	STK00
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	PAGESEL	_tdi_tdo
	CALL	_tdi_tdo
	PAGESEL	$
;	.line	173; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00156_DS_:
;	.line	175; "i2c_slave.c"	if (i++)
	BANKSEL	_i
	MOVF	_i,W
	BANKSEL	r0x1035
	MOVWF	r0x1035
	BANKSEL	_i
	INCF	_i,F
;;     peep 7 - Removed redundant move
	BANKSEL	r0x1035
	MOVF	r0x1035,W
	BTFSC	STATUS,2
	GOTO	_00158_DS_
;	.line	176; "i2c_slave.c"	tdi_tdo(SSPBUF, c, 1);
	MOVLW	0x01
	MOVWF	STK01
	BANKSEL	_c
	MOVF	_c,W
	MOVWF	STK00
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	PAGESEL	_tdi_tdo
	CALL	_tdi_tdo
	PAGESEL	$
	GOTO	_00191_DS_
_00158_DS_:
;	.line	178; "i2c_slave.c"	c = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	BANKSEL	_c
	MOVWF	_c
;	.line	179; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00160_DS_:
;	.line	182; "i2c_slave.c"	tdi_out(SSPBUF, 8, 1);
	MOVLW	0x01
	MOVWF	STK01
	MOVLW	0x08
	MOVWF	STK00
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	PAGESEL	_tdi_out
	CALL	_tdi_out
	PAGESEL	$
;	.line	183; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00161_DS_:
;	.line	185; "i2c_slave.c"	if (i++)
	BANKSEL	_i
	MOVF	_i,W
	BANKSEL	r0x1035
	MOVWF	r0x1035
	BANKSEL	_i
	INCF	_i,F
;;     peep 7 - Removed redundant move
	BANKSEL	r0x1035
	MOVF	r0x1035,W
	BTFSC	STATUS,2
	GOTO	_00163_DS_
;	.line	186; "i2c_slave.c"	tdi_out(SSPBUF, c, 1);
	MOVLW	0x01
	MOVWF	STK01
	BANKSEL	_c
	MOVF	_c,W
	MOVWF	STK00
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	PAGESEL	_tdi_out
	CALL	_tdi_out
	PAGESEL	$
	GOTO	_00191_DS_
_00163_DS_:
;	.line	188; "i2c_slave.c"	c = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	BANKSEL	_c
	MOVWF	_c
;	.line	189; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00165_DS_:
;	.line	192; "i2c_slave.c"	tdi_tdo(SSPBUF, 8, 0);
	MOVLW	0x00
	MOVWF	STK01
	MOVLW	0x08
	MOVWF	STK00
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	PAGESEL	_tdi_tdo
	CALL	_tdi_tdo
	PAGESEL	$
;	.line	193; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00166_DS_:
;	.line	195; "i2c_slave.c"	if (i++)
	BANKSEL	_i
	MOVF	_i,W
	BANKSEL	r0x1035
	MOVWF	r0x1035
	BANKSEL	_i
	INCF	_i,F
;;     peep 7 - Removed redundant move
	BANKSEL	r0x1035
	MOVF	r0x1035,W
	BTFSC	STATUS,2
	GOTO	_00168_DS_
;	.line	196; "i2c_slave.c"	tdi_tdo(SSPBUF, c, 0);
	MOVLW	0x00
	MOVWF	STK01
	BANKSEL	_c
	MOVF	_c,W
	MOVWF	STK00
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	PAGESEL	_tdi_tdo
	CALL	_tdi_tdo
	PAGESEL	$
	GOTO	_00191_DS_
_00168_DS_:
;	.line	198; "i2c_slave.c"	c = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	BANKSEL	_c
	MOVWF	_c
;	.line	199; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00170_DS_:
;	.line	202; "i2c_slave.c"	tdi_out(SSPBUF, 8, 0);
	MOVLW	0x00
	MOVWF	STK01
	MOVLW	0x08
	MOVWF	STK00
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	PAGESEL	_tdi_out
	CALL	_tdi_out
	PAGESEL	$
;	.line	203; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00171_DS_:
;	.line	205; "i2c_slave.c"	if (i++)
	BANKSEL	_i
	MOVF	_i,W
	BANKSEL	r0x1035
	MOVWF	r0x1035
	BANKSEL	_i
	INCF	_i,F
;;     peep 7 - Removed redundant move
	BANKSEL	r0x1035
	MOVF	r0x1035,W
	BTFSC	STATUS,2
	GOTO	_00173_DS_
;	.line	206; "i2c_slave.c"	tdi_out(SSPBUF, c, 0);
	MOVLW	0x00
	MOVWF	STK01
	BANKSEL	_c
	MOVF	_c,W
	MOVWF	STK00
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	PAGESEL	_tdi_out
	CALL	_tdi_out
	PAGESEL	$
	GOTO	_00191_DS_
_00173_DS_:
;	.line	208; "i2c_slave.c"	c = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	BANKSEL	_c
	MOVWF	_c
;	.line	209; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00175_DS_:
;	.line	212; "i2c_slave.c"	TRISA = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	BANKSEL	_TRISA
	MOVWF	_TRISA
;	.line	213; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00176_DS_:
;	.line	215; "i2c_slave.c"	LATA = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	BANKSEL	_LATA
	MOVWF	_LATA
;	.line	216; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00177_DS_:
;	.line	218; "i2c_slave.c"	WPUA = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	MOVWF	_WPUA
;	.line	219; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00178_DS_:
;	.line	221; "i2c_slave.c"	PORTA = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	BANKSEL	_PORTA
	MOVWF	_PORTA
;	.line	222; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00179_DS_:
;	.line	225; "i2c_slave.c"	TRISB = SSPBUF | 0xC0;
	MOVLW	0xc0
	BANKSEL	_SSPBUF
	IORWF	_SSPBUF,W
	BANKSEL	_TRISB
	MOVWF	_TRISB
;	.line	226; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00180_DS_:
;	.line	228; "i2c_slave.c"	LATB = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	BANKSEL	_LATB
	MOVWF	_LATB
;	.line	229; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00181_DS_:
;	.line	231; "i2c_slave.c"	WPUB = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	MOVWF	_WPUB
;	.line	232; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00182_DS_:
;	.line	234; "i2c_slave.c"	PORTB = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	BANKSEL	_PORTB
	MOVWF	_PORTB
;	.line	235; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00183_DS_:
;	.line	238; "i2c_slave.c"	TRISC = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	BANKSEL	_TRISC
	MOVWF	_TRISC
;	.line	239; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00184_DS_:
;	.line	241; "i2c_slave.c"	LATC = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	BANKSEL	_LATC
	MOVWF	_LATC
;	.line	242; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00185_DS_:
;	.line	244; "i2c_slave.c"	WPUC = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	MOVWF	_WPUC
;	.line	245; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00186_DS_:
;	.line	247; "i2c_slave.c"	PORTC = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	BANKSEL	_PORTC
	MOVWF	_PORTC
;	.line	248; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00187_DS_:
;	.line	251; "i2c_slave.c"	RC2PPS = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	BANKSEL	_RC2PPS
	MOVWF	_RC2PPS
;	.line	252; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00188_DS_:
;	.line	254; "i2c_slave.c"	NCO1CON = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	BANKSEL	_NCO1CON
	MOVWF	_NCO1CON
;	.line	255; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00189_DS_:
;	.line	257; "i2c_slave.c"	NCO1CLK = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	BANKSEL	_NCO1CLK
	MOVWF	_NCO1CLK
;	.line	258; "i2c_slave.c"	break;
	GOTO	_00191_DS_
_00190_DS_:
;	.line	261; "i2c_slave.c"	t = SSPBUF;
	BANKSEL	_SSPBUF
	MOVF	_SSPBUF,W
	BANKSEL	_irq_t_1_24
	MOVWF	_irq_t_1_24
_00191_DS_:
;	.line	264; "i2c_slave.c"	SSP1CON1bits.CKP = 1;
	BANKSEL	_SSP1CON1bits
	BSF	_SSP1CON1bits,4
	GOTO	END_OF_INTERRUPT
;;shiftRight_Left2ResultLit:5323: shCount=1, size=1, sign=0, same=0, offr=0
_00224_DS_:
;	.line	267; "i2c_slave.c"	a = SSPBUF >> 1;
	BANKSEL	_SSPBUF
	LSRF	_SSPBUF,W
	BANKSEL	_irq_a_1_24
	MOVWF	_irq_a_1_24
;	.line	268; "i2c_slave.c"	i = 0;
	BANKSEL	_i
	CLRF	_i
;	.line	269; "i2c_slave.c"	if (SSP1STATbits.R_NOT_W) {		/* read */
	BANKSEL	_SSP1STATbits
	BTFSS	_SSP1STATbits,2
	GOTO	END_OF_INTERRUPT
;	.line	270; "i2c_slave.c"	switch (a & 0x2F) {
	MOVLW	0x2f
	BANKSEL	_irq_a_1_24
	ANDWF	_irq_a_1_24,W
	BANKSEL	r0x1035
	MOVWF	r0x1035
;;     peep 1 - test/jump to test/skip
	MOVF	r0x1035,W
	BTFSC	STATUS,2
	GOTO	_00195_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x04
	BTFSC	STATUS,2
	GOTO	_00197_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x05
	BTFSC	STATUS,2
	GOTO	_00197_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x06
	BTFSC	STATUS,2
	GOTO	_00198_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x07
	BTFSC	STATUS,2
	GOTO	_00199_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x08
	BTFSC	STATUS,2
	GOTO	_00201_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x09
	BTFSC	STATUS,2
	GOTO	_00201_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x0a
	BTFSC	STATUS,2
	GOTO	_00202_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x0b
	BTFSC	STATUS,2
	GOTO	_00203_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x20
	BTFSC	STATUS,2
	GOTO	_00204_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x21
	BTFSC	STATUS,2
	GOTO	_00205_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x22
	BTFSC	STATUS,2
	GOTO	_00206_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x23
	BTFSC	STATUS,2
	GOTO	_00207_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x24
	BTFSC	STATUS,2
	GOTO	_00208_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x25
	BTFSC	STATUS,2
	GOTO	_00209_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x26
	BTFSC	STATUS,2
	GOTO	_00210_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x27
	BTFSC	STATUS,2
	GOTO	_00211_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x28
	BTFSC	STATUS,2
	GOTO	_00212_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x29
	BTFSC	STATUS,2
	GOTO	_00213_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x2a
	BTFSC	STATUS,2
	GOTO	_00214_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x2b
	BTFSC	STATUS,2
	GOTO	_00215_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x2c
	BTFSC	STATUS,2
	GOTO	_00216_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x2e
	BTFSC	STATUS,2
	GOTO	_00217_DS_
	MOVF	r0x1035,W
;;     peep 1 - test/jump to test/skip
	XORLW	0x2f
	BTFSC	STATUS,2
	GOTO	_00218_DS_
	GOTO	_00219_DS_
_00195_DS_:
;	.line	272; "i2c_slave.c"	SSPBUF = buf[i++];
	BANKSEL	_i
	MOVF	_i,W
	BANKSEL	r0x1035
	MOVWF	r0x1035
	BANKSEL	_i
	INCF	_i,F
	BANKSEL	r0x1035
	MOVF	r0x1035,W
	ADDLW	(_buf + 0)
	MOVWF	r0x1035
	MOVLW	high (_buf + 0)
	BTFSC	STATUS,0
	ADDLW	0x01
	MOVWF	r0x1036
	MOVF	r0x1035,W
	MOVWF	FSR0L
	MOVF	r0x1036,W
	MOVWF	FSR0H
	MOVF	INDF0,W
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	273; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00197_DS_:
;	.line	277; "i2c_slave.c"	SSPBUF = v;
	BANKSEL	_v
	MOVF	_v,W
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	278; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00198_DS_:
;	.line	281; "i2c_slave.c"	SSPBUF = tdo_in(8, 1);
	MOVLW	0x01
	MOVWF	STK00
	MOVLW	0x08
	PAGESEL	_tdo_in
	CALL	_tdo_in
	PAGESEL	$
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	282; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00199_DS_:
;	.line	284; "i2c_slave.c"	SSPBUF = tdo_in(c, 1);
	MOVLW	0x01
	MOVWF	STK00
	BANKSEL	_c
	MOVF	_c,W
	PAGESEL	_tdo_in
	CALL	_tdo_in
	PAGESEL	$
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	285; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00201_DS_:
;	.line	289; "i2c_slave.c"	SSPBUF = v;
	BANKSEL	_v
	MOVF	_v,W
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	290; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00202_DS_:
;	.line	293; "i2c_slave.c"	SSPBUF = tdo_in(8, 0);
	MOVLW	0x00
	MOVWF	STK00
	MOVLW	0x08
	PAGESEL	_tdo_in
	CALL	_tdo_in
	PAGESEL	$
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	294; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00203_DS_:
;	.line	296; "i2c_slave.c"	SSPBUF = tdo_in(c, 0);
	MOVLW	0x00
	MOVWF	STK00
	BANKSEL	_c
	MOVF	_c,W
	PAGESEL	_tdo_in
	CALL	_tdo_in
	PAGESEL	$
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	297; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00204_DS_:
;	.line	300; "i2c_slave.c"	SSPBUF = TRISA;
	BANKSEL	_TRISA
	MOVF	_TRISA,W
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	301; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00205_DS_:
;	.line	303; "i2c_slave.c"	SSPBUF = LATA;
	BANKSEL	_LATA
	MOVF	_LATA,W
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	304; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00206_DS_:
;	.line	306; "i2c_slave.c"	SSPBUF = WPUA;
	BANKSEL	_WPUA
	MOVF	_WPUA,W
	MOVWF	_SSPBUF
;	.line	307; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00207_DS_:
;	.line	309; "i2c_slave.c"	SSPBUF = PORTA;
	BANKSEL	_PORTA
	MOVF	_PORTA,W
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	310; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00208_DS_:
;	.line	313; "i2c_slave.c"	SSPBUF = TRISB;
	BANKSEL	_TRISB
	MOVF	_TRISB,W
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	314; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00209_DS_:
;	.line	316; "i2c_slave.c"	SSPBUF = LATB;
	BANKSEL	_LATB
	MOVF	_LATB,W
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	317; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00210_DS_:
;	.line	319; "i2c_slave.c"	SSPBUF = WPUB;
	BANKSEL	_WPUB
	MOVF	_WPUB,W
	MOVWF	_SSPBUF
;	.line	320; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00211_DS_:
;	.line	322; "i2c_slave.c"	SSPBUF = PORTB;
	BANKSEL	_PORTB
	MOVF	_PORTB,W
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	323; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00212_DS_:
;	.line	326; "i2c_slave.c"	SSPBUF = TRISC;
	BANKSEL	_TRISC
	MOVF	_TRISC,W
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	327; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00213_DS_:
;	.line	329; "i2c_slave.c"	SSPBUF = LATC;
	BANKSEL	_LATC
	MOVF	_LATC,W
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	330; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00214_DS_:
;	.line	332; "i2c_slave.c"	SSPBUF = WPUC;
	BANKSEL	_WPUC
	MOVF	_WPUC,W
	MOVWF	_SSPBUF
;	.line	333; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00215_DS_:
;	.line	335; "i2c_slave.c"	SSPBUF = PORTC;
	BANKSEL	_PORTC
	MOVF	_PORTC,W
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	336; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00216_DS_:
;	.line	339; "i2c_slave.c"	SSPBUF = RC2PPS;
	BANKSEL	_RC2PPS
	MOVF	_RC2PPS,W
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	340; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00217_DS_:
;	.line	342; "i2c_slave.c"	SSPBUF = NCO1CON;
	BANKSEL	_NCO1CON
	MOVF	_NCO1CON,W
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	343; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00218_DS_:
;	.line	345; "i2c_slave.c"	SSPBUF = NCO1CLK;
	BANKSEL	_NCO1CLK
	MOVF	_NCO1CLK,W
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
;	.line	346; "i2c_slave.c"	break;
	GOTO	_00220_DS_
_00219_DS_:
;	.line	349; "i2c_slave.c"	SSPBUF = 0xA5;		/* default */
	MOVLW	0xa5
	BANKSEL	_SSPBUF
	MOVWF	_SSPBUF
_00220_DS_:
;	.line	351; "i2c_slave.c"	SSP1CON1bits.CKP = 1;
	BANKSEL	_SSP1CON1bits
	BSF	_SSP1CON1bits,4
END_OF_INTERRUPT:
	RETFIE	

;--------------------------------------------------------
; code
;--------------------------------------------------------
code_i2c_slave	code
;***
;  pBlock Stats: dbName = M
;***
;has an exit
;; Starting pCode block
S_i2c_slave__main	code
_main:
; 2 exit points
;	.line	370; "i2c_slave.c"	OSCCONbits.SPLLEN = 1;
	BANKSEL	_OSCCONbits
	BSF	_OSCCONbits,7
;	.line	371; "i2c_slave.c"	OSCCONbits.IRCF = 0b1110;	/* 8MHz */
	MOVF	(_OSCCONbits + 0),W
	ANDLW	0x87
	IORLW	0x70
;;     peep 2 - Removed redundant move
;	.line	372; "i2c_slave.c"	OSCCONbits.SCS = 0b00;	/* Fosc */
	MOVWF	(_OSCCONbits + 0)
	ANDLW	0xfc
	MOVWF	(_OSCCONbits + 0)
;	.line	375; "i2c_slave.c"	ANSELA = 0;
	BANKSEL	_ANSELA
	CLRF	_ANSELA
;	.line	376; "i2c_slave.c"	ANSELB = 0;
	CLRF	_ANSELB
;	.line	377; "i2c_slave.c"	ANSELC = 0;
	CLRF	_ANSELC
;	.line	380; "i2c_slave.c"	SCL_TRIS = 1;
	BANKSEL	_TRISBbits
	BSF	_TRISBbits,6
;	.line	381; "i2c_slave.c"	SDA_TRIS = 1;
	BSF	_TRISBbits,7
;	.line	383; "i2c_slave.c"	PPSLOCKbits.PPSLOCKED = 0;
	BANKSEL	_PPSLOCKbits
	BCF	_PPSLOCKbits,0
;	.line	385; "i2c_slave.c"	SSPDATPPS = SDA_PPSP;
	MOVLW	0x0f
	MOVWF	_SSPDATPPS
;	.line	386; "i2c_slave.c"	SDA_RPPS = SDA_PPS;
	MOVLW	0x11
	BANKSEL	_RB7PPS
	MOVWF	_RB7PPS
;	.line	388; "i2c_slave.c"	SSPCLKPPS = SCL_PPSP;
	MOVLW	0x0e
	BANKSEL	_SSPCLKPPS
	MOVWF	_SSPCLKPPS
;	.line	389; "i2c_slave.c"	SCL_RPPS = SCL_PPS;
	MOVLW	0x10
	BANKSEL	_RB6PPS
	MOVWF	_RB6PPS
;	.line	391; "i2c_slave.c"	SSP1STATbits.SMP = 1;
	BANKSEL	_SSP1STATbits
	BSF	_SSP1STATbits,7
;	.line	392; "i2c_slave.c"	SSP1STATbits.CKE = 1;
	BSF	_SSP1STATbits,6
;	.line	393; "i2c_slave.c"	SSP1CON1bits.SSPM = 0b0110;	/* 7bit slave mode */
	MOVF	(_SSP1CON1bits + 0),W
	ANDLW	0xf0
	IORLW	0x06
	MOVWF	(_SSP1CON1bits + 0)
;	.line	394; "i2c_slave.c"	SSP1CON1bits.SSPEN = 1;	/* enable I2C */
	BSF	_SSP1CON1bits,5
;	.line	395; "i2c_slave.c"	SSP1CON1bits.CKP = 1;	/* enable I2C clock */
	BSF	_SSP1CON1bits,4
;	.line	396; "i2c_slave.c"	SSP1CON2 = 0;
	CLRF	_SSP1CON2
;	.line	397; "i2c_slave.c"	SSP1CON2bits.SEN = 0;	/* clock stretching disabled */
	BCF	_SSP1CON2bits,0
;	.line	398; "i2c_slave.c"	SSP1CON3 = 0;
	CLRF	_SSP1CON3
;	.line	399; "i2c_slave.c"	SSP1CON3bits.BOEN = 1;	/* buffer override enabled */
	BSF	_SSP1CON3bits,4
;	.line	401; "i2c_slave.c"	SSPADD = 0b10000000;
	MOVLW	0x80
	MOVWF	_SSPADD
;	.line	402; "i2c_slave.c"	SSPMSK = 0b10100000;
	MOVLW	0xa0
	MOVWF	_SSPMSK
;	.line	404; "i2c_slave.c"	NCO1INCU = 0;
	BANKSEL	_NCO1INCU
	CLRF	_NCO1INCU
;	.line	405; "i2c_slave.c"	NCO1INCH = 0x80;
	MOVLW	0x80
	MOVWF	_NCO1INCH
;	.line	406; "i2c_slave.c"	NCO1INCL = 0x00;
	CLRF	_NCO1INCL
;	.line	408; "i2c_slave.c"	NCO1CON = 0b10100000;
	MOVLW	0xa0
	MOVWF	_NCO1CON
;	.line	412; "i2c_slave.c"	PIR1bits.SSP1IF = 0;	/* clear I2C irq */
	BANKSEL	_PIR1bits
	BCF	_PIR1bits,3
;	.line	413; "i2c_slave.c"	PIE1bits.SSP1IE = 1;	/* enable I2C irq */
	BANKSEL	_PIE1bits
	BSF	_PIE1bits,3
;	.line	415; "i2c_slave.c"	INTCONbits.PEIE = 1;	/* enable peripheral irq */
	BANKSEL	_INTCONbits
	BSF	_INTCONbits,6
;	.line	416; "i2c_slave.c"	INTCONbits.GIE = 1;		/* enable global irq */
	BSF	_INTCONbits,7
_00473_DS_:
;	.line	418; "i2c_slave.c"	while (1);
	GOTO	_00473_DS_
	RETURN	
; exit point of _main

;***
;  pBlock Stats: dbName = C
;***
;has an exit
;7 compiler assigned registers:
;   r0x1025
;   STK00
;   r0x1026
;   STK01
;   r0x1027
;   r0x1028
;   r0x1029
;; Starting pCode block
S_i2c_slave__tdi_tdo	code
_tdi_tdo:
; 2 exit points
;	.line	108; "i2c_slave.c"	void tdi_tdo(unsigned char val, unsigned char cnt, unsigned char tms)
	BANKSEL	r0x1025
	MOVWF	r0x1025
	MOVF	STK00,W
	MOVWF	r0x1026
	MOVF	STK01,W
	MOVWF	r0x1027
;	.line	110; "i2c_slave.c"	unsigned char bit = 0;
	CLRF	r0x1028
;	.line	112; "i2c_slave.c"	TMS_PORT = 0;
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,3
_00139_DS_:
;	.line	113; "i2c_slave.c"	while (--cnt) {
	BANKSEL	r0x1026
	DECF	r0x1026,W
;;     peep 2 - Removed redundant move
	MOVWF	r0x1029
	MOVWF	r0x1026
;;     peep 7 - Removed redundant move
	MOVF	r0x1029,W
	BTFSC	STATUS,2
	GOTO	_00141_DS_
;	.line	114; "i2c_slave.c"	v = (v << 1) | bit;
	BANKSEL	_v
	LSLF	_v,W
;;     peep 9b - Removed redundant move
	BANKSEL	r0x1029
	MOVWF	r0x1029
	IORWF	r0x1028,W
	BANKSEL	_v
	MOVWF	_v
;	.line	115; "i2c_slave.c"	TCK_PORT = 0;
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,2
;	.line	116; "i2c_slave.c"	if (val & 1) {
	BANKSEL	r0x1025
	BTFSS	r0x1025,0
	GOTO	_00137_DS_
;	.line	117; "i2c_slave.c"	TDI_PORT = 1;
	BANKSEL	_PORTCbits
	BSF	_PORTCbits,1
	GOTO	_00138_DS_
_00137_DS_:
;	.line	119; "i2c_slave.c"	TDI_PORT = 0;
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,1
_00138_DS_:
;	.line	121; "i2c_slave.c"	bit = TDO_PORT;
	BANKSEL	r0x1029
	CLRF	r0x1029
	BANKSEL	_PORTCbits
	BTFSS	_PORTCbits,0
	GOTO	_00001_DS_
	BANKSEL	r0x1029
	INCF	r0x1029,F
_00001_DS_:
	BANKSEL	r0x1029
	MOVF	r0x1029,W
	MOVWF	r0x1028
;;shiftRight_Left2ResultLit:5323: shCount=1, size=1, sign=0, same=1, offr=0
;	.line	122; "i2c_slave.c"	val = val >> 1;
	LSRF	r0x1025,F
;	.line	123; "i2c_slave.c"	TCK_PORT = 1;
	BANKSEL	_PORTCbits
	BSF	_PORTCbits,2
	GOTO	_00139_DS_
_00141_DS_:
;	.line	125; "i2c_slave.c"	v = (v << 1) | bit;
	BANKSEL	_v
	LSLF	_v,W
;;     peep 9b - Removed redundant move
	BANKSEL	r0x1026
	MOVWF	r0x1026
	IORWF	r0x1028,W
	BANKSEL	_v
	MOVWF	_v
;	.line	126; "i2c_slave.c"	TCK_PORT = 0;
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,2
;	.line	127; "i2c_slave.c"	if (val & 1) {
	BANKSEL	r0x1025
	BTFSS	r0x1025,0
	GOTO	_00143_DS_
;	.line	128; "i2c_slave.c"	TDI_PORT = 1;
	BANKSEL	_PORTCbits
	BSF	_PORTCbits,1
	GOTO	_00144_DS_
_00143_DS_:
;	.line	130; "i2c_slave.c"	TDI_PORT = 0;
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,1
_00144_DS_:
;	.line	132; "i2c_slave.c"	bit = TDO_PORT;
	BANKSEL	r0x1025
	CLRF	r0x1025
	BANKSEL	_PORTCbits
	BTFSS	_PORTCbits,0
	GOTO	_00002_DS_
	BANKSEL	r0x1025
	INCF	r0x1025,F
_00002_DS_:
	BANKSEL	r0x1025
	MOVF	r0x1025,W
	MOVWF	r0x1028
;	.line	133; "i2c_slave.c"	TMS_PORT = tms;
	RRF	r0x1027,W
	BTFSC	STATUS,0
	GOTO	_00003_DS_
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,3
_00003_DS_:
	BTFSS	STATUS,0
	GOTO	_00004_DS_
	BANKSEL	_PORTCbits
	BSF	_PORTCbits,3
_00004_DS_:
;	.line	134; "i2c_slave.c"	TCK_PORT = 1;
	BANKSEL	_PORTCbits
	BSF	_PORTCbits,2
;	.line	135; "i2c_slave.c"	v = v << 1 | bit;
	BANKSEL	_v
	LSLF	_v,W
;;     peep 9b - Removed redundant move
	BANKSEL	r0x1025
	MOVWF	r0x1025
	IORWF	r0x1028,W
	BANKSEL	_v
	MOVWF	_v
	RETURN	
; exit point of _tdi_tdo

;***
;  pBlock Stats: dbName = C
;***
;has an exit
;6 compiler assigned registers:
;   r0x102A
;   STK00
;   r0x102B
;   r0x102C
;   r0x102D
;   r0x102E
;; Starting pCode block
S_i2c_slave__tdo_in	code
_tdo_in:
; 2 exit points
;	.line	85; "i2c_slave.c"	unsigned char tdo_in(unsigned char cnt, unsigned char tms)
	BANKSEL	r0x102A
	MOVWF	r0x102A
	MOVF	STK00,W
	MOVWF	r0x102B
;	.line	87; "i2c_slave.c"	unsigned char val = 0;
	CLRF	r0x102C
;	.line	88; "i2c_slave.c"	unsigned char bit = 0;
	CLRF	r0x102D
;	.line	90; "i2c_slave.c"	TMS_PORT = 0;
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,3
_00129_DS_:
;	.line	91; "i2c_slave.c"	while (--cnt) {
	BANKSEL	r0x102A
	DECF	r0x102A,W
;;     peep 2 - Removed redundant move
	MOVWF	r0x102E
	MOVWF	r0x102A
;;     peep 7 - Removed redundant move
	MOVF	r0x102E,W
	BTFSC	STATUS,2
	GOTO	_00131_DS_
;	.line	92; "i2c_slave.c"	val = val << 1;
	LSLF	r0x102C,F
;	.line	93; "i2c_slave.c"	TCK_PORT = 0;
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,2
;	.line	94; "i2c_slave.c"	val = val | bit;
	BANKSEL	r0x102D
	MOVF	r0x102D,W
	IORWF	r0x102C,F
;	.line	95; "i2c_slave.c"	bit = TDO_PORT;
	CLRF	r0x102E
	BANKSEL	_PORTCbits
	BTFSS	_PORTCbits,0
	GOTO	_00005_DS_
	BANKSEL	r0x102E
	INCF	r0x102E,F
_00005_DS_:
	BANKSEL	r0x102E
	MOVF	r0x102E,W
	MOVWF	r0x102D
;	.line	96; "i2c_slave.c"	TCK_PORT = 1;
	BANKSEL	_PORTCbits
	BSF	_PORTCbits,2
	GOTO	_00129_DS_
_00131_DS_:
;	.line	98; "i2c_slave.c"	val = val << 1;
	BANKSEL	r0x102C
	LSLF	r0x102C,F
;	.line	99; "i2c_slave.c"	TCK_PORT = 0;
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,2
;	.line	100; "i2c_slave.c"	val = val | bit;
	BANKSEL	r0x102D
	MOVF	r0x102D,W
	IORWF	r0x102C,F
;	.line	101; "i2c_slave.c"	bit = TDO_PORT;
	CLRF	r0x102A
	BANKSEL	_PORTCbits
	BTFSS	_PORTCbits,0
	GOTO	_00006_DS_
	BANKSEL	r0x102A
	INCF	r0x102A,F
_00006_DS_:
	BANKSEL	r0x102A
	MOVF	r0x102A,W
	MOVWF	r0x102D
;	.line	102; "i2c_slave.c"	TMS_PORT = tms;
	RRF	r0x102B,W
	BTFSC	STATUS,0
	GOTO	_00007_DS_
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,3
_00007_DS_:
	BTFSS	STATUS,0
	GOTO	_00008_DS_
	BANKSEL	_PORTCbits
	BSF	_PORTCbits,3
_00008_DS_:
;	.line	103; "i2c_slave.c"	TCK_PORT = 1;
	BANKSEL	_PORTCbits
	BSF	_PORTCbits,2
;	.line	104; "i2c_slave.c"	val = val << 1 | bit;
	BANKSEL	r0x102C
	LSLF	r0x102C,W
;;     peep 9b - Removed redundant move
	MOVWF	r0x102A
	IORWF	r0x102D,W
;;     peep 2 - Removed redundant move
;	.line	105; "i2c_slave.c"	return val;
	MOVWF	r0x102C
	RETURN	
; exit point of _tdo_in

;***
;  pBlock Stats: dbName = C
;***
;has an exit
;6 compiler assigned registers:
;   r0x102F
;   STK00
;   r0x1030
;   STK01
;   r0x1031
;   r0x1032
;; Starting pCode block
S_i2c_slave__tdi_out	code
_tdi_out:
; 2 exit points
;	.line	62; "i2c_slave.c"	void tdi_out(unsigned char val, unsigned char cnt, unsigned char tms)
	BANKSEL	r0x102F
	MOVWF	r0x102F
	MOVF	STK00,W
	MOVWF	r0x1030
	MOVF	STK01,W
	MOVWF	r0x1031
;	.line	64; "i2c_slave.c"	TMS_PORT = 0;
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,3
_00119_DS_:
;	.line	65; "i2c_slave.c"	while (--cnt) {
	BANKSEL	r0x1030
	DECF	r0x1030,W
;;     peep 2 - Removed redundant move
	MOVWF	r0x1032
	MOVWF	r0x1030
;;     peep 7 - Removed redundant move
	MOVF	r0x1032,W
	BTFSC	STATUS,2
	GOTO	_00121_DS_
;	.line	66; "i2c_slave.c"	TCK_PORT = 0;
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,2
;	.line	67; "i2c_slave.c"	if (val & 1) {
	BANKSEL	r0x102F
	BTFSS	r0x102F,0
	GOTO	_00117_DS_
;	.line	68; "i2c_slave.c"	TDI_PORT = 1;
	BANKSEL	_PORTCbits
	BSF	_PORTCbits,1
	GOTO	_00118_DS_
_00117_DS_:
;	.line	70; "i2c_slave.c"	TDI_PORT = 0;
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,1
;;shiftRight_Left2ResultLit:5323: shCount=1, size=1, sign=0, same=1, offr=0
_00118_DS_:
;	.line	72; "i2c_slave.c"	val = val >> 1;
	BANKSEL	r0x102F
	LSRF	r0x102F,F
;	.line	73; "i2c_slave.c"	TCK_PORT = 1;
	BANKSEL	_PORTCbits
	BSF	_PORTCbits,2
	GOTO	_00119_DS_
_00121_DS_:
;	.line	75; "i2c_slave.c"	TCK_PORT = 0;
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,2
;	.line	76; "i2c_slave.c"	if (val & 1) {
	BANKSEL	r0x102F
	BTFSS	r0x102F,0
	GOTO	_00123_DS_
;	.line	77; "i2c_slave.c"	TDI_PORT = 1;
	BANKSEL	_PORTCbits
	BSF	_PORTCbits,1
	GOTO	_00124_DS_
_00123_DS_:
;	.line	79; "i2c_slave.c"	TDI_PORT = 0;
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,1
_00124_DS_:
;	.line	81; "i2c_slave.c"	TMS_PORT = tms;
	BANKSEL	r0x1031
	RRF	r0x1031,W
	BTFSC	STATUS,0
	GOTO	_00009_DS_
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,3
_00009_DS_:
	BTFSS	STATUS,0
	GOTO	_00010_DS_
	BANKSEL	_PORTCbits
	BSF	_PORTCbits,3
_00010_DS_:
;	.line	82; "i2c_slave.c"	TCK_PORT = 1;
	BANKSEL	_PORTCbits
	BSF	_PORTCbits,2
	RETURN	
; exit point of _tdi_out

;***
;  pBlock Stats: dbName = C
;***
;has an exit
;3 compiler assigned registers:
;   r0x1033
;   STK00
;   r0x1034
;; Starting pCode block
S_i2c_slave__tms_out	code
_tms_out:
; 2 exit points
;	.line	47; "i2c_slave.c"	void tms_out(unsigned char val, unsigned char cnt)
	BANKSEL	r0x1033
	MOVWF	r0x1033
	MOVF	STK00,W
	MOVWF	r0x1034
_00108_DS_:
;	.line	49; "i2c_slave.c"	while (cnt) {
	MOVLW	0x00
	BANKSEL	r0x1034
	IORWF	r0x1034,W
	BTFSC	STATUS,2
	GOTO	_00111_DS_
;	.line	50; "i2c_slave.c"	TCK_PORT = 0;
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,2
;	.line	51; "i2c_slave.c"	if (val & 1) {
	BANKSEL	r0x1033
	BTFSS	r0x1033,0
	GOTO	_00106_DS_
;	.line	52; "i2c_slave.c"	TMS_PORT = 1;
	BANKSEL	_PORTCbits
	BSF	_PORTCbits,3
	GOTO	_00107_DS_
_00106_DS_:
;	.line	54; "i2c_slave.c"	TMS_PORT = 0;
	BANKSEL	_PORTCbits
	BCF	_PORTCbits,3
;;shiftRight_Left2ResultLit:5323: shCount=1, size=1, sign=0, same=1, offr=0
_00107_DS_:
;	.line	56; "i2c_slave.c"	val = val >> 1;
	BANKSEL	r0x1033
	LSRF	r0x1033,F
;	.line	57; "i2c_slave.c"	TCK_PORT = 1;
	BANKSEL	_PORTCbits
	BSF	_PORTCbits,2
;	.line	58; "i2c_slave.c"	cnt--;
	BANKSEL	r0x1034
	DECF	r0x1034,F
	GOTO	_00108_DS_
_00111_DS_:
	RETURN	
; exit point of _tms_out


;	code size estimation:
;	  710+  252 =   962 instructions ( 2428 byte)

	end
