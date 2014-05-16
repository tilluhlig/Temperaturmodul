;#########################
;######## EEPROM #########
;######## EEPROM #########
;######## EEPROM #########
;#########################
.ESEG
// GESAMTDATEN
// welche blockgroesse hat das datensystem
eeprom_intern_blockgroesse: .BYTE 1

// wieviele bloecke gibt es im gesamten system
eeprom_intern_bloecke_gesamt: .BYTE 3


// EINZELDATEN
// welche adresslänge hat das eeprom
eeprom_intern_adresslaenge: .BYTE 4

// welche seitengroesse hat das eeprom
eeprom_intern_seitengroesse: .BYTE 4

// höchste adresse des eeprom
eeprom_intern_adressen: .BYTE 12

// wieviele bloecke hat das eeprom
eeprom_intern_bloecke: .BYTE 12

// wieviele seiten hat das eeprom
eeprom_intern_seiten: .BYTE 8

// wieviele blöcke pro seite hat das eeprom
eeprom_intern_blockseite: .BYTE 4

// ist einer der eeprom fehlerhaft
eeprom_intern_fehler: .BYTE 4
