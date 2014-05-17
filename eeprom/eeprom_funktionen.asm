;#############################################
;##### liest die gesamte datenstruktur #######
;###### und sendet die daten ans uart ########
;##### ACHTUNG beginnt nicht am anfang  ######
;############ der datenstruktur  #############
;#############################################
eeprom_read_data2:
lds r16, eeprom_aktiv
cpi r16, 0
brne eeprom_write_block_ok3
ret
eeprom_write_block_ok3:

cli
push r16
push r17
push r18
push r19
push r20
push r24
push r21

lds r16, eeprom_blockgroesse
rcall send_register
lds r16, eeprom_bloecke_gesamt
rcall send_register
lds r16, eeprom_bloecke_gesamt+1
rcall send_register
lds r16, eeprom_bloecke_gesamt+2
rcall send_register


ldi r24, 0 ; <- welches eeprom wird gerade ausgelesen
eeprom_read_data_schleife:

mov r16, r24
rcall eeprom_select

lds r16, eeprom_blockseite
cpi r16, 0
breq eeprom_read_data_schleife_ende

ldi r18, 0
ldi r17, 0
ldi r16, 0
rcall eeprom_start
rcall eeprom_start_read
rcall eeprom_send_adress

lds r18, eeprom_seiten
lds r17, eeprom_seiten+1

schleife8:

lds r21, eeprom_seitengroesse
inc r21
lds r19, eeprom_blockseite
schleife10:


lds r20, eeprom_blockgroesse
schleife9:
rcall eeprom_read
rcall send_register
dec r21
dec r20
brne schleife9


dec r19
brne schleife10

cpi r21, 0
breq no_rest
schleife12:
rcall eeprom_read
dec r21
brne schleife12
no_rest:

sub r17,EINS
sbc r18, NULL
cpi r17, 0
brne schleife8
cpi r18, 0
brne schleife8

rcall eeprom_ende

eeprom_read_data_schleife_ende:
inc r24
cpi r24,4
brne eeprom_read_data_schleife

pop r21
pop r24
pop r20
pop r19
pop r18
pop r17
pop r16
sei
ret


;#############################################
;########## selektiert ein eeprom ############
;#############################################
;######## in: r16 = id des eeprom ############
;#############################################
eeprom_select:
sts eeprom_id,r16

ldi zl, low(eeprom_adresslaenge_alle)
ldi zh, high(eeprom_adresslaenge_alle)
add zl,r16
adc zh, NULL
ld r17, z
sts eeprom_adresslaenge, r17

ldi zl, low(eeprom_seitengroesse_alle)
ldi zh, high(eeprom_seitengroesse_alle)
add zl,r16
adc zh, NULL
ld r17, z
sts eeprom_seitengroesse, r17

ldi zl, low(eeprom_adressen_alle)
ldi zh, high(eeprom_adressen_alle)
ldi r17, 3
mul r16, r17
add zl,r0
adc zh, NULL
ld r17, z+
sts eeprom_adressen, r17
ld r17, z+
sts eeprom_adressen+1, r17
ld r17, z+
sts eeprom_adressen+2, r17

ldi zl, low(eeprom_bloecke_alle)
ldi zh, high(eeprom_bloecke_alle)
ldi r17, 3
mul r16, r17
add zl,r0
adc zh, NULL
ld r17, z+
sts eeprom_bloecke, r17
ld r17, z+
sts eeprom_bloecke+1, r17
ld r17, z+
sts eeprom_bloecke+2, r17

ldi zl, low(eeprom_seiten_alle)
ldi zh, high(eeprom_seiten_alle)
ldi r17, 2
mul r16, r17
add zl,r0
adc zh, NULL
ld r17, z+
sts eeprom_seiten, r17
ld r17, z+
sts eeprom_seiten+1, r17

ldi zl, low(eeprom_blockseite_alle)
ldi zh, high(eeprom_blockseite_alle)
add zl,r16
adc zh, NULL
ld r17, z
sts eeprom_blockseite, r17

ret


;#############################################
;########## lädt alle daten aus dem ##########
;####### internen eeprom ins sram ############
;#############################################
eeprom_sram_laden:
push r17
ldi zl, low(eeprom_intern_blockgroesse)
ldi zh, high(eeprom_intern_blockgroesse)
ldi xl, low(eeprom_blockgroesse)
ldi xh, high(eeprom_blockgroesse)

ldi r17, 52
eeprom_sram_laden_schleife:
rcall eeprom_intern_read
st x+, r16

add zl, EINS
adc zh, NULL

dec r17
brne eeprom_sram_laden_schleife


pop r17
ret
