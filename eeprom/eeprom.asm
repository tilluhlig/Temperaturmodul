.equ SCK_REG = DDRB
.equ SCK_PORT = PORTB
.equ SCK_PIN = 5

.equ SO_REG = DDRB
.equ SO_PORT = PINB
.equ SO_PIN = 4

.equ SI_REG = DDRB
.equ SI_PORT = PORTB
.equ SI_PIN = 3



.equ CS0_REG = DDRB
.equ CS0_PORT = PORTB
.equ CS0_PIN = 2

.equ CS1_REG = DDRB
.equ CS1_PORT = PORTB
.equ CS1_PIN = 1

.equ CS2_REG = DDRC
.equ CS2_PORT = PORTC
.equ CS2_PIN = 5

.equ CS3_REG = DDRC
.equ CS3_PORT = PORTC
.equ CS3_PIN = 4

;#########################
;####### FUNKTIONEN ######
;####### FUNKTIONEN ######
;####### FUNKTIONEN ######
;#########################
//.include "eeprom/eeprom_funktionen.asm"


.include "eeprom/eeprom_spi.asm"


//.include "eeprom/eeprom_intern_funktionen.asm"


.include "eeprom/eeprom_kenngroessen.asm"


//.include "eeprom/eeprom_erstelle_datenstruktur.asm"


//.include "eeprom/eeprom_finde_anfang.asm"


;#########################
;## SPEICHERRESERVIERUNG #
;## SPEICHERRESERVIERUNG #
;## SPEICHERRESERVIERUNG #
;#########################
//.include "eeprom/eeprom_pm.asm"


.include "eeprom/eeprom_sram.asm"


//.include "eeprom/eeprom_intern.asm"

.CSEG
