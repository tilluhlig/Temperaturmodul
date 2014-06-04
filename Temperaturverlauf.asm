.equ SENSOR_ID = 0b00100000   // 1 - 15

//.include "m88def.inc"
; REGISTER                                        
.def NULL     = R10
.def EINS     = R11
.def VOLL    = R12

.def Sensor = R15

.def temp     = R16
.def temp1     = R17
.def temp2     = R18
.def temp3     = R19
.def temp4     = R20
.def temp5     = R21
.def temp6     = R22
//.def temp7     = R23
.def temp8     = R24
.def temp9     = R25

.equ FAKTOR = 1

.equ XTAL = 1000000 * FAKTOR
.equ F_CPU = 1000000 * FAKTOR                            ; Systemtakt in Hz
.equ BAUD  = 62500                                      ; Baudrate

.equ LED_V_PORT                = PORTC        ; SPANNUNG-PORT        
.equ LED_V_PIN                = 0            ; SPANNUNG-PIN
        
; Berechnungen
.equ UBRR_VAL   = ((F_CPU+BAUD*8)/(BAUD*16)-1)  ; clever runden
.equ BAUD_REAL  = (F_CPU/(16*(UBRR_VAL+1)))      ; Reale Baudrate
.equ BAUD_ERROR = ((BAUD_REAL*1000)/BAUD-1000)  ; Fehler in Promille
 
.if ((BAUD_ERROR>10) || (BAUD_ERROR<-10))       ; max. +/-10 Promille Fehler
  .error "Systematischer Fehler der Baudrate grösser 1 Prozent und damit zu hoch!"
.endif

.macro input
  .if @1 < 0x40
    in    @0, @1
  .else
      lds    @0, @1
  .endif
.endm

.macro output
  .if @0 < 0x40
    out    @0, @1
  .else
    sts    @0, @1
  .endif
.endm

.macro bbis ;port,bit,target
  .if @0 < 0x20
     sbic    @0, @1
    rjmp    @2
  .elif @0 < 0x40
    in        r2, @0
    sbrc    r2, @1
    rjmp    @2
  .else
    lds        r2, @0
    sbrc    r2, @1
    rjmp    @2
  .endif
.endm

.org 0x0000
rjmp reset
//.org 0x000b
//rjmp loop

.org 0x0007; 0x0009
rjmp loop

.include "sram/sram_makros.asm"

.include "eeprom/eeprom.asm"

.include "sonstiges.asm"

reset:
cli
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
    
    ldi zl, low(adr_TEMPERATURDATEN_H)
    ldi zh, high(adr_TEMPERATURDATEN_H)
    st z+, NULL
    st z+, NULL
    st z+, NULL
    st z+, NULL
    st z+, NULL

    ldi zl, low(adr_TEMPERATURDATEN_L)
    ldi zh, high(adr_TEMPERATURDATEN_L)
    st z+, NULL
    st z+, NULL
    st z+, NULL
    st z+, NULL
    st z+, NULL

; Baudrate einstellen
    /*ldi     temp, HIGH(UBRR_VAL)
    output     UBRR0H, temp
    ldi     temp, LOW(UBRR_VAL)
    output     UBRR0L, temp*/

 ;RS232 initialisieren
    ldi r16, LOW(UBRR_VAL)
    output UBRR0L,r16 ;UBRR0L
    ldi r16, HIGH(UBRR_VAL)
    output UBRR0H,r16 ; UBRR0H
    ldi r16,(1<<UCSZ01)|(1<<UCSZ00) ; Frame-Format: 8 Bit // 8 bit, 1 stop
    output UCSR0C,r16 ; UCSR0C
    input r16, UCSR0B
    ori r16, (1<<RXEN0)|(1<<TXEN0)
    output UCSR0B, r16
/*    ldi r16, (1<<URSEL)|(3<<UCSZ0)
    out UCSRC,r16
    ldi r16, (1<<RXEN)|(1<<TXEN)
    out UCSRB,r16*/

; Init
          ldi      temp, HIGH(RAMEND)     ; Stackpointer initialisieren
          out      SPH, temp
          ldi      temp, LOW(RAMEND)
          out      SPL, temp
    
