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


;#############################################
;###### initialisiert die datenstruktur ######
;#############################################
eeprom_init_datenstruktur:
; wird beim start des prozessors einmal aufgerufen, um
; die ports und den sram einzurichten 

; initialisierung von spi
rcall eeprom_init

; lade datenstrukturinformationen in sram
rcall eeprom_sram_laden

ssn eeprom_fehler_blinken, 1
ldi zl, low(eeprom_fehler)
ldi zh, high(eeprom_fehler)
ldi r16, 4
pruefen:
ld r17, Z+
cpi r17, 1
brne no_fehler
sts eeprom_fehler_blinken, EINS
rjmp over_pruefen
no_fehler:
dec r16
brne pruefen
over_pruefen:


; Prüfe die korrektheit der daten
lds r16, eeprom_adresslaenge_alle
cpi r16,4
brlo ok5
lds r16, eeprom_adresslaenge_alle+1
cpi r16,4
brlo ok5
lds r16, eeprom_adresslaenge_alle+2
cpi r16,4
brlo ok5
lds r16, eeprom_adresslaenge_alle+3
cpi r16,4
brlo ok5
sts eeprom_aktiv, NULL
sts eeprom_fehler_blinken, EINS
ret
ok5:

; finde den anfang der datenstruktur
rcall eeprom_finde_anfang

sts eeprom_aktiv, EINS
ret


;#############################################
;######## erstellt die datenstruktur #########
;#############################################
eeprom_erstelle_datenstruktur:
rcall eeprom_erstelle_datenstruktur2
ret


;#############################################
;###### sucht eine neue baustein id ##########
;#############################################
;### in: r16 = id vermuteter neuer baustein ##
;#############################################
;###### out: r16 = id neuer baustein #########
;#############################################
eeprom_finde_neuen_baustein:
cpi r16, 4
brne no_last
ldi r16,0
no_last:
sts eeprom_id, r16

finde_neuen_chip:
lds r16, eeprom_id
cpi r16, 4
brlo auswahl_ok2
subi r16,4
auswahl_ok2:

rcall eeprom_select

lds r16, eeprom_blockseite
cpi r16, 0
breq eeprom_finde_neuen_ende

cpi r16, 4
brlo auswahl_ok
subi r16, 4
sts eeprom_id, r16
auswahl_ok:
ret

eeprom_finde_neuen_ende:
lds r16, eeprom_id
inc r16
sts eeprom_id, r16
cpi r16, 8
breq over_finde_neuen_chip
rjmp finde_neuen_chip
over_finde_neuen_chip:

ret


;#############################################
;####### schreibt einen datenblock ###########
;#############################################
;####### in: [eeprom_input] = daten ##########
;############ eeprom_input[ 0] = H ###########
;############ eeprom_input[15] = L ###########
;#############################################
eeprom_write_block:
lds r16, eeprom_aktiv
cpi r16,0
brne eeprom_write_block_ok2
ret
eeprom_write_block_ok2:

lds r16, eeprom_anfang_hatanfang
cpi r16, 0
brne eeprom_write_block_ok
ret
eeprom_write_block_ok:

// hier wird geschrieben
lds r16, eeprom_anfang_id
rcall eeprom_select

rcall eeprom_start
rcall eeprom_start_write
lds r18, eeprom_anfang_adresse
lds r17, eeprom_anfang_adresse+1
lds r16, eeprom_anfang_adresse+2
rcall eeprom_send_adress

ldi zl, low(eeprom_input)
ldi zh, high(eeprom_input)

lds r23, eeprom_blockgroesse
dec r23
schreibschleife:
ld r16, Z+
//rcall send_register
rcall eeprom_write
dec r23
brne schreibschleife

// letztes byte erstellen und schreiben
ld r16, Z
andi r16, 0b11111110
lds r17, eeprom_anfang_kontrollbit
andi r17, 1
or r16, r17
//ld r16, Z+
//rcall send_register
rcall eeprom_write

rcall eeprom_end_write

