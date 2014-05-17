;#############################################
;#### ermittelt die anzahl der adressbytes ###
;################ eines eeprom ###############
;######### ermittelt 8, 16 und 24 bit ########
;#############################################
;##### out: r16 = adresslaenge in bytes ######
;########## r16 = 0 -> fehler ################
;#############################################
eeprom_ermittle_adresslaenge:

// schreibe daten ins eeprom (1,2,4,8)
rcall eeprom_start
rcall eeprom_start_write

ldi r16, 1
rcall eeprom_write
lsl r16
rcall eeprom_write
lsl r16
rcall eeprom_write
lsl r16
rcall eeprom_write

//rcall eeprom_ende
rcall eeprom_end_write

// ermittle ob es eine 1 byte adresse ist
rcall eeprom_start
rcall eeprom_start_read
ldi r16, 1
rcall eeprom_send_adress8Bit
rcall eeprom_read
rcall eeprom_ende

cpi r16, 2
brne eeprom_ermittle_adresslaenge_ende_test2byte
ldi r16, 1
rjmp eeprom_ermittle_adresslaenge_ende

eeprom_ermittle_adresslaenge_ende_test2byte:
rcall eeprom_start
rcall eeprom_start_read
ldi r16, 2
ldi r17, 1
rcall eeprom_send_adress16Bit
rcall eeprom_read
rcall eeprom_ende

cpi r16, 4
brne eeprom_ermittle_adresslaenge_ende_test3byte
ldi r16, 2
rjmp eeprom_ermittle_adresslaenge_ende

eeprom_ermittle_adresslaenge_ende_test3byte:
rcall eeprom_start
rcall eeprom_start_read
ldi r16, 4
ldi r17, 2
ldi r18, 1
rcall eeprom_send_adress24Bit
rcall eeprom_read
rcall eeprom_ende

cpi r16, 8
brne eeprom_ermittle_adresslaenge_ende_testNObyte
ldi r16, 3
rjmp eeprom_ermittle_adresslaenge_ende

eeprom_ermittle_adresslaenge_ende_testNObyte:
ldi r16, 0

eeprom_ermittle_adresslaenge_ende:
ret


;#############################################
;######## ermittelt die speichergröße ########
;################ eines eeprom ###############
;### 1k,2k,4k,32k,64k,128k,256k,512k,1024k ###
;#############################################
;####### out: höchste adresse  ###############
;###### H <-- res2, res1, res0 <-- L #########
;#### res0 = res1 = res2 = 0 -> fehler #######
;#############################################
eeprom_ermittle_speichergroesse:
ldi r16, 1
sts eeprom_speicher+1, r16 ; eeprom_speicher[1] = kontrollbyte

ssn eeprom_res0, 3

ldi zl, low(eeprom_letzte_adresse*2)
ldi zh, high(eeprom_letzte_adresse*2)

// schreibe erstes byte als markierung
rcall eeprom_start
rcall eeprom_start_write

ldi r16 ,0
ldi r17 ,0
ldi r18 ,0
rcall eeprom_send_adress

lds r16, eeprom_speicher+1
rcall eeprom_write
//rcall eeprom_ende
rcall eeprom_end_write


ldi r16,9
sts eeprom_speicher+2, r16 ; eeprom_speicher[2] = anzahl möglicher speichertypen

eeprom_schleife:

// starte lesevorgang
lpm r18 , z+
lpm r17 ,z+
lpm r16 ,z+

rcall eeprom_start
rcall eeprom_start_read
sts eeprom_speicher+4, r18
sts eeprom_speicher+5, r17
sts eeprom_speicher+6, r16
rcall eeprom_send_adress

rcall eeprom_read
rcall eeprom_read
sts eeprom_speicher+3, r16 ; eeprom_speicher[3] = das gefundene Byte
rcall eeprom_ende

// ist das unser byte ???
lds r16, eeprom_speicher+3
lds r17, eeprom_speicher+1
cp r16, r17
breq eeprom_gefunden
rjmp eeprom_kein_treffer
eeprom_gefunden:

// erstelle neues kontrollbyte
rcall eeprom_start
rcall eeprom_start_write
lds r16, eeprom_speicher+1
inc r16
sts eeprom_speicher+1, r16 ; eeprom_speicher[1] = kontrollbyte
ldi r16 ,0
ldi r17 ,0
ldi r18 ,0
rcall eeprom_send_adress
lds r16, eeprom_speicher+1
rcall eeprom_write
//rcall eeprom_ende
rcall eeprom_end_write

// prüfe das zweite kontrollbyte erneut
rcall eeprom_start
rcall eeprom_start_read
lds r18,eeprom_speicher+4 
lds r17,eeprom_speicher+5 
lds r16,eeprom_speicher+6 
rcall eeprom_send_adress
rcall eeprom_read
rcall eeprom_read
sts eeprom_speicher+3, r16 ; eeprom_speicher[3] = das gefundene Byte
rcall eeprom_ende

// ist das zweite byte auch unseres ???
lds r16, eeprom_speicher+3
lds r17, eeprom_speicher+1
cp r16, r17
brne eeprom_kein_treffer 

// eeprom gefunden
lds r16, eeprom_speicher+4
sts eeprom_res2, r16
lds r16,eeprom_speicher+5
sts eeprom_res1, r16
lds r16,eeprom_speicher+6
sts eeprom_res0, r16
rjmp eeprom_schleife_ende

eeprom_kein_treffer:


lds r16, eeprom_speicher+2
dec r16
sts eeprom_speicher+2, r16
cpi r16, 0
breq eeprom_schleife_ende
rjmp eeprom_schleife
eeprom_schleife_ende:

ret


;#############################################
;######### ermittelt die seitengröße #########
;################ eines eeprom ###############
;########### 16B,32B,64B,128B,256B ###########
;#############################################
;######## out: res0+1 = seitengröße  #########
;############# res0 = 0 -> fehler ############
;#############################################
eeprom_ermittle_seitengroesse:
push r17
push r18

ldi r16, 0
sts eeprom_res2, r16
sts eeprom_res1, r16
sts eeprom_res0, r16

ldi zl, low(eeprom_seitenspruenge*2)
ldi zh, high(eeprom_seitenspruenge*2)

// schreibe erstes byte als markierung
rcall eeprom_start
rcall eeprom_start_write

ldi r16 ,0
ldi r17 ,0
ldi r18 ,0
rcall eeprom_send_adress

ldi r16, 0
rcall eeprom_write
//rcall eeprom_ende
rcall eeprom_end_write

ldi r17,1 // hier wird die aktuelle zellposition gespeichert
sts eeprom_speicher+1, r17 ; eeprom_speicher[1] = zellposition

ldi r16,5
sts eeprom_speicher+2, r16 ; eeprom_speicher[2] = anzahl möglicher seitentypen
eeprom_schleife2:


// schreibe testdaten
rcall eeprom_start
rcall eeprom_start_write
lds r16 ,eeprom_speicher+1
ldi r17 ,0
ldi r18 ,0
rcall eeprom_send_adress

ldi r16, 255

lpm r18, z
eeprom_schreibe:
rcall eeprom_write
dec r18
brne eeprom_schreibe

//rcall eeprom_ende
rcall eeprom_end_write

// lies erstes byte
rcall eeprom_start
rcall eeprom_start_read
ldi r18,0 
ldi r17,0 
ldi r16,0
rcall eeprom_send_adress

rcall eeprom_read
sts eeprom_speicher+3, r16 ; eeprom_speicher[3] = das gefundene Byte
rcall eeprom_ende

lds r17, eeprom_speicher+1
lpm r18, z+
add r17, r18
sts eeprom_speicher+1,r17

// prüfe ob überlauf
lds r16, eeprom_speicher+3
cpi r16, 255
brne no_treffer2
lds r17, eeprom_speicher+1
dec r17
dec r17
sts eeprom_res0, r17
rjmp eeprom_schleife_ende2
no_treffer2:


lds r16, eeprom_speicher+2
dec r16
sts eeprom_speicher+2, r16
cpi r16, 0
breq eeprom_schleife_ende2
rjmp eeprom_schleife2
eeprom_schleife_ende2:


pop r18
pop r17
ret