; IO einstellen
/*ldi temp, 0b00000110
out DDRB, temp
ldi temp, 0b00000001
out PORTB, temp

ldi temp, 0b00110011
out DDRC, temp
ldi temp, 0b00001100
out PORTC, temp

ldi temp, 0b00000000
out DDRD, temp
ldi temp, 0b11111100
out PORTD, temp    */

ldi temp, 0b00000110
out DDRB, temp
ldi temp, 0b00000000
out PORTB, temp

ldi temp, 0b00110011
out DDRC, temp
ldi temp, 0b00001100 //ldi temp, 0b00001100
out PORTC, temp

ldi temp, 0b00000000
out DDRD, temp
ldi temp, 0b00000000
out PORTD, temp    





cbi SENSOR_V_PORT, SENSOR_V_PIN

cbi LED_V_PORT, LED_V_PIN
//rcall eeprom_init
rcall eeprom_init_datenstruktur

ssn Sensor_Anzahl, 2

// Zeitabstand ermitteln
ssn Sensor_Zeitabstand, 1
ldi r16, 0b00001111
sbic PIND, 2
andi r16,0b00000111
NOP
sbic PINB, 0
andi r16,0b00001011
NOP
sbic PINC, 3
andi r16,0b00001101
NOP
sbic PINC, 2
andi r16,0b00001110
NOP
sts Sensor_Zeitabstand, r16
ldi temp, 0b00000000 //ldi temp, 0b00001100
out PORTC, temp
// Timer 1

output  ADCSRA, NULL
 

        lds r17, Sensor_Zeitabstand
        ldi     ZL, LOW(Sensor_Zeiten_Timer*2)        ; Low-Byte der Adresse in Z-Pointer
        ldi     ZH, HIGH(Sensor_Zeiten_Timer*2)
        add ZL, r17
        adc ZH, NULL
        lpm  
        output     OCR2A, r0 ; <- Anzahl


        ldi     ZL, LOW(Sensor_Zeiten_Vorteiler*2)        ; Low-Byte der Adresse in Z-Pointer
        ldi     ZH, HIGH(Sensor_Zeiten_Vorteiler*2)
        add ZL, r17
        adc ZH, NULL
        lpm  
        output tccr2b,r0 ;for counter2   <- Vorteiler   


        ldi     ZL, LOW(Sensor_Zeiten_Durchgaenge_H*2)        ; Low-Byte der Adresse in Z-Pointer
        ldi     ZH, HIGH(Sensor_Zeiten_Durchgaenge_H*2)
        add ZL, r17
        adc ZH, NULL
        lpm
        sts Sensor_Cooldown, r0
        ldi     ZL, LOW(Sensor_Zeiten_Durchgaenge_L*2)        ; Low-Byte der Adresse in Z-Pointer
        ldi     ZH, HIGH(Sensor_Zeiten_Durchgaenge_L*2)
        add ZL, r17
        adc ZH, NULL
        lpm
        sts Sensor_Cooldown+1, r0


ldi temp, (1<<AS2) ; Asynchronous Timer 2
output ASSR, temp
ldi temp, (1<<OCIE2A) ; Timer 2 Overflow Interrupt Enable
output TIMSK2,temp

ldi r16, (1<<SE)
out SMCR, r16

ldi temp, ( 1 << WGM21 )
output TCCR2A,temp
 

ldi temp, (1<<AS2) ; Asynchronous Timer 2
output ASSR, temp
ldi temp, (1<<OCIE2A) ; Timer 2 Overflow Interrupt Enable
output TIMSK2,temp


ldi r16, 0b10101001
output PRR, temp

sbi LED_V_PORT, LED_V_PIN

cbi LED_V_PORT, LED_V_PIN
rcall wait500ms
rcall wait500ms
sbi LED_V_PORT, LED_V_PIN
rcall wait500ms
rcall wait500ms
cbi LED_V_PORT, LED_V_PIN
rcall wait500ms
rcall wait500ms
sbi LED_V_PORT, LED_V_PIN
rcall wait500ms
rcall wait500ms


//mov r7, NULL
ldi r16, 60
sts initit, r16