ars eeprom_anfang_kontrollbit, 1, EINS


// stelle neue adresse ein
lds r16, eeprom_anfang_id
rcall eeprom_select

// ist das ende der struktur erreicht ???
ass eeprom_anfang_adresse,3, eeprom_blockgroesse, 1
ars eeprom_anfang_blockinstruktur, 3, EINS
ars eeprom_anfang_blockderseite, 1, EINS

css eeprom_anfang_blockinstruktur, 3, eeprom_bloecke_gesamt, ende_der_struktur_erreicht, no_ende_der_struktur_erreicht
ende_der_struktur_erreicht:
// ende der struktur erreicht
ssn eeprom_anfang_blockinstruktur,3
ssn eeprom_anfang_adresse, 3
ssn eeprom_anfang_seite, 2
ssn eeprom_anfang_blockderseite, 1

// hier noch den neuen baustein suchen
ars eeprom_anfang_id, 1, EINS
lds r16, eeprom_anfang_id
rcall eeprom_finde_neuen_baustein
sts eeprom_anfang_id, r16

ret
no_ende_der_struktur_erreicht:


// ist das ende der seite erreicht ???
css eeprom_anfang_blockderseite, 1, eeprom_blockseite, neu_setzen, no_neu_setzen
neu_setzen:
// wir haben den letzten block der seite erreicht
// addiere rest der seite zu adresse; <- hier noch rest der seite addieren
ssn eeprom_speicher, 1
ass eeprom_speicher, 1, eeprom_seitengroesse, 1
ars eeprom_speicher, 1, EINS

lds r17, eeprom_blockgroesse
runterzaehlen:
srs eeprom_speicher, 1, r17
lds r16, eeprom_speicher
cp r16, r17
brsh runterzaehlen
ars eeprom_anfang_adresse, 3, r16

ars eeprom_anfang_seite,2, EINS
ssn eeprom_anfang_blockderseite, 1
no_neu_setzen:


// ist das ende des bausteins erreicht (seitenanzahl) ???
css eeprom_anfang_seite, 2, eeprom_seiten, neu_setzen2, no_neu_setzen2
neu_setzen2:
// wir haben das seitenende des bausteins erreicht
ssn eeprom_anfang_blockderseite, 1
ssn eeprom_anfang_adresse, 3
ssn eeprom_anfang_seite, 2

// hier noch den neuen baustein suchen
lds r23, eeprom_anfang_id
ars eeprom_anfang_id, 1, EINS
lds r16, eeprom_anfang_id
rcall eeprom_finde_neuen_baustein
sts eeprom_anfang_id, r16

cp r23, r16
breq array_durchlaufen

cp r23, r16
brlo array_durchlaufen
rjmp no_neu_setzen2
array_durchlaufen:
ssn eeprom_anfang_blockinstruktur,3
no_neu_setzen2:

ret


;#############################################
;##### liest die gesamte datenstruktur #######
;###### und sendet die daten ans uart ########
;##### ACHTUNG beginnt nicht am anfang  ######
;############ der datenstruktur  #############
;#############################################
eeprom_read_data:
rcall eeprom_read_data2
ret


;#########################
;####### FUNKTIONEN ######
;####### FUNKTIONEN ######
;####### FUNKTIONEN ######
;#########################
.include "eeprom/eeprom_funktionen.asm"


.include "eeprom/eeprom_spi.asm"


.include "eeprom/eeprom_intern_funktionen.asm"


.include "eeprom/eeprom_kenngroessen.asm"


.include "eeprom/eeprom_erstelle_datenstruktur.asm"


.include "eeprom/eeprom_finde_anfang.asm"


;#########################
;## SPEICHERRESERVIERUNG #
;## SPEICHERRESERVIERUNG #
;## SPEICHERRESERVIERUNG #
;#########################
.include "eeprom/eeprom_pm.asm"


.include "eeprom/eeprom_sram.asm"


.include "eeprom/eeprom_intern.asm"

.CSEG
