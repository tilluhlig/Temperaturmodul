;#############################################
;####### erstellt die datenstruktur ##########
;####### letztes Bit ist kontrollbit #########
;################ 2B - 16B ##################
;#############################################
;########### in: r16 = blocklänge ############
;#############################################
eeprom_erstelle_datenstruktur2:
cpi r16, 0
brne ok
ret
ok:

cli
push r17
push r18
push r19
push r20
push r21
push r22
push r23
push r24

rcall send_register

ssn eeprom_fehler, 4

sts eeprom_speicher, r16 ; eeprom_speicher[0] = gewünschte blockgröße in byte (1-16)
sts eeprom_speicher+1, NULL ; eeprom_speicher[1] = speichert einen zähler zur bestimmung des kontrollbit
sts eeprom_blockgroesse, r16

ldi zl, low(eeprom_intern_blockgroesse)
ldi zh, high(eeprom_intern_blockgroesse)
lds r16, eeprom_blockgroesse
rcall eeprom_intern_write

ldi r16, 0
sts eeprom_id, r16

eeprom_schleife3:

// eeprom erkennen
sts eeprom_adresslaenge, NULL
ssn eeprom_adressen, 3
sts eeprom_seitengroesse, NULL
ssn eeprom_seiten, 2
ssn eeprom_bloecke, 3
ssn eeprom_blockseite, 1 

rcall eeprom_ermittle_adresslaenge
cpi r16,0
brne no_fail
rjmp eeprom_kenngroessen_speicher
no_fail:
sts eeprom_adresslaenge, r16

rcall eeprom_ermittle_speichergroesse
ssn eeprom_adressen,3
ass eeprom_adressen,3, eeprom_res2, 3

rcall eeprom_ermittle_seitengroesse
lds r16, eeprom_res0
sts eeprom_seitengroesse, r16

// maximale anzahl der blöcke berechnen
lds r16, eeprom_seitengroesse ; <- welche seitengröße hat das gewählte eeprom

// berechne anzahl der eeprom seiten
ssn eeprom_seiten,2
ssn eeprom_speicher+2, 3
ass eeprom_speicher+2, 3, eeprom_adressen, 3
ars eeprom_speicher+2, 3, EINS

eeprom_seitenberechnung:
ars eeprom_seiten,2, EINS
srs eeprom_speicher+2, 3, EINS
srs eeprom_speicher+2, 3, r16
csn eeprom_speicher+2, 3, ende_eeprom_seitenberechnung, eeprom_seitenberechnung
ende_eeprom_seitenberechnung:


// berechne anzahl der blöcke pro seite
lds r16, eeprom_speicher  ; <- welche blockgröße war gewünscht
lds r17, eeprom_seitengroesse ; <- welche seitengröße hat das gewählte eeprom
ldi r18, 0 ; <- hier zähle ich die anzahl derer hoch

add r17, EINS

eeprom_blockseitenberechnung:
add r18, EINS

sub r17, r16

cp r17,r16
brsh eeprom_blockseitenberechnung

sts eeprom_blockseite, r18

// berechne anzahl der blöcke
ssn eeprom_speicher+2, 2
ass eeprom_speicher+2, 2, eeprom_seiten, 2
ssn eeprom_bloecke, 3

lds r19, eeprom_blockseite

addiere:
ars eeprom_bloecke, 3, r19
srs eeprom_speicher+2, 2, EINS
csn eeprom_speicher+2, 2, ende_addiere, addiere
ende_addiere:

// eeprom kenngrößen speichern

// einzeldaten intern eeprom
eeprom_kenngroessen_speicher:
ldi zl, low(eeprom_intern_adresslaenge)
ldi zh, high(eeprom_intern_adresslaenge)
lds r16, eeprom_id
add zl, r16
adc zh, NULL
lds r16, eeprom_adresslaenge
rcall eeprom_intern_write

ldi zl, low(eeprom_intern_seitengroesse)
ldi zh, high(eeprom_intern_seitengroesse)
lds r16, eeprom_id
add zl, r16
adc zh, NULL
lds r16, eeprom_seitengroesse
rcall eeprom_intern_write

ldi zl, low(eeprom_intern_adressen)
ldi zh, high(eeprom_intern_adressen)
ldi r17, 3
lds r16, eeprom_id
mul r16,r17
add zl, r0
adc zh, NULL
lds r16, eeprom_adressen
rcall eeprom_intern_write
lds r16, eeprom_adressen+1
rcall eeprom_intern_write
lds r16, eeprom_adressen+2
rcall eeprom_intern_write

ldi zl, low(eeprom_intern_bloecke)
ldi zh, high(eeprom_intern_bloecke)
ldi r17, 3
lds r16, eeprom_id
mul r16,r17
add zl, r0
adc zh, NULL
lds r16, eeprom_bloecke
rcall eeprom_intern_write
lds r16, eeprom_bloecke+1
rcall eeprom_intern_write
lds r16, eeprom_bloecke+2
rcall eeprom_intern_write

ldi zl, low(eeprom_intern_seiten)
ldi zh, high(eeprom_intern_seiten)
ldi r17, 2
lds r16, eeprom_id
mul r16,r17
add zl, r0
adc zh, NULL
lds r16, eeprom_seiten
rcall eeprom_intern_write
lds r16, eeprom_seiten+1
rcall eeprom_intern_write

ldi zl, low(eeprom_intern_blockseite)
ldi zh, high(eeprom_intern_blockseite)
lds r16, eeprom_id
add zl, r16
adc zh, NULL
lds r16, eeprom_blockseite
rcall eeprom_intern_write