// erreichbar sein
do2:
lds r16, initit
cpi r16, 120
brne no_30
cbi LED_V_PORT, LED_V_PIN
rcall wait500ms
sbi LED_V_PORT, LED_V_PIN
rcall wait500ms
cbi LED_V_PORT, LED_V_PIN
rcall wait500ms
sbi LED_V_PORT, LED_V_PIN
rcall wait500ms
cbi LED_V_PORT, LED_V_PIN
rcall wait500ms
sbi LED_V_PORT, LED_V_PIN
rcall wait500ms
cbi LED_V_PORT, LED_V_PIN
rcall wait500ms
sbi LED_V_PORT, LED_V_PIN
rcall wait500ms
cbi LED_V_PORT, LED_V_PIN
rcall wait500ms
sbi LED_V_PORT, LED_V_PIN
rcall wait500ms
rjmp anfang_prozessor
rjmp over_30
no_30:
inc r16
sts initit, r16
over_30:


bbis     UCSR0A, RXC0, sprung1 
//sbis UCSRA, RXC                  
rjmp     no_receive
sprung1:
input       temp, UDR0 //UDR0
cli 
sts initit, NULL

// gib Zeitdaten aus
cpi temp, 'E'
breq send14
rjmp no_send14
send14:
// Zeitabstand ermitteln
ldi temp, 0b00001100 //ldi temp, 0b00001100
out PORTC, temp

ldi r16, 0b00001111

sbic PIND, 2
andi r16,0b00000111
NOP
sbic PINB, 0
andi r16,0b00001011
NOP
sbic PINC, 3
andi r16,0b00001101
NOP
sbic PINC, 2
andi r16,0b00001110
NOP

sts Sensor_Zeitabstand, r16
rcall send_register
ldi temp, 0b00000000 //ldi temp, 0b00001100
out PORTC, temp


        lds r17, Sensor_Zeitabstand
        ldi     ZL, LOW(Sensor_Zeiten_Timer*2)        ; Low-Byte der Adresse in Z-Pointer
        ldi     ZH, HIGH(Sensor_Zeiten_Timer*2)
        add ZL, r17
        adc ZH, NULL
        lpm  
        mov r16, r0
        rcall send_register

        ldi     ZL, LOW(Sensor_Zeiten_Vorteiler*2)        ; Low-Byte der Adresse in Z-Pointer
        ldi     ZH, HIGH(Sensor_Zeiten_Vorteiler*2)
        add ZL, r17
        adc ZH, NULL
        lpm  
        mov r16, r0
        rcall send_register


        ldi     ZL, LOW(Sensor_Zeiten_Durchgaenge_H*2)        ; Low-Byte der Adresse in Z-Pointer
        ldi     ZH, HIGH(Sensor_Zeiten_Durchgaenge_H*2)
        add ZL, r17
        adc ZH, NULL
        lpm
        mov r16, r0
        rcall send_register
        ldi     ZL, LOW(Sensor_Zeiten_Durchgaenge_L*2)        ; Low-Byte der Adresse in Z-Pointer
        ldi     ZH, HIGH(Sensor_Zeiten_Durchgaenge_L*2)
        add ZL, r17
        adc ZH, NULL
        lpm
        mov r16, r0
        rcall send_register


rjmp no_receive
no_send14:

// ermittle adresslänge
cpi temp, 'D'
breq send13
rjmp no_send13
send13:
ldi r16, 0
sts eeprom_id, r16
rcall eeprom_ermittle_adresslaenge
rcall send_register
rjmp no_receive
no_send13:

// suche den anfang und gib daten ans uart
cpi temp, 'K'
breq send12
rjmp no_send12
send12:

rcall eeprom_finde_anfang

lds r16, eeprom_anfang_id
rcall send_register
lds r16, eeprom_anfang_seite
rcall send_register
lds r16, eeprom_anfang_seite+1
rcall send_register
lds r16, eeprom_anfang_blockderseite
rcall send_register
lds r16, eeprom_anfang_adresse
rcall send_register
lds r16, eeprom_anfang_adresse+1
rcall send_register
lds r16, eeprom_anfang_adresse+2
rcall send_register
lds r16, eeprom_anfang_blockinstruktur
rcall send_register
lds r16, eeprom_anfang_blockinstruktur+1
rcall send_register
lds r16, eeprom_anfang_blockinstruktur+2
rcall send_register
lds r16, eeprom_anfang_kontrollbit
rcall send_register
lds r16, eeprom_anfang_hatanfang
rcall send_register

    rjmp no_receive
    no_send12:

