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
rcall send_register
ret
