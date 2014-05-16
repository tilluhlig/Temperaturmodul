;#############################################
;########## schreibt ein byte ins ############
;############## interne eeprom ###############
;#############################################
;############ in: r16 = daten ################
;#############################################
eeprom_intern_write:
/*push r17
sbic    EECR, EEPE                  ; pr�fe ob der letzte Schreibvorgang beendet ist
rjmp    eeprom_intern_write                ; wenn nein, nochmal pr�fen
 
out     EEARH, ZH                   ; Adresse schreiben
out     EEARL, ZL                   ; 
out     EEDR,r16                    ; Daten  schreiben
in r17, sreg           				; SREG sichern
cli                                 ; Interrupts sperren, die n�chsten
                                    ; zwei Befehle d�rfen NICHT
                                    ; unterbrochen werden
sbi     EECR,EEMPE                  ; Schreiben vorbereiten
sbi     EECR,EEPE                   ; Und los !
out     sreg,r17           			; SREG wieder herstellen

rcall wait5ms
rcall wait5ms

add zl, EINS
adc zh, NULL

pop r17*/
ret


;#############################################
;########## liest ein byte aus dem ###########
;############## internen eeprom ##############
;#############################################
;########### out: r16 = daten ################
;#############################################
eeprom_intern_read:
/*sbic    EECR,EEPE                   ; pr�fe ob der vorherige Schreibzugriff
                                        ; beendet ist
rjmp    eeprom_intern_read                 ; nein, nochmal pr�fen
 
out     EEARH, ZH                   ; Adresse laden
out     EEARL, ZL    
sbi     EECR, EERE                  ; Lesevorgang aktivieren
in      r16, EEDR                   ; Daten in CPU Register kopieren*/
ret
