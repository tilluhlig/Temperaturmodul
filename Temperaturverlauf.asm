.equ SENSOR_ID = 0b00100000   // 1 - 15

.include "m8def.inc"
; REGISTER										
.def NULL 	= R10
.def EINS 	= R11
.def VOLL	= R12

.def Sensor = R15

.def temp 	= R16
.def temp1 	= R17
.def temp2 	= R18
.def temp3 	= R19
.def temp4 	= R20
.def temp5 	= R21
.def temp6 	= R22
//.def temp7 	= R23
.def temp8 	= R24
.def temp9 	= R25

.equ FAKTOR = 1

.equ XTAL = 1000000 * FAKTOR
.equ F_CPU = 1000000 * FAKTOR                            ; Systemtakt in Hz
.equ BAUD  = 62500  		                             ; Baudrate

; Berechnungen
.equ UBRR_VAL   = ((F_CPU+BAUD*8)/(BAUD*16)-1)  ; clever runden
.equ BAUD_REAL  = (F_CPU/(16*(UBRR_VAL+1)))      ; Reale Baudrate
.equ BAUD_ERROR = ((BAUD_REAL*1000)/BAUD-1000)  ; Fehler in Promille
 
.if ((BAUD_ERROR>10) || (BAUD_ERROR<-10))       ; max. +/-10 Promille Fehler
  .error "Systematischer Fehler der Baudrate grösser 1 Prozent und damit zu hoch!"
.endif

.macro input
  .if @1 < 0x40
	in	@0, @1
  .else
  	lds	@0, @1
  .endif
.endm

.macro output
  .if @0 < 0x40
	out	@0, @1
  .else
	sts	@0, @1
  .endif
.endm

.macro bbis ;port,bit,target
  .if @0 < 0x20
 	sbic	@0, @1
	rjmp	@2
  .elif @0 < 0x40
	in		r2, @0
	sbrc	r2, @1
	rjmp	@2
  .else
	lds		r2, @0
	sbrc	r2, @1
	rjmp	@2
  .endif
.endm



.org 0x0000
rjmp reset

//.include "sram/sram_makros.asm"

.include "eeprom/eeprom.asm"

.include "sonstiges.asm"

reset:

; STARTWERTE

// Sensor ID einstellen
ldi temp, SENSOR_ID
mov Sensor, temp
										
	; NULL				
	clr NULL
	; EINS				
	ldi temp,1
	mov EINS,temp
	; VOLL				
	ldi temp,255
	mov VOLL,temp
	
	
 ;RS232 initialisieren
	/*ldi r16, LOW(UBRR_VAL)
	output UBRRL,r16 ;UBRR0L
	ldi r16, HIGH(UBRR_VAL)
	output UBRRH,r16 ; UBRR0H*/
	/*ldi r16,(1<<UCSZ01)|(1<<UCSZ00) ; Frame-Format: 8 Bit // 8 bit, 1 stop
	output UCSR0C,r16 ; UCSR0C
	ldi r16, (1<<RXEN0)|(1<<TXEN0)
	output UCSR0B, r16*/
 ;RS232 initialisieren
	ldi r16, LOW(UBRR_VAL)
	out UBRRL,r16
	ldi r16, HIGH(UBRR_VAL)
	out UBRRH,r16
	ldi r16, (1<<URSEL)|(3<<UCSZ0) ; Frame-Format: 8 Bit // 8 bit, 1 stop
	out UCSRC,r16
	sbi UCSRB, RXEN			; RX (Empfang) aktivieren
	sbi UCSRB, TXEN			; TX (Senden)  aktivieren
	

	; Init
          ldi      temp, HIGH(RAMEND)     ; Stackpointer initialisieren
          out      SPH, temp
          ldi      temp, LOW(RAMEND)
          out      SPL, temp

; IO einstellen
ldi temp, 0b00000110
out DDRB, temp
ldi temp, 0b00000001
out PORTB, temp

ldi temp, 0b00110011
out DDRC, temp
ldi temp, 0b00001101
out PORTC, temp

ldi temp, 0b00000000
out DDRD, temp
ldi temp, 0b00000100
out PORTD, temp	


out  ADCSRA, NULL
cli

rcall eeprom_init

do:

//bbis     UCSR0A, RXC0, sprung1 
sbis   UCSRA, RXC                
rjmp     no_receive
//sprung1:
in       temp, UDR
cli 

// ermittle adresslänge
cpi temp, 'D'
breq send13
rjmp no_send13
send13:
ldi r16, 0
sts eeprom_id, r16
rcall eeprom_ermittle_adresslaenge
rcall send_register
no_send13:

no_receive:

rjmp do


send_register:
//push temp
/*mov temp, @0
swap temp
and temp, Sensor

	serout_string_wait:
    sbis    UCSRA,UDRE
    rjmp    serout_string_wait
    out     UDR, temp

	mov temp, @0
and temp, Sensor

	serout_string_wait2:
    sbis    UCSRA,UDRE
    rjmp    serout_string_wait2
    out     UDR, temp*/

	serout_string_wait2:
   // bbis    UCSR0A,UDRE0, over_send_register
	sbis UCSRA,UDRE
    rjmp    serout_string_wait2
	over_send_register:
    output     UDR, r16 ;UDR0
//	pop temp
ret


