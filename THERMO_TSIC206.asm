
.equ SENSOR_EINGANG_PORT	= PIND					; SIGNAL-PORT		
.equ SENSOR_EINGANG_MASKE	= 0b00010000			; SIGNAL-PIN 4		
.equ SENSOR_EINGANG_MASKE2	= 0b00100000			; SIGNAL-PIN 5		
.equ SENSOR_EINGANG_MASKE3	= 0b01000000			; SIGNAL-PIN 6		
.equ SENSOR_EINGANG_MASKE4	= 0b10000000			; SIGNAL-PIN 7	
.equ SENSOR_EINGANG_MASKE5	= 0b00001000			; SIGNAL-PIN 3
	
.equ SENSOR_V_PORT			= PORTC		; SPANNUNG-PORT		
.equ SENSOR_V_PIN			= 1			; SPANNUNG-PIN	
.equ SENSOR_OFFSET			= 0			; OFFSETWERT

sensor_abfragen:
sts adr_TEMPERATURDATEN_L, NULL
sts adr_TEMPERATURDATEN_H, NULL
ldi r16, SENSOR_EINGANG_MASKE
sts sensor_eingang, r16
ldi r16, 0
sts sensor_nummer, r16
rcall SENSOR_TSIC
sts adr_TEMPERATURDATEN_L, temp1
sts adr_TEMPERATURDATEN_H, temp2
ret

sensor_abfragen2:
sts adr_TEMPERATURDATEN_L+1, NULL
sts adr_TEMPERATURDATEN_H+1, NULL
ldi r16, SENSOR_EINGANG_MASKE2
sts sensor_eingang, r16
ldi r16, 1
sts sensor_nummer, r16
rcall SENSOR_TSIC
sts adr_TEMPERATURDATEN_L+1, temp1
sts adr_TEMPERATURDATEN_H+1, temp2
ret

sensor_abfragen3:
sts adr_TEMPERATURDATEN_L+2, NULL
sts adr_TEMPERATURDATEN_H+2, NULL
ldi r16, SENSOR_EINGANG_MASKE3
sts sensor_eingang, r16
ldi r16, 2
sts sensor_nummer, r16
rcall SENSOR_TSIC
sts adr_TEMPERATURDATEN_L+2, temp1
sts adr_TEMPERATURDATEN_H+2, temp2
ret

sensor_abfragen4:
sts adr_TEMPERATURDATEN_L+3, NULL
sts adr_TEMPERATURDATEN_H+3, NULL
ldi r16, SENSOR_EINGANG_MASKE4
sts sensor_eingang, r16
ldi r16, 3
sts sensor_nummer, r16
rcall SENSOR_TSIC
sts adr_TEMPERATURDATEN_L+3, temp1
sts adr_TEMPERATURDATEN_H+3, temp2
ret

sensor_abfragen5:
sts adr_TEMPERATURDATEN_L+4, NULL
sts adr_TEMPERATURDATEN_H+4, NULL
ldi r16, SENSOR_EINGANG_MASKE5
sts sensor_eingang, r16
ldi r16, 4
sts sensor_nummer, r16
rcall SENSOR_TSIC
sts adr_TEMPERATURDATEN_L+4, temp1
sts adr_TEMPERATURDATEN_H+4, temp2
ret


; ##############################################################################
; ##############################################################################
; ##############################################################################
SENSOR_TSIC:
	; INITIALISIERUNG		

//	STS(adr_TEMPERATUR_L),NULL
//	STS(adr_TEMPERATUR_H),NULL
/*ldi zl, low(adr_TEMPERATURDATEN_L)
ldi zh, high(adr_TEMPERATURDATEN_L)
lds r16, sensor_nummer
add zl, r16
adc zh, NULL
st z, NULL

ldi zl, low(adr_TEMPERATURDATEN_H)
ldi zh, high(adr_TEMPERATURDATEN_H)
lds r16, sensor_nummer
add zl, r16
adc zh, NULL
st z, NULL*/

	clr temp1
	clr temp2

	STS(adr_STROBE),NULL
	clr temp6					; PARITÄT						
	ldi temp8,15				;(STROBE typisch bei 1MHz=15)	
	clr temp9					;(Impulslänge)					
