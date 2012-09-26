; Ramon sandoval LCD

	LIST P=PIC16F877
	__CONFIG _HS_OSC & _WDT_OFF & _PWRTE_ON & _CP_OFF & _LVP_OFF
	
	include <p16F877.inc>
	
;start of general purpose registers
gcount		Equ	0x20		;used in looping routines
count1		Equ	0x21		;used in delay routine
counta		Equ	0x22		;used in delay routine
gcount1		Equ	0x23
gcount2		Equ	0x24
posvar		Equ 0x25
pass1		Equ 0x26
pass2		Equ 0x27
pass3		Equ 0x28
pass4		Equ 0x29
pass5		Equ 0x2A

LCD_RS		Equ	2			;LCD handshake lines
Begin		Equ 1
LCD_E		Equ	0
gled		Equ 3

mA			Equ 0x41		;my Letters
mB			Equ 0x42
mC			Equ 0x43
mD			Equ 0x44
mE			Equ 0x45
mF			Equ 0x46
mG			Equ 0x47
mH			Equ 0x48
mI			Equ 0x49
mJ			Equ 0x4A
mK			Equ 0x4B
mL			Equ 0x4C
mM			Equ 0x4D
mN			Equ 0x4E
mO			Equ 0x4F
mP			Equ 0x50
mQ			Equ 0x51
mR			Equ 0x52
mS			Equ 0x53
mT			Equ 0x54
mU			Equ 0x55
mV			Equ 0x56
mW			Equ 0x57
mX			Equ 0x58
mY			Equ 0x59
mZ			Equ 0x5A
mEx			Equ 0x21
mSp			Equ 0x20

			org	0x00
			goto start

start

;------------------------------------------------------------
Initialise	clrf	PORTC
			clrf	PORTD
			clrf	PORTB
			clrf	pass1
			clrf	pass2
			clrf	pass3
			clrf	pass4
			clrf	pass5

SetPorts	bsf 	STATUS,	RP0		;select bank 1
			movlw	0x00			;make all C outputs
			movwf	TRISC
			movlw	0x02			;make all D outputs, except pin1
			movwf	TRISD
			movlw	0xFF			;make all B inputs
			movwf	TRISB
			bcf 	STATUS,	RP0		;select bank 0

			call	Delay255		;wait for LCD to settle

			movlw	0x3F
			movwf	PORTC
			call 	Pulse_e
			call	Delay100

			movlw	0x3F
			movwf	PORTC
			call 	Pulse_e
			call	Delay255

			movlw	0x3F
			movwf	PORTC
			call 	Pulse_e

			call	LCD_Init		;setup LCD
;------------------------------------------------------
;MAIN
;------------------------------------------------------

			call 	intro1

Message		btfss	PORTD, Begin
			goto	Message
			
			call	LCD_Clr
			call	intro2
				
			movlw	0x40
			movwf	gcount1
			movlw	0x03
			movwf	gcount2
			
Check		decfsz	gcount1
			goto	Check2

			movlw	0x40
			movwf	gcount1
			decfsz	gcount2
			goto	Check2

			btfss	PORTD, gled
			goto	turngon
			goto	turngoff

turngon		bsf		PORTD, gled
			movlw	0x40
			movwf	gcount1
			movlw	0x01
			movwf	gcount2
			goto 	Check2

turngoff	bcf		PORTD, gled
			movlw	0x40
			movwf	gcount1
			movlw	0x03
			movwf	gcount2
			goto 	Check2

			
Check2		call	position
			movf	PORTB, W
			
			btfss	PORTD, 3
			goto	Check
			
			btfss	pass1, 0
			goto	chkpass1
			btfss	pass2, 0
			goto	chkpass2
			btfss	pass3, 0
			goto	chkpass3
			btfss	pass4, 0
			goto	chkpass4
			goto	chkpass5

