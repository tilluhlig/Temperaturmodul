;#########################
;######### SRAM ##########
;######### SRAM ##########
;######### SRAM ##########
;#########################
 .DSEG

// ARBEITSDATEN
// temp speicher zum rechnen
eeprom_speicher: .BYTE   9

// hier drin werden die ergebnisse gespeichert
eeprom_res2: .BYTE 1
eeprom_res1: .BYTE 1
eeprom_res0: .BYTE 1



// eingabedaten (blockübergabe)
eeprom_input: .BYTE 16


// GEWÄHLTES EEPROM
// welches eeprom ist ausgewählt
eeprom_id: .BYTE 1

// welche adresslänge hat das gewählte eeprom
eeprom_adresslaenge: .BYTE 1

// welche seitengroesse hat das gewählte eeprom
eeprom_seitengroesse: .BYTE 1

// höchste adresse des gewählten eeprom
eeprom_adressen: .BYTE 3

// wieviele bloecke hat das gewählte eeprom
eeprom_bloecke: .BYTE 3

// wieviele seiten hat das eeprom
eeprom_seiten: .BYTE 2

// wieviele blöcke pro seite hat das eeprom
eeprom_blockseite: .BYTE 1


// GESAMTDATEN
// welche blockgroesse hat die datenstruktur
eeprom_blockgroesse: .BYTE 1

// wieviele bloecke gibt es in der gesamten datenstruktur
eeprom_bloecke_gesamt: .BYTE 3


// EINZELDATEN
// welche adresslänge hat das eeprom
eeprom_adresslaenge_alle: .BYTE 4

// welche seitengroesse hat das eeprom
eeprom_seitengroesse_alle: .BYTE 4

// höchste adresse des eeprom
eeprom_adressen_alle: .BYTE 12

// wieviele bloecke hat das eeprom
eeprom_bloecke_alle: .BYTE 12

// wieviele seiten hat das eeprom
eeprom_seiten_alle: .BYTE 8

// wieviele blöcke pro seite hat das eeprom
eeprom_blockseite_alle: .BYTE 4

// ist einer der eeprom fehlerhaft
eeprom_fehler: .BYTE 4


// gibt an, ob die datenstruktur korrekt eingerichtet ist
eeprom_aktiv: .BYTE 1


// SCHREIBPOSITION (anfang der daten)
// welches eeprom
eeprom_anfang_id: .BYTE 1

// auf welcher seite befindet er sich
eeprom_anfang_seite: .BYTE 2

// welcher block der seite ist es
eeprom_anfang_blockderseite: .BYTE 1

// welche adresse ist es (zum senden der adresse an eeprom)
eeprom_anfang_adresse: .BYTE 3

// welcher block in gesamter datenstruktur (damit man weis, ob noch blöcke kommen und für begrenzung)
eeprom_anfang_blockinstruktur: .BYTE 3

eeprom_anfang_kontrollbit: .BYTE 1

eeprom_anfang_hatanfang: .BYTE 1


// SONSTIGES
eeprom_fehler_blinken: .BYTE 1
