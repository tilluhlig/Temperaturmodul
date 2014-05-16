;#############################################
;####### setzt den schreibkopf auf den #######
;######## anfang der datenstruktur ###########
;#############################################
eeprom_finde_anfang:
cli
push r16
push r17
push r18
push r19
push r20
push r24
push r21
push r23
push r22

ldi r16, 7
sts eeprom_blockgroesse, r16

// alles zurücksetzen
ssn eeprom_anfang_id, 1
ssn eeprom_anfang_seite, 2
ssn eeprom_anfang_blockinstruktur, 3
ssn eeprom_anfang_hatanfang, 1

sts eeprom_speicher+3, NULL ; eeprom_speicher[3] = istersterblock, kontrollbit aus erstem block
sts eeprom_speicher, NULL ; eeprom_speicher[0] = kontrollbyte ; <- kontrollbit
ssn eeprom_anfang_id, 1
ssn eeprom_anfang_kontrollbit, 1

eeprom_finde_anfang_schleife:

lds r16, eeprom_anfang_id

cpi r16, 4
brlo no_zweiter_durchgang
subi r16, 4
cpi r16, 0
brne no00
ssn eeprom_anfang_seite, 2
ssn eeprom_anfang_blockinstruktur, 3
no00:

no_zweiter_durchgang:

rcall eeprom_select

ssn eeprom_anfang_adresse, 3

lds r16, eeprom_blockseite
cpi r16, 0
brne eeprom_finde_anfang_ok
rjmp eeprom_finde_anfang_ende
eeprom_finde_anfang_ok:

ldi r18, 0
ldi r17, 0
ldi r16, 0
rcall eeprom_start
rcall eeprom_start_read
rcall eeprom_send_adress

lds r18, eeprom_seiten
lds r17, eeprom_seiten+1
sts eeprom_speicher+1, r18 ; eeprom_speicher[1] = seitenanzahl H
sts eeprom_speicher+2, r17 ; eeprom_speicher[2] = seitenanzahl L

schleife13:
ldi r16, 'S'
rcall send_register

sts eeprom_anfang_blockderseite, NULL
lds r21, eeprom_seitengroesse
inc r21
lds r19, eeprom_blockseite
sts eeprom_speicher+4, r19 ; eeprom_speicher[4] = anzahl der blöcke pro seite
schleife15:
//send_const 'B'


lds r20, eeprom_blockgroesse

dec r20
dec r21
schleife14:
rcall eeprom_read
//send_const 'R'
dec r21
dec r20
brne schleife14

rcall eeprom_read
// das ist unser interessantes byte
lds r23, eeprom_speicher+3
cpi r23, 0
brne nichterstes
sts eeprom_speicher+3, EINS
rjmp nichts_gefunden
nichterstes:
lds r23, eeprom_speicher
andi r23, 1
andi r16, 1
add r23, r16
sbrc r23, 0
rjmp nichts_gefunden
// der anfang wurde gefunden
push r16
ldi r16, 'F'
rcall send_register
pop r16

inc r16
andi r16, 1
sts eeprom_anfang_kontrollbit, r16

lds r24, eeprom_anfang_id
cpi r24, 4
brlo no_setzen
subi r24, 4
no_setzen:
sts eeprom_anfang_id, r24

sts eeprom_anfang_hatanfang, EINS
rjmp eeprom_finde_anfang_ende2
nichts_gefunden:

mov r23, r16
sts eeprom_speicher, r23

// eeprom_anfang_adresse erhöhen
lds r20, eeprom_blockgroesse
ars eeprom_anfang_adresse, 3, r20

// bisherige blöcke hochzählen und prüfen, ob alle blöcke bearbeitet
ars eeprom_anfang_blockinstruktur, 3, EINS

css eeprom_anfang_blockinstruktur, 3, eeprom_bloecke_gesamt, ende_gefunden, weitermachen
ende_gefunden:
// hier soll nicht weitergemacht werden, alle blöcke in struktur bearbeitet, und kein anfang gefunden
ldi r16, '?'
rcall send_register

rjmp eeprom_finde_anfang_ende
weitermachen:

// eeprom_anfang_blockderseite hochzählen
ars eeprom_anfang_blockderseite, 1, EINS

srs eeprom_speicher+4, 1, EINS
csn eeprom_speicher+4, 1, no_schleife15, schleife15

/*dec r19
breq no_schleife15
rjmp schleife15*/
no_schleife15:

cpi r21, 0
breq no_rest2
// eeprom_anfang_adresse erhöhen
ars eeprom_anfang_adresse, 3, r21

schleife16:
rcall eeprom_read
dec r21
brne schleife16
no_rest2:

srs eeprom_speicher+1, 2, EINS
csn eeprom_speicher+1, 2, schleife13_ende, schleife13
schleife13_ende:

eeprom_finde_anfang_ende:
rcall eeprom_ende

lds r24, eeprom_anfang_id
inc r24
sts eeprom_anfang_id, r24

cpi r24,8
breq eeprom_finde_anfang_ende2
rjmp eeprom_finde_anfang_schleife
eeprom_finde_anfang_ende2:
rcall eeprom_ende

pop r22
pop r23
pop r21
pop r24
pop r20
pop r19
pop r18
pop r17
pop r16
sei
ret