chkpass1	btfss	PORTB, 0
			goto	failure
			bsf		pass1, 0
			movlw	0xCB
			movwf	PORTC
			call	Pulse_e
			movlw	0x21
			call	prnt
			goto	turngoff
			goto 	Check
				
chkpass2	btfss	PORTB, 1
			goto	failure
			bsf		pass2, 0
			movlw	0xCC
			movwf	PORTC
			call	Pulse_e
			movlw	0x21
			call	prnt
			goto	turngoff
			goto 	Check

chkpass3	btfss	PORTB, 2
			goto	failure
			bsf		pass3, 0
			movlw	0xCD
			movwf	PORTC
			call	Pulse_e
			movlw	0x21
			call	prnt
			goto	turngoff
			goto 	Check

chkpass4	btfss	PORTB, 3
			goto	failure
			bsf		pass4, 0
			movlw	0xCE
			movwf	PORTC
			call	Pulse_e
			movlw	0x21
			call	prnt
			goto	turngoff
			goto 	Check

chkpass5	btfss	PORTB, 4
			goto	failure
			goto 	decoded

failure		call 	LCD_Clr
			call 	failmessage
			goto	Stop
	
decoded		call 	LCD_Clr
			call 	secret
			bcf		PORTD, gled

Stop		btfss	PORTD, 1
			goto	Stop			;endless loop
			goto	Initialise

;------------------------------------------------------------


;Subroutines and text tables

;LCD routines

;Initialise LCD
LCD_Init	movlw	0x38			;Function Set
			movwf	PORTC
			call	Pulse_e

			movlw	0x0F			;Set display on/off and cursor
			movwf	PORTC			;and blink on
			call	Pulse_e
			
			call	LCD_Clr			;clear display

			movlw	0x06			;Entry mode set
			movwf	PORTC		
			call	Pulse_e

			call	Delay255
			
			retlw	0x00

; command set routine

;----------------------------------------------------------

intro1		movlw	mP
			call 	prnt
			movlw	mR
			call 	prnt
			movlw	mE
			call 	prnt
			movlw	mS
			call 	prnt
			movlw	mS
			call 	prnt
			movlw	mSp
			call 	prnt

			movlw	mS
			call 	prnt
			movlw	mT
			call 	prnt
			movlw	mA
			call 	prnt
			movlw	mR
			call 	prnt
			movlw	mT
			call 	prnt
			retlw	0x00

intro2		movlw	mE
			call 	prnt
			movlw	mN
			call 	prnt
			movlw	mT
			call 	prnt
			movlw	mE
			call 	prnt
			movlw	mR
			call 	prnt
			movlw	mSp
			call 	prnt			


			movlw	mP
			call 	prnt
			movlw	mA
			call 	prnt
			movlw	mS
			call 	prnt
			movlw	mS
			call 	prnt
			movlw	mW
			call 	prnt
			movlw	mO
			call 	prnt
			movlw	mR
			call 	prnt
			movlw	mD
			call 	prnt

			call 	setpos
			call	flags

			retlw	0x00

;----------------------------------------------------------

failmessage	movlw	mF
			call 	prnt
			movlw	mA
			call 	prnt
			movlw	mI
			call 	prnt
			movlw	mL
			call 	prnt

			retlw	0x00

;----------------------------------------------------------

secret		movlw	mD
			call 	prnt
			movlw	mR
			call 	prnt
			movlw	mI
			call 	prnt
			movlw	mN
			call 	prnt
			movlw	mK
			call 	prnt
			movlw	mSp
			call 	prnt

			movlw	mM
			call 	prnt
			movlw	mO
			call 	prnt
			movlw	mR
			call 	prnt
			movlw	mE
			call 	prnt

			call	line2
			
			movlw	mO
			call 	prnt
			movlw	mV
			call 	prnt
			movlw	mA
			call 	prnt
			movlw	mL
			call 	prnt
			movlw	mT
			call 	prnt
			movlw	mI
			call 	prnt
			movlw	mN
			call 	prnt
			movlw	mE
			call 	prnt

			retlw	0x00