;===============================================================================
	; SENSOR-SPANNUNG ein	
//	sbi (SENSOR_V_PORT),(SENSOR_V_PIN)
	rcall wait5ms
	; sendet Sensor DATEN ?	
	rcall SENSOR_DATEN_SUCHEN	; OUT temp
	tst temp
	brne SENSOR_TSIC_ABFRAGEN_START
	; ERROR (keine DATEN)
//	cbi PORTD,LED_D_ROT			; ROT	
	ret
;===============================================================================
SENSOR_TSIC_ABFRAGEN_START:
	; auf Sendepause warten 
	rcall SENSOR_PAUSE_SUCHEN
;===============================================================================
	; GELB 					
//	cbi PORTD,LED_D_GELB
	; Interrupts sperren	
//	CLI	
	; START-BIT (STROBE)	
	rcall SENSOR_PIN_ABFRAGEN	; out temp	
	STS(adr_STROBE),temp9		; STROBE speichern im SRAM		
	mov temp8,temp9				; STROBE speichern im Register	
	; Bit-7 (MSB)	
	rcall SENSOR_PIN_ABFRAGEN	; out temp	
	STS(adr_BIT_A),temp			; für TEST-Darstellung
	LSL temp
	ROL temp2
	; Bit-6			
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	STS(adr_BIT_B),temp
	LSL temp
	ROL temp2
	; Bit-5			
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	STS(adr_BIT_C),temp
	LSL temp
	ROL temp2
	; Bit-4			
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	STS(adr_BIT_D),temp
	LSL temp
	ROL temp2