// einzeldaten sram
ldi zl, low(eeprom_adresslaenge_alle)
ldi zh, high(eeprom_adresslaenge_alle)
lds r16, eeprom_id
add zl, r16
adc zh, NULL
lds r16, eeprom_adresslaenge
st Z, r16

ldi zl, low(eeprom_seitengroesse_alle)
ldi zh, high(eeprom_seitengroesse_alle)
lds r16, eeprom_id
add zl, r16
adc zh, NULL
lds r16, eeprom_seitengroesse
st Z, r16

ldi zl, low(eeprom_adressen_alle)
ldi zh, high(eeprom_adressen_alle)
ldi r17, 3
lds r16, eeprom_id
mul r16,r17
add zl, r0
adc zh, NULL
lds r16, eeprom_adressen
st Z+, r16
lds r16, eeprom_adressen+1
st Z+, r16
lds r16, eeprom_adressen+2
st Z, r16

ldi zl, low(eeprom_bloecke_alle)
ldi zh, high(eeprom_bloecke_alle)
ldi r17, 3
lds r16, eeprom_id
mul r16,r17
add zl, r0
adc zh, NULL
lds r16, eeprom_bloecke
st Z+, r16
lds r16, eeprom_bloecke+1
st Z+, r16
lds r16, eeprom_bloecke+2
st Z, r16

ldi zl, low(eeprom_seiten_alle)
ldi zh, high(eeprom_seiten_alle)
ldi r17, 2
lds r16, eeprom_id
mul r16,r17
add zl, r0
adc zh, NULL
lds r16, eeprom_seiten
st Z+, r16
lds r16, eeprom_seiten+1
st Z, r16

ldi zl, low(eeprom_blockseite_alle)
ldi zh, high(eeprom_blockseite_alle)
lds r16, eeprom_id
add zl, r16
adc zh, NULL
lds r16, eeprom_blockseite
st Z, r16

ldi r16, 'P'
rcall send_register

lds r16, eeprom_id
rcall eeprom_select

// bytes auf dem eeprom einrichten
ssn eeprom_speicher+5, 2
ass eeprom_speicher+5, 2, eeprom_seiten, 2

lds r23, eeprom_speicher+1 ; <- kontrollbitzähler
lds r21, eeprom_blockseite

cpi r22, 0
brne einrichten_weiter2
rjmp einrichten_ende
einrichten_weiter2:

cpi r21, 0
brne einrichten_weiter
rjmp einrichten_ende
einrichten_weiter:


ssn eeprom_speicher+2,3
schleife4:

rcall eeprom_start
rcall eeprom_start_write
lds r18, eeprom_speicher+2
lds r17, eeprom_speicher+3
lds r16, eeprom_speicher+4
rcall eeprom_send_adress
lds r21, eeprom_blockseite
schleife6:
// schreibt die blöcke der seite
lds r24, eeprom_blockgroesse
dec r24

schleife5:
// schreibt den block 
mov r16, NULL
rcall eeprom_write
dec r24
brne schleife5


mov r16, NULL
sbrc r23, 0
mov r16, EINS
rcall eeprom_write
inc r23


dec r21
brne schleife6

rcall eeprom_end_write

ass eeprom_speicher+2, 3, eeprom_seitengroesse, 1
ars eeprom_speicher+2, 3, EINS

srs eeprom_speicher+5, 2, EINS

csn eeprom_speicher+5, 2, ende_schleife4, schleife4
ende_schleife4:

sts eeprom_speicher+1, r23

einrichten_ende:

ars eeprom_id, 1, EINS
lds r16, eeprom_id
cpi r16, 4
breq eeprom_schleife_ende3
rjmp eeprom_schleife3
eeprom_schleife_ende3:


// gesamtdaten speichern
ssn eeprom_fehler, 4
ldi zl, low(eeprom_intern_fehler)
ldi zh, high(eeprom_intern_fehler)
mov r16, NULL
rcall eeprom_intern_write
rcall eeprom_intern_write
rcall eeprom_intern_write
rcall eeprom_intern_write

ssn eeprom_bloecke_gesamt, 3
ass eeprom_bloecke_gesamt,3, eeprom_bloecke_alle,3
ass eeprom_bloecke_gesamt,3, eeprom_bloecke_alle+3,3 
ass eeprom_bloecke_gesamt,3, eeprom_bloecke_alle+6,3
ass eeprom_bloecke_gesamt,3, eeprom_bloecke_alle+9,3

lds r16, eeprom_bloecke_gesamt+2
sbrc r16, 0
rjmp isungerade
srs eeprom_bloecke_gesamt,3, EINS
isungerade:

ldi zl, low(eeprom_intern_bloecke_gesamt)
ldi zh, high(eeprom_intern_bloecke_gesamt)
lds r16, eeprom_bloecke_gesamt
rcall eeprom_intern_write
lds r16, eeprom_bloecke_gesamt+1
rcall eeprom_intern_write
lds r16, eeprom_bloecke_gesamt+2
rcall eeprom_intern_write

// schreibposition festlegen
sts eeprom_anfang_id, NULL
ssn eeprom_anfang_seite,2
sts eeprom_anfang_blockderseite, NULL
ssn eeprom_anfang_adresse,3
ssn eeprom_anfang_blockinstruktur,3

ENDE:
ldi r16, 'Z'
rcall send_register

pop r24
pop r23
pop r22
pop r21
pop r20
pop r19
pop r18
pop r17
sei
ret