;----------------------------------------------------------

position	btfsc	PORTB, 0
			goto	p0
			btfsc	PORTB, 1
			goto	p1
			btfsc	PORTB, 2
			goto	p2
			btfsc	PORTB, 3
			goto	p3
			btfsc	PORTB, 4
			goto	p4
			btfsc	PORTB, 5
			goto	p5
			btfsc	PORTB, 6
			goto	p6
			btfsc	PORTB, 7
			goto	p7
			nop
			goto	pdef

pdef		movlw	0x0C
			goto	pdef2
pdef2		movwf	PORTC	
			call	Pulse_e	
			movlw	0x00
			movwf	posvar	
			nop
			nop
			nop
			call	Delay5
			nop
			call	Delay5
			nop
			retlw	0x00
			
p0			movlw	0xC7
			goto	cursset
p1			movlw	0xC6
			goto	cursset
p2			movlw	0xC5
			goto	cursset
p3			movlw	0xC4
			goto	cursset
p4			movlw	0xC3
			goto	cursset
p5			movlw	0xC2
			goto	cursset
p6			movlw	0xC1
			goto	cursset
p7			movlw	0xC0
			goto	cursset

cursset		movwf	PORTC
			call	Pulse_e
			movf	PORTC, W
			movwf	posvar
			movlw	0x0F
			movwf	PORTC	
			call	Pulse_e
			retlw	0x00

setpos		movlw	0xC0
			movwf	PORTC
			call	Pulse_e
			movlw	mO
			call	prnt
			movlw	mO
			call	prnt
			movlw	mO
			call	prnt
			movlw	mO
			call	prnt
			movlw	mO
			call	prnt
			movlw	mO
			call	prnt
			movlw	mO
			call	prnt
			movlw	mO
			call	prnt
			retlw	0x00

flags		movlw	0xCB
			movwf	PORTC
			call	Pulse_e
			movlw	0x2E
			call	prnt
			movlw	0x2E
			call	prnt
			movlw	0x2E
			call	prnt
			movlw	0x2E
			call	prnt
			movlw	0x2E
			call	prnt
			retlw	0x00

;--------------------------------------------------------

prnt		movwf	PORTC
			bsf		PORTD, LCD_RS
			call 	Pulse_e
			bcf		PORTD, LCD_RS
			retlw	0x00

line2		movlw	0xC0
			movwf	PORTC
			call	Pulse_e
			retlw	0x00

LCD_Clr		movlw	0x01			;Clear display
			movwf	PORTC
			call	Pulse_e
			retlw	0x00

Pulse_e		bsf		PORTD, LCD_E
			call	Delay5
			bcf		PORTD, LCD_E
			call	Delay5
			retlw	0x00

;--------------------------------------------------------

Goff		movlw	0xFF
			movwf	gcount
goffcount	call	Delay255
			call	Delay255
			call	Delay255
			decfsz	gcount, f		
			goto	goffcount
			retlw	0x00

Gon			movlw	0xFF
			movwf	gcount
goncount	call	Delay255
			decfsz	gcount, f		
			goto	goncount
			retlw	0x00

Delay255	movlw	0xff		;delay 255 mS
			goto	d0
			
Delay100	movlw	.100		;delay 100mS
			goto	d0
			
Delay50		movlw	.50		;delay 50mS
			goto	d0
			
Delay20		movlw	.20		;delay 20mS
			goto	d0
			
Delay5		movlw	0x05		;delay 5.000 ms (4 MHz clock)

d0			movwf	count1
d1			movlw	0xC8			;delay 1mS
			movwf	counta

Delay_0		decfsz	counta, f
			goto	Delay_0
	
			decfsz	count1	,f
			goto	d1
			retlw	0x00



;end of LCD routines

		end      
