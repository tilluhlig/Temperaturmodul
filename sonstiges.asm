/*.macro lsr2
lsr @0
lsr @0
.endm

.macro lsr3
lsr @0
lsr @0
lsr @0
.endm

.macro lsr4
lsr @0
lsr @0
lsr @0
lsr @0
.endm

.macro lsr5
lsr @0
lsr @0
lsr @0
lsr @0
lsr @0
.endm

.macro lsr6
lsr @0
lsr @0
lsr @0
lsr @0
lsr @0
lsr @0
.endm

.macro lsr7
lsr @0
lsr @0
lsr @0
lsr @0
lsr @0
lsr @0
lsr @0
.endm

.macro lsl2
lsl @0
lsl @0
.endm

.macro lsl3
lsl @0
lsl @0
lsl @0
.endm

.macro lsl4
lsl @0
lsl @0
lsl @0
lsl @0
.endm

.macro lsl5
lsl @0
lsl @0
lsl @0
lsl @0
lsl @0
.endm

.macro lsl6
lsl @0
lsl @0
lsl @0
lsl @0
lsl @0
lsl @0
.endm

.macro lsl7
lsl @0
lsl @0
lsl @0
lsl @0
lsl @0
lsl @0
lsl @0
.endm*/


; ##############################################################################
; ##############################################################################
; ##############################################################################
;Längere Pause für manche Befehle;5ms Pause										
wait5ms:                               
	push temp1           ; temp1 auf dem Stack sichern            
	push temp2           ; temp2 auf dem Stack sichern            
;------------
        ldi temp2,5 * FAKTOR // von 6
wait5ms_2:
	   	ldi temp1, 200
wait5ms_:
   	//	wdr				; WATCH-DOG	
	NOP
//	NOP
//	NOP
		dec  temp1
        brne wait5ms_

        dec  temp2
        brne wait5ms_2
;------------
	pop temp2      		; temp2 wiederherstellen                    
	pop temp1      		; temp1 wiederherstellen                    
ret


; ##############################################################################
; ##############################################################################
; ##############################################################################
;Längere Pause für manche Befehle;5ms Pause										
wait5ms2:                               
	push temp1           ; temp1 auf dem Stack sichern            
	push temp2           ; temp2 auf dem Stack sichern            
;------------
        ldi temp2,5 * FAKTOR // von 6
wait5ms_23:
	   	ldi temp1, 200
wait5ms_3:
   	//	wdr				; WATCH-DOG	
	NOP
	//NOP
	//NOP
		dec  temp1
        brne wait5ms_3

        dec  temp2
        brne wait5ms_23
;------------
	pop temp2      		; temp2 wiederherstellen                    
	pop temp1      		; temp1 wiederherstellen                    
ret

; ##############################################################################
; ##############################################################################
; ##############################################################################
;Längere Pause für manche Befehle;5ms Pause										
wait500ms:                               
	push temp1           ; temp1 auf dem Stack sichern            
	ldi temp1, 100
	sh:
	rcall wait5ms2
	dec temp1
	brne sh	                 
	pop temp1      		; temp1 wiederherstellen                    
ret


; ##############################################################################
; ##############################################################################
; ##############################################################################
; INP: temp3																
; OUT: temp3+2 (z.B."FF") 		!!!Achtung Rückwärts, erst temp3, dann temp2!!!											
FUNKTION_HEX:
	; SICHERUNGSKOPIE						
	push temp
	; 1-er STELLE		
	mov temp2,temp3
	mov temp,temp3	

	rcall FUNKTION_HEX_UMWANDLUNG
	mov temp3,temp
	; 10-er STELLE		
	mov temp,temp2	
	; NIBBLES tausch	
	swap temp
	rcall FUNKTION_HEX_UMWANDLUNG
	mov temp2,temp
	; SICHERUNGSKOPIE wieder herstellen		
	pop temp
	ret
;-------------------------------------------------------------------------------
FUNKTION_HEX_UMWANDLUNG:
	; BITMUSTER	
	andi temp,0b00001111
	; vergleich	
	cpi temp,0
	breq FUNKTION_HEX_0
	cpi temp,1
	breq FUNKTION_HEX_1
	cpi temp,2
	breq FUNKTION_HEX_2
	cpi temp,3
	breq FUNKTION_HEX_3
	cpi temp,4
	breq FUNKTION_HEX_4
	cpi temp,5
	breq FUNKTION_HEX_5
	cpi temp,6
	breq FUNKTION_HEX_6
	cpi temp,7
	breq FUNKTION_HEX_7
	cpi temp,8
	breq FUNKTION_HEX_8
	cpi temp,9
	breq FUNKTION_HEX_9
	cpi temp,10
	breq FUNKTION_HEX_A
	cpi temp,11
	breq FUNKTION_HEX_B
	cpi temp,12
	breq FUNKTION_HEX_C
	cpi temp,13
	breq FUNKTION_HEX_D
	cpi temp,14
	breq FUNKTION_HEX_E
	cpi temp,15
	breq FUNKTION_HEX_F

FUNKTION_HEX_0:
	ldi temp,'0'
	ret
FUNKTION_HEX_1:
	ldi temp,'1'
	ret
FUNKTION_HEX_2:
	ldi temp,'2'
	ret
FUNKTION_HEX_3:
	ldi temp,'3'
	ret
FUNKTION_HEX_4:
	ldi temp,'4'
	ret
FUNKTION_HEX_5:
	ldi temp,'5'
	ret
FUNKTION_HEX_6:
	ldi temp,'6'
	ret
FUNKTION_HEX_7:
	ldi temp,'7'
	ret
FUNKTION_HEX_8:
	ldi temp,'8'
	ret
FUNKTION_HEX_9:
	ldi temp,'9'
	ret
FUNKTION_HEX_A:
	ldi temp,'A'
	ret
FUNKTION_HEX_B:
	ldi temp,'B'
	ret
FUNKTION_HEX_C:
	ldi temp,'C'
	ret
FUNKTION_HEX_D:
	ldi temp,'D'
	ret
FUNKTION_HEX_E:
	ldi temp,'E'
	ret
FUNKTION_HEX_F:
	ldi temp,'F'
ret
