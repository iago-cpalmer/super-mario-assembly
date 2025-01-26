; -----------------------------------------------------------------------------
SYSINIT
; INITIALIZES THE SYSTEM
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVE.L  (A7)+,A0                ; GET RETURN ADDRESS
            JSR     KBDINIT                 ; INIT KEYBOARD
            JSR     SCRINIT                 ; INIT SCREEN
            ANDI.W  #$DFFF,SR               ; SWITCH TO USER
            MOVE.L  A0,-(A7)                ; PUT RETURN ADDRESS
            RTS


; -----------------------------------------------------------------------------
SCRINIT
; INITIALIZES THE SCREEN, SCREEN-RELATED INTERRUPT AND VARS.
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - D0,D1,D2,D3
; -----------------------------------------------------------------------------
            ORI.W   #$0700,SR               ; DISABLE ALL INT
            MOVE.L  #SCRUPD,($80+WDUTRAP*4) ; INSTALL TRAP
            MOVE.L  #WDWIDTH<<16|WDHEIGHT,D1 ; SET RESOLUTION
            MOVE.B  #33,D0
            TRAP    #15
            MOVE.L  #1,D1                   ; SET WINDOWED MODE
            TRAP    #15
            MOVE.W  #$FF00,D1               ; CLEAR VISIBLE BUFFER
            MOVE.B  #11,D0
            TRAP    #15
            MOVE.B  #17,D1                  ; ENABLE DOUBLE BUFFER
            MOVE.B  #92,D0
            TRAP    #15
            MOVE.W  #$FF00,D1               ; CLEAR HIDDEN BUFFER
            MOVE.B  #11,D0
            TRAP    #15
            MOVE.L  #SCRISR,($60+WDIRQ*4)  ; SET EXCEPTION VECTOR
            MOVE.B  #5,D1                   ; ENABLE EXCEPTION PROCESSING
            MOVE.B  #32,D0
            TRAP    #15
            MOVE.B  #%10000000|WDIRQ,D2    ; ENABLE AUTO-IRQ
            MOVE.B  #WDRTIME,D3
            MOVE.B  #6,D1
            MOVE.B  #32,D0
            TRAP    #15
            CLR.B   (SCRINTCT)              ; PREPARE INTERRUPT FLAG
            CLR.B   (SCRCYCCT)              ; PREPARE CYCLE COUNTER
            ANDI.W  #$F8FF,SR               ; ENABLE INTS

            RTS

; -----------------------------------------------------------------------------
SCRISR
; SCREEN TIMER ISR. INCREASES THE INTERRUPT COUNTER AND UPDATES DOUBLE BUFFER.
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            ADDQ.B  #1,(SCRINTCT)           ; UPDATE INT FLAG/COUNTER
            ADDQ.B  #1,(SCRCYCCT)           ; UPDATE CYCLE COUNTER
            RTE


; -----------------------------------------------------------------------------
SCRUPD
; TRAP SERVICE ROUTINE IN CHARGE OF VISUALIZING CURRENT FRAME AND CLEARING
; BUFFER FOR THE NEXT ONE.
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.W D0-D1,-(A7)
            MOVE.B  #94,D0                  ; UPDATE DOUBLE BUFFER
            TRAP    #15
            MOVE.W  #$FF00,D1               ; CLEAR HIDDEN BUFFER
            MOVE.B  #11,D0
            TRAP    #15
            MOVEM.W (A7)+,D0-D1
            RTE


; -----------------------------------------------------------------------------
KBDINIT
; INITIALIZES THE SYSTEM VARIABLES KBDSYS AND KBDVAL
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            CLR.B   (KBDVAL)                ; INIT VARS
            CLR.B   (KBDEDGE)
            MOVE.L  #KBDREAD,($80+KBUTRAP*4) ; INSTALL
            RTS
            
; -----------------------------------------------------------------------------
KBDREAD
; TRAP SERVICE ROUTINE.
; UPDATES THE SYSTEM VARIABLES KBDEDGE AND KBDVAL ACCORDING TO THE BITFIELD
; DESCRIBED IN SYSCONST. KBDVAL HOLDS THE CURRENT VALUES AND KBDEFGE HOLDS
; RISING EDGES FROM PREVIOUS CALL TO THE CURRENT ONE.
; INPUT    - NONE
; OUTPUT   - (KBDVAL) AND (KBDEDGE)
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0-D3,-(A7)
            MOVE.B  #19,D0
            MOVE.L  #KEYRGHT<<24+KEYLEFT<<16+KEYDOWN<<8+KEYUP,D1
            TRAP    #15
            BSR     .STORE                  ; STORE UP, DOWN, LEFT AND RIGHT
            MOVE.B  (KBDVAL),D0             ; COMPUTE EDGE.
            NOT.B   D0                      ; EDGE=NOT(PREVIOUS) AND CURRENT.
            AND.B   D2,D0
            MOVE.B  D2,(KBDVAL)             ; STORE VALUES (PRESS AND EDGE)
            MOVE.B  D0,(KBDEDGE)
            
            ; READ THE MOUSE POSITION AND INPUT
            MOVE.B  #0,D1                   ; GET CURRENT MOUSE STATE
            MOVE.W  #61,D0                  ; READ MOUSE STATE
            TRAP    #15
            MOVE.W  D1,MOUXPOS              ; STORE MOUSE X POSITION
            LSR.L   #8,D1                   ; SHIFT BYTE TO RIGHT
            LSR.L   #8,D1                   ; SHIFT BYTE TO RIGHT
            MOVE.W  D1,MOUYPOS              ; STORE MOUSE Y POSITION
            AND.B   #$01,D0                 ; READ ONLY LEFT CLICK
            MOVE.B  D0,MOUBSTA              ; STORE CURRENT NEEDED MOUSE STATE   
            MOVEM.L (A7)+,D0-D3
            RTE

.STORE      MOVE.W  #3,D3                   ; TRANSLATES THE 8-BIT ENCODING
.LOOP       LSL.L   #8,D1                   ; OF TRAP #15 TASK 19 INTO A 1-BIT
            ROXL.B  #1,D2                   ; PER KEYPRESS ENCODING
            DBRA.W  D3,.LOOP
            RTS


; -----------------------------------------------------------------------------
STRINIT
; SETS THE FONT PROPERTIES
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0-D3,-(A7)
            MOVEM.L A0,-(A7)
                       
            ; SET FONT
            MOVE.L  #$00FFFFFF,D1           ; SET COLOR
            
            MOVE.L  #1,D2                   ; SET BOLD
            
            MOVE.L  #18*2,D3                ; SET SIZE IN POINTS
            LSL.L   #8,D3                   
            LSL.L   #8,D3                   ; GET IN HIGH WORD, LOW BYTE                  
            OR.L    D3,D2                   ; WRITE IT ON D2
            
            MOVE.L  #1,D3                   ; FONT: FIXEDSYS
            LSL.L   #8,D3                   
            LSL.L   #8,D3
            LSL.L   #8,D3                   ; GET IN HIGH WORD, HIGH BYTE         
            OR.L    D3,D2                   ; WRITE IT ON D2
            
            MOVE.W  #21,D0
            TRAP    #15
            
            
            ; LEAVE SUBROUTINE
            MOVEM.L (A7)+,A0
            MOVEM.L (A7)+,D0-D3
            RTS










*~Font name~Courier New~
*~Font size~9~
*~Tab type~0~
*~Tab size~4~
