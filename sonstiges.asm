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
	   	ldi temp1, 255
wait5ms_:
   	//	wdr				; WATCH-DOG	
	NOP
	NOP
	NOP
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
wait500ms:                               
	push temp1           ; temp1 auf dem Stack sichern            
	ldi temp1, 100
	sh:
	rcall wait5ms
	dec temp1
	brne sh	                 
	pop temp1      		; temp1 wiederherstellen                    
ret