// liest den ersten sensor aus
cpi temp, 'A'
brne no_send
    sbi SENSOR_V_PORT, SENSOR_V_PIN
    rcall sensor_abfragen
    cbi SENSOR_V_PORT, SENSOR_V_PIN
    lds temp3,     adr_TEMPERATURDATEN_H
    rcall FUNKTION_HEX
    mov temp, temp3
    rcall send_register

    lds temp3,     adr_TEMPERATURDATEN_L
    rcall FUNKTION_HEX
    mov temp, temp2
    rcall send_register
    mov temp, temp3
    rcall send_register
    rjmp no_receive
    no_send:


cpi temp, 'C'
brne no_send16
// Datensätze schreiben

ldi r17,0
ldi r19,1
aussen:
ldi r18,100
aussen2:

push r18
push r19
sts adr_TEMPERATURDATEN_L, r17
inc r17
sts adr_TEMPERATURDATEN_H, NULL
push r17
rcall speichern
pop r17
pop r19
pop  r18

ldi r16,'F'
rcall send_register
dec r18
brne aussen2
dec r19
brne aussen

rjmp no_receive
no_send16:


cpi temp, SENSOR_ID+1 ;="!"
breq send2
rjmp no_send2
send2:
    // erstellt die Struktur für einen Sensor
    ldi r16, 2
    rcall eeprom_erstelle_datenstruktur
    rcall eeprom_finde_anfang
    sts eeprom_aktiv, EINS
    rjmp no_receive
no_send2:


cpi temp, SENSOR_ID+2 ;="""
breq send3
rjmp no_send3
send3:
    // erstellt die Struktur für zwei Sensoren
    ldi r16, 3
    rcall eeprom_erstelle_datenstruktur
    rcall eeprom_finde_anfang
    sts eeprom_aktiv, EINS
    rjmp no_receive
no_send3:

cpi temp, SENSOR_ID+3 ;="#"
breq send4
rjmp no_send4
send4:
    // erstellt die Struktur für drei Sensoren
    ldi r16, 5
    rcall eeprom_erstelle_datenstruktur
    rcall eeprom_finde_anfang
    sts eeprom_aktiv, EINS
    rjmp no_receive
no_send4:

cpi temp, SENSOR_ID+4 ;="$"
breq send5
rjmp no_send5
send5:
    // erstellt die Struktur für vier Sensoren
    ldi r16, 6
    rcall eeprom_erstelle_datenstruktur
    rcall eeprom_finde_anfang
    sts eeprom_aktiv, EINS
    rjmp no_receive
no_send5:

cpi temp, SENSOR_ID+5 ;="%"
breq send6
rjmp no_send6
send6:
    // erstellt die Struktur für fünf Sensoren
    ldi r16, 7
    rcall eeprom_erstelle_datenstruktur
    rcall eeprom_finde_anfang
    sts eeprom_aktiv, EINS
    rjmp no_receive
no_send6:

cpi temp,  SENSOR_ID+6 ;="&" 
breq send7
rjmp no_send7
send7:
    // liest alle eeprom aus und sendet an uart
    lds r16, Sensor_Zeitabstand
    rcall send_register
    rcall eeprom_read_data

    rjmp no_receive
no_send7:

cpi temp, SENSOR_ID+7 ;="'"
breq send8
rjmp no_send8
send8:
    // liest internes eeprom aus
ldi zl, low(eeprom_blockgroesse)
ldi zh, high(eeprom_blockgroesse)
ldi r23, 52
schleife11:
ld r16, z+
rcall send_register
dec r23
brne schleife11

lds r16, Sensor_Zeitabstand
inc r16
rcall send_register
    
rjmp no_receive
no_send8:

no_receive:

rcall wait500ms

rjmp do2



anfang_prozessor:
sei
ldi r16, (1<<SE) | (1<<SM1) | (1<<SM0)
out SMCR, r16


//send_const 'W'7
//cli
//rcall eeprom_init
// 
do:
//cbi LED_V_PORT, LED_V_PIN

//lds r16, init
//cpi r16, 31
//brne no_31
//sei
sleep
//no_31:

/*    serout_string_wait22:
    lds r16, UCSR0A
    sbrs r16, UDRE0
    rjmp    serout_string_wait22
    ldi r16, 'X'
    output     UDR0, r16*/
/*
ldi r16,0
weiter:
rcall wait5ms
cpi r16, 128
brne no_aus
sbi LED_V_PORT, LED_V_PIN
no_aus:

dec r16
brne weiter
*/

rjmp do

loop:
rcall wait5ms2
rcall wait5ms2
rcall wait5ms2
rcall wait5ms2
rcall wait5ms2
rcall wait5ms2
rcall wait5ms2
rcall wait5ms2
rcall wait5ms2
rcall wait5ms2
rcall wait5ms2
rcall wait5ms2
rcall wait5ms2
 ; ???
//rjmp empfangen


/*mov r16, r9
cpi r16,0
breq no_0
sbi LED_V_PORT, LED_V_PIN
mov r9, NULL
rjmp no_1
no_0:
cbi LED_V_PORT, LED_V_PIN
mov r9, EINS
no_1:*/


/*lds r16, init
cpi r16, 30
brlo no_30
cpi r16, 30
brne over_30

ldi r16, (1<<SE) | (1<<SM1) | (1<<SM0)
out SMCR, r16
inc r16
sts init, r16
//sei
//sleep
rjmp over_30
no_30:
inc r16
sts init, r16
over_30:*/


/*lds r16, eeprom_fehler_blinken
cpi r16, 1
brne no_fehler_blinken
cli
blink:
cbi LED_V_PORT, LED_V_PIN
rcall wait500ms
sbi LED_V_PORT, LED_V_PIN
rcall wait500ms
rjmp blink
no_fehler_blinken:*/
 

lds r16, eeprom_aktiv
cpi r16,0
breq not_aktiv
lds r16, Sensor_Anzahl
cpi r16, 0
brne not_aktiv
ldi r23,0
lds r22, eeprom_blockgroesse
ldi r21, 8
mul r22, r21

ldi r21, 11
subtrahieren:
inc r23
sub r0, r21
cp r0, r21
brsh subtrahieren
sts Sensor_Anzahl, r23
cpi r23, 0
brne speichernn
sts eeprom_fehler_blinken, EINS
rjmp not_aktiv
speichernn:
rcall speichern
not_aktiv:


/*sbic PINC, 2
rjmp uart_on
cpp UCSR0B, RXEN0            ; RX (Empfang) aktivieren
cpp UCSR0B, TXEN0            ; TX (Senden)  aktivieren
rjmp over_uart_sensor
uart_on:
spp UCSR0B, RXEN0            ; RX (Empfang) aktivieren
spp UCSR0B, TXEN0            ; TX (Senden)  aktivieren
over_uart_sensor:*/



//lds temp, Sensor_Cooldown

// LED
/*lds temp, Sensor_Cooldown
cpi temp, 1
breq messen2
rjmp over_messen2
messen2:
cbi LED_V_PORT, LED_V_PIN
over_messen2:*/

// Messen???
lds r23, Sensor_Anzahl
cpi r23, 0
brne is_messen3
rjmp over_messen3
is_messen3:

CSN Sensor_Cooldown, 2, messen, no_messen
no_messen:
//lds temp, Sensor_Cooldown
//cpi temp, 0
//breq messen
SRS Sensor_Cooldown,2,EINS
//dec temp
//sts Sensor_Cooldown, temp
rjmp over_messen
messen:
cli

ldi r16, 'M'
rcall send_register /// DEBUG

sbi (SENSOR_V_PORT),(SENSOR_V_PIN)
///lds r16, Sensor_Anzahl /// DEBUG
///rcall send_register /// DEBUG

lds r23, Sensor_Anzahl
rcall wait5ms2

cpi r23, 1
brlo no1
rcall sensor_abfragen
no1:

cpi r23, 2
brlo no2
rcall sensor_abfragen2
no2:

cpi r23, 3
brlo no3
rcall sensor_abfragen3
no3:

cpi r23, 4
brlo no4
rcall sensor_abfragen4
no4:

cpi r23, 5
brlo no5
rcall sensor_abfragen5
no5:

rcall speichern

cbi (SENSOR_V_PORT),(SENSOR_V_PIN)
sbi LED_V_PORT, LED_V_PIN

lds r17, Sensor_Zeitabstand
ldi     ZL, LOW(Sensor_Zeiten_Durchgaenge_H*2)        ; Low-Byte der Adresse in Z-Pointer
ldi     ZH, HIGH(Sensor_Zeiten_Durchgaenge_H*2)
add ZL, r17
adc ZH, NULL
lpm
sts Sensor_Cooldown, r0
ldi     ZL, LOW(Sensor_Zeiten_Durchgaenge_L*2)        ; Low-Byte der Adresse in Z-Pointer
ldi     ZH, HIGH(Sensor_Zeiten_Durchgaenge_L*2)
add ZL, r17
adc ZH, NULL
lpm
sts Sensor_Cooldown+1, r0

sei
rjmp over_over_messen3
over_messen3:
sts adr_TEMPERATURDATEN_L, NULL
sts adr_TEMPERATURDATEN_L+1, NULL
sts adr_TEMPERATURDATEN_L+2, NULL
sts adr_TEMPERATURDATEN_L+3, NULL
sts adr_TEMPERATURDATEN_L+4, NULL
sts adr_TEMPERATURDATEN_H, NULL
sts adr_TEMPERATURDATEN_H+1, NULL
sts adr_TEMPERATURDATEN_H+2, NULL
sts adr_TEMPERATURDATEN_H+3, NULL
sts adr_TEMPERATURDATEN_H+4, NULL
over_over_messen3:


over_messen:
sei
reti

speichern:
// daten ins eeprom hochladen

ldi zl, low(eeprom_input)
ldi zh, high(eeprom_input)
lds r23, eeprom_blockgroesse
nullen:
st z+, NULL
dec r23
brne nullen

ldi zl, low(adr_TEMPERATURDATEN_L)
ldi zh, high(adr_TEMPERATURDATEN_L)
ldi xl, low(adr_TEMPERATURDATEN_H)
ldi xh, high(adr_TEMPERATURDATEN_H)

lds r24, Sensor_Anzahl; <- hier wurden manuel festgelegt, das es 5 sensoren sind
///mov r16, r24 /// DEBUG
///rcall send_register /// DEBUG

sensoren_speichern:

ld r16, x+
///rcall send_register /// DEBUG
sts eeprom_speicher, r16
ld r16, z+
///rcall send_register /// DEBUG
sts eeprom_speicher+1, r16
push zl
push zh
push xl
push xh

lds r16, eeprom_blockgroesse
ldi r17, 2
ssr eeprom_input, r16, eeprom_speicher, r17, 11

pop xh
pop xl
pop zh
pop zl

dec r24
brne sensoren_speichern

lds r16, eeprom_input
///rcall send_register /// DEBUG
lds r16, eeprom_input+1
///rcall send_register /// DEBUG

rcall eeprom_write_block
ret

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
    bbis    UCSR0A,UDRE0, over_send_register
///    sbis UCSRA,UDRE
    rjmp    serout_string_wait2
    over_send_register:
    output     UDR0, r16 ;UDR0
//    pop temp
ret


.include "THERMO_TSIC206.asm"

.DSEG                ; Umschalten auf das SRAM Datensegment
Sensor_Cooldown:   .BYTE  2
Sensor_Anzahl: .BYTE 1
Sensor_Zeitabstand: .BYTE 1
initit: .BYTE 1

.CSEG
Sensor_Zeiten_Vorteiler:
    .db 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
Sensor_Zeiten_Timer:
    .db 31,159,159,239,239,239,239,239,239,239,239,239,239,239,239,239
Sensor_Zeiten_Durchgaenge_H:
    .db 0,0,0,0,0, 0, 0, 0,  0,  0,high(479),high(719),high(959),high(2879),high(5759),high(11519)
Sensor_Zeiten_Durchgaenge_L:
    .db 0,0,1,3,7,19,39,79,119,239, low(479), low(719), low(959), low(2879), low(5759), low(11519)
