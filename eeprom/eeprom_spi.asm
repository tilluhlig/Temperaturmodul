;#############################################
;############### initialisiert ###############
;#############################################
eeprom_init:
sbi SI_REG, SI_PIN
sbi SCK_REG, SCK_PIN
cbi SO_REG, SO_PIN

cbi SCK_PORT, SCK_PIN
cbi SI_PORT, SI_PIN

sbi CS0_REG, CS0_PIN
sbi CS1_REG, CS1_PIN
sbi CS2_REG, CS2_PIN
sbi CS3_REG, CS3_PIN
sbi CS0_PORT, CS0_PIN
sbi CS1_PORT, CS1_PIN
sbi CS2_PORT, CS2_PIN
sbi CS3_PORT, CS3_PIN

ldi r16, (1<<SPE) | (1<<MSTR)  ;| (1<<SPR0) | (1<<SPR1)
out SPCR , r16

//in r16, SPSR
//ori r16, (1<<SPI2X)
//out SPSR, r16
ret


;#############################################
;####### schreibt ein byte ins eeprom ########
;#############################################
;####### in: r16 = zu schreibendes byte ######
;#############################################
eeprom_write:
out SPDR, r16
Wait_Transmit:
//in r16, SPSR
//sbrs r16, SPIF
bbis SPSR, SPIF, sprung2
rjmp Wait_Transmit
sprung2:
ret


;#############################################
;######### liest ein byte vom eeprom #########
;#############################################
;######## out: r16 = empfangenes byte ########
;#############################################
eeprom_read:
ldi r16, 0
rcall eeprom_write
in r16, SPDR
ret


;#############################################
;######### sendet eine 8 bit adresse #########
;#############################################
;################# in: r16 ###################
;#############################################
eeprom_send_adress8Bit:
rcall eeprom_write
ret


;#############################################
;######## sendet eine 16 bit adresse #########
;#############################################
;########## in: H <-- r17, r16 <-- L #########
;#############################################
eeprom_send_adress16Bit:
push r16
mov r16, r17
rcall eeprom_write
pop r16
rcall eeprom_write
ret


;#############################################
;######## sendet eine 24 bit adresse #########
;#############################################
;####### in: H <-- r18, r17, r16 <-- L #######
;#############################################
eeprom_send_adress24Bit:
push r16
mov r16, r18
rcall eeprom_write
mov r16, r17
rcall eeprom_write
pop r16
rcall eeprom_write
ret

;#############################################
;############ sendet eine adresse ############
;#############################################
;####### in: H <-- r18, r17, r16 <-- L #######
;#############################################
eeprom_send_adress:
push r19
push r16
lds r19, eeprom_adresslaenge

cpi r19, 3
brne eeprom_send_adress_no_3
mov r16, r18
rcall eeprom_write
mov r16, r17
rcall eeprom_write
eeprom_send_adress_no_3:


cpi r19, 2
brne eeprom_send_adress_no_2
mov r16, r17
rcall eeprom_write
eeprom_send_adress_no_2:

pop r16
rcall eeprom_write

pop r19
ret


;#############################################
;##### startet den zugriff aufs eeprom #######
;#############################################
;##### in: [eeprom_id] = welches eeprom ######
;#############################################
eeprom_start:
push r16
lds r16, eeprom_id

cpi r16, 0
brne eeprom_start_no0
cbi CS0_PORT, CS0_PIN 
eeprom_start_no0:

cpi r16, 1
brne eeprom_start_no1
cbi CS1_PORT, CS1_PIN 
eeprom_start_no1:

cpi r16, 2
brne eeprom_start_no2
cbi CS2_PORT, CS2_PIN 
eeprom_start_no2:

cpi r16, 3
brne eeprom_start_no3
cbi CS3_PORT, CS3_PIN
eeprom_start_no3:

pop r16
ret


;#############################################
;##### beendet den zugriff aufs eeprom #######
;#############################################
;##### in: [eeprom_id] = welches eeprom ######
;#############################################
eeprom_ende:
sbi CS0_PORT, CS0_PIN 
sbi CS1_PORT, CS1_PIN 
sbi CS2_PORT, CS2_PIN 
sbi CS3_PORT, CS3_PIN 
ret


;#############################################
;###### startet einen schreibvorgang #########
;#############################################
eeprom_start_write:
push r16
ldi r16, 0b00000110
rcall eeprom_write

rcall eeprom_ende
rcall eeprom_start

ldi r16, 0b00000010
rcall eeprom_write

pop r16
ret


;#############################################
;###### beendet einen schreibvorgang #########
;#############################################
eeprom_end_write:
//push r16
//rcall wait5ms
//rcall wait5ms
rcall eeprom_ende
rcall wait5ms
rcall wait5ms
//rcall wait5ms

//rcall wait5ms
//rcall eeprom_start
//ldi r16, 0b00000100
//rcall eeprom_write
//rcall eeprom_ende

//rcall wait5ms
//rcall wait5ms

//pop r16
ret


;#############################################
;######## startet einen lesevorgang ##########
;#############################################
eeprom_start_read:
push r16

ldi r16, 0b00000011
rcall eeprom_write

pop r16
ret