;-------------------------------------------------------------------------------
	; ERROR-CHECK (Bit 7 bis 4 muss NULL sein
	mov temp,temp2
	andi temp,0b11111000
	tst temp
	breq SENSOR_TSIC_ABFRAGEN_NULL_OK
//	cbi PORTD,LED_D_ROT			; ROT	
SENSOR_TSIC_ABFRAGEN_NULL_OK:
;-------------------------------------------------------------------------------
	; Bit-3			
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	STS(adr_BIT_E),temp
	LSL temp
	ROL temp2
	; Bit-2			
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	STS(adr_BIT_F),temp
	LSL temp
	ROL temp2
	; Bit-1			
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	STS(adr_BIT_G),temp
	LSL temp
	ROL temp2
	; Bit-0	(LSB)	
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	STS(adr_BIT_H),temp
	LSL temp
	ROL temp2
	; PARITY-BIT	
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	STS(adr_BIT_I),temp
;-------------------------------------------------------------------------------
	; PARITÄTS-PRÜFUNG		
	mov temp6,temp2
	rcall BERECHNUNG_SENSOR_PARITAET	; inp/out: temp6
	cp temp6,temp
	breq SENSOR_TSIC_ABFRAGEN_P1_OK
//	cbi PORTD,LED_D_ROT		; ROT		
SENSOR_TSIC_ABFRAGEN_P1_OK:
;===============================================================================
	; START-BIT		
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	; Bit-7 (MSB)	
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	STS(adr_BIT_J),temp
	LSL temp
	ROL temp1
	; Bit-6			
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	STS(adr_BIT_K),temp
	LSL temp
	ROL temp1
	; Bit-5			
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	STS(adr_BIT_L),temp
	LSL temp
	ROL temp1
	; Bit-4			
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	STS(adr_BIT_M),temp
	LSL temp
	ROL temp1
	; Bit-3			
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	STS(adr_BIT_N),temp
	LSL temp
	ROL temp1
	; Bit-2			
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	STS(adr_BIT_O),temp
	LSL temp
	ROL temp1
	; Bit-1			
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	STS(adr_BIT_P),temp
	LSL temp
	ROL temp1
	; Bit-0	(LSB)	
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	STS(adr_BIT_Q),temp
	LSL temp
	ROL temp1
	; PARITY-BIT	
	rcall SENSOR_PIN_ABFRAGEN	; out temp
	STS(adr_BIT_R),temp
;-------------------------------------------------------------------------------
	; PARITÄTS-PRÜFUNG		
	mov temp6,temp1
	rcall BERECHNUNG_SENSOR_PARITAET	; inp/out: temp6
	cp temp6,temp
	breq SENSOR_TSIC_ABFRAGEN_P2_OK
//	cbi PORTD,LED_D_ROT		; ROT		
SENSOR_TSIC_ABFRAGEN_P2_OK:
;-------------------------------------------------------------------------------
	; Interrupts freigeben	
//	sei	
	; GELB 					
//	sbi PORTD,LED_D_GELB
	; SENSOR-SPANNUNG aus	
	rcall wait5ms
//	rcall wait5ms
//	cbi (SENSOR_V_PORT),(SENSOR_V_PIN)
	; ZWISCHENERGEBNIS		
///	STS(adr_TEMPERATURDATEN_L),temp1
//	STS(adr_TEMPERATURDATEN_H),temp2

/*ldi zl, low(adr_TEMPERATURDATEN_L)
ldi zh, high(adr_TEMPERATURDATEN_L)
lds r23, sensor_nummer
add zl, r23
adc zh, NULL
st z, temp1

ldi zl, low(adr_TEMPERATURDATEN_H)
ldi zh, high(adr_TEMPERATURDATEN_H)
lds r23, sensor_nummer
add zl, r23
adc zh, NULL
st z, temp2*/

	; BERECHNUNG Temperatur	
//	rcall SENSOR_BERECHNUNG
	; BERECHNUNG OFFSET		
	//rcall SENSOR_BERECHNUNG_OFFSET
	; Temperatur speichern	
	//STS(adr_TEMPERATUR_L),temp1
	//STS(adr_TEMPERATUR_H),temp2
ret


; ##############################################################################
; ##############################################################################
; ##############################################################################
; nach einem Pegelwechsel suchen												
SENSOR_DATEN_SUCHEN:
    lds r4, sensor_eingang
	; Schleifen-Initialisierung	
	ldi ZL,LOW (65535/FAKTOR)
	ldi ZH,HIGH(65535/FAKTOR)
	; SCHLEIFE					
SENSOR_DATEN_SUCHEN_L:
//	WDR
	sbiw ZL,1
	tst ZL
	brne SENSOR_DATEN_SUCHEN_L_W
	tst ZH
	brne SENSOR_DATEN_SUCHEN_L_W
	; ERROR			
	clr temp
	ret
SENSOR_DATEN_SUCHEN_L_W:
	in r3, SENSOR_EINGANG_PORT
	and r3, r4
    cp r3, NULL
	brne SENSOR_DATEN_SUCHEN_L
//	sbic (SENSOR_EINGANG_PORT),(SENSOR_EINGANG_PIN)        ; "skip if bit ..."
//	rjmp SENSOR_DATEN_SUCHEN_L	
;-------------------------------------------------------------------------------
	; Schleifen-Initialisierung	
	ldi ZL,LOW (65535/FAKTOR)
	ldi ZH,HIGH(65535/FAKTOR)
	; SCHLEIFE					
SENSOR_DATEN_SUCHEN_H:
//	WDR
	sbiw ZL,1
	tst ZL
	brne SENSOR_DATEN_SUCHEN_H_W
	tst ZH
	brne SENSOR_DATEN_SUCHEN_H_W
	; ERROR			
	clr temp
	ret
SENSOR_DATEN_SUCHEN_H_W:
	in r3, SENSOR_EINGANG_PORT
	and r3, r4
    cp r3, NULL
	breq SENSOR_DATEN_SUCHEN_H
//	sbis (SENSOR_EINGANG_PORT),(SENSOR_EINGANG_PIN)        ; "skip if bit ..."
//	rjmp SENSOR_DATEN_SUCHEN_H	
;-------------------------------------------------------------------------------
	; Freigabe		
	ldi temp,1
ret


; ##############################################################################
; ##############################################################################
; ##############################################################################
; warten auf Sendepause des Sensors (ca.40ms)									
; hiermit kann die Zeit der Interruptsperrung verkürzt werden	
SENSOR_PAUSE_SUCHEN:
	ldi ZL,0 // 196
	ldi ZH,40 //   10
	lds r4, sensor_eingang

SENSOR_PAUSE_SUCHEN_s:
	; Warteschleife, wenn PIN "LOW" ist
	in r3, SENSOR_EINGANG_PORT
	and r3, r4
    cp r3, NULL
	breq SENSOR_PAUSE_SUCHEN
//	sbis (SENSOR_EINGANG_PORT),(SENSOR_EINGANG_PIN)       ; "skip if bit ..."	
//	rjmp SENSOR_PAUSE_SUCHEN
	dec ZL
	brne SENSOR_PAUSE_SUCHEN_s
	dec ZH
	brne SENSOR_PAUSE_SUCHEN_s
ret


; ##############################################################################
; ##############################################################################
; ##############################################################################
; INP: temp8 (STROBE) 															
; OUT: temp + temp9(Impulslänge)												
SENSOR_PIN_ABFRAGEN:
	clr temp9
	lds r4, sensor_eingang
SENSOR_PIN_ABFRAGEN_S:
	; Warteschleife, wenn PIN "HIGH" ist			
    in r3, SENSOR_EINGANG_PORT
	and r3, r4
    cp r3, NULL
	brne SENSOR_PIN_ABFRAGEN_S
//	sbic (SENSOR_EINGANG_PORT),(SENSOR_EINGANG_PIN)        ; "skip if bit ..."
//	rjmp SENSOR_PIN_ABFRAGEN_S

SENSOR_PIN_ABFRAGEN_Z:
	; Warteschleife, wenn PIN "LOW" ist	
			
	inc temp9 					; ZÄHLER+1
	in r3, SENSOR_EINGANG_PORT
	and r3, r4
    cp r3, NULL
	breq SENSOR_PIN_ABFRAGEN_Z
	//sbis (SENSOR_EINGANG_PORT),(SENSOR_EINGANG_PIN)        ; "skip if bit ..."	
	//rjmp SENSOR_PIN_ABFRAGEN_Z

	; VERGLEICH	mit STROBE-WERT					
	cp temp9,temp8
	brlo SENSOR_LOGIC_HIGH
	clr temp
	ret
SENSOR_LOGIC_HIGH:
	ldi temp,255
ret


.DSEG			
adr_STROBE: .BYTE 1			; SENSOR-STROBE				
adr_TEMPERATURDATEN_L: .BYTE 5			; SENSOR-DATENWERT			
adr_TEMPERATURDATEN_H: .BYTE 5
//adr_TEMPERATUR_L: .BYTE 1			; SENSOR-Temperaturwert		
//adr_TEMPERATUR_H: .BYTE 1
adr_BIT_A: .BYTE 1		; Darstellung der Bitwerte	
adr_BIT_B: .BYTE 1
adr_BIT_C: .BYTE 1
adr_BIT_D: .BYTE 1
adr_BIT_E: .BYTE 1
adr_BIT_F: .BYTE 1
adr_BIT_G: .BYTE 1
adr_BIT_H: .BYTE 1
adr_BIT_I: .BYTE 1
adr_BIT_J: .BYTE 1
adr_BIT_K: .BYTE 1
adr_BIT_L: .BYTE 1
adr_BIT_M: .BYTE 1
adr_BIT_N: .BYTE 1
adr_BIT_O: .BYTE 1
adr_BIT_P: .BYTE 1
adr_BIT_Q: .BYTE 1
adr_BIT_R: .BYTE 1
sensor_eingang: .BYTE 1
sensor_nummer: .BYTE 1
.CSEG


; ##############################################################################
; ##############################################################################
; ##############################################################################
; INP: temp1 + temp2															
; OUT: temp1 + temp2															
;===============================================================================
; BERECHNUNG der Temperatur aus den Temperaturdaten								
; Formel:	°C = WERT x 2000/2048-500											
;	-50°C	   0 (0x000)														
;	-10°C	 409 (0x199)														
;	  0°C	 512 (0x200)														
;	 25°C	 767 (0x2FF)														
;	 60°C	1125 (0x465)														
;	125°C	1790 (0x6FE)														
;	150°C	2047 (0x7FF)														
SENSOR_BERECHNUNG:
	clr temp3
	mov temp4,temp1
	mov temp5,temp2
	clr temp6
	; x 2000					
	ldi ZL,LOW (125-1)
	ldi ZH,HIGH(125-1)
SENSOR_BERECHNUNG_SCHLEIFE:
	add temp1,temp4
	adc temp2,temp5
	adc temp3,temp6
	sbiw ZL,1
	tst ZL
	brne SENSOR_BERECHNUNG_SCHLEIFE
	tst ZH
	brne SENSOR_BERECHNUNG_SCHLEIFE
	; :2048		
	mov temp4, temp1
	mov temp5, temp2
	mov temp6, temp3
lsl temp1
lsl temp2
lsl temp3
sbrc temp4, 7
add temp2, EINS
sbrc temp5, 7
add temp3, EINS

	mov temp1,temp2	; :256
	mov temp2,temp3
					
	/*mov temp1,temp2	; :256
	mov temp2,temp3
	LSR temp2		; :2	
	ROR temp1
	LSR temp2		; :2	
	ROR temp1
	LSR temp2		; :2	
	ROR temp1*/
	; -500						
	ldi temp3,low (-500)
	ldi temp4,high(-500)
	add temp1,temp3
	adc temp2,temp4
ret
; ##############################################################################
; ##############################################################################
; ##############################################################################
; Temperaturoffset																
; INP: temp1 + temp2															
; OUT: temp1 + temp2															
SENSOR_BERECHNUNG_OFFSET:
	ldi temp3,LOW (SENSOR_OFFSET)
	ldi temp4,HIGH(SENSOR_OFFSET)
	add temp1,temp3
	adc temp2,temp4	
ret
; ##############################################################################
; ##############################################################################
; ##############################################################################
; INP: temp6																	
; OUT: temp6																	
BERECHNUNG_SENSOR_PARITAET:
	push temp	; sichern			
	clr temp	

	; 1xrechts ==> Carry rollt raus
	LSR temp6
	rcall BERECHNUNG_SENSOR_PARITAET_Z
	LSR temp6
	rcall BERECHNUNG_SENSOR_PARITAET_Z
	LSR temp6
	rcall BERECHNUNG_SENSOR_PARITAET_Z
	LSR temp6
	rcall BERECHNUNG_SENSOR_PARITAET_Z
	LSR temp6
	rcall BERECHNUNG_SENSOR_PARITAET_Z
	LSR temp6
	rcall BERECHNUNG_SENSOR_PARITAET_Z
	LSR temp6
	rcall BERECHNUNG_SENSOR_PARITAET_Z
	LSR temp6
	rcall BERECHNUNG_SENSOR_PARITAET_Z
	; Bitmuster 	
	andi temp,0b00000001
	; gleich NULL ?	
	tst temp
	brne BERECHNUNG_SENSOR_PARITAET_1
BERECHNUNG_SENSOR_PARITAET_0:
	; Ergebnis 		
	ldi temp6,0
	pop temp ; wieder herstellen	
	ret
BERECHNUNG_SENSOR_PARITAET_1:
	; Ergebnis 		
	ldi temp6,255
	pop temp ; wieder herstellen	
	ret
;-------------------------------------------------------------------------------
BERECHNUNG_SENSOR_PARITAET_Z:
	brcs BERECHNUNG_SENSOR_PARITAET_ZZ
	ret
BERECHNUNG_SENSOR_PARITAET_ZZ:
	; Carrys zählen	
	inc temp
ret
; ##############################################################################
; ##############################################################################
; ##############################################################################

