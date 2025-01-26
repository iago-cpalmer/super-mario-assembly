; -- Dynamic memory system
DMMBLKS     EQU     64                      ; Block size
DMMNBLK     EQU     300                     ; Number of blocks


; --- OCCUPIES THE FIRST FREE BLOCK IN DYNAMIC MEMORY
;     Input:
;           - None
;     Output:
;           - A0.L - Slot of data in dynamic memory
;     Modifies:
;           - Dynamic memory
; ---------------------------------------------------------------------------
DMALLOC
            MOVEM.L D0-D2,-(A7)
            LEA.L   DYNMEM,A0
            MOVE.W  #DMMNBLK-1,D0
            MOVE.W  #-DMMBLKS,D1
.LOOP            
            ADD.W   #DMMBLKS,D1
            MOVE.W  0(A0,D1.W),D2
            CMP.W   #0,D2 
            BNE     .OUTLOOP                ; Check if that block is occupied      
            DBRA    D0,.LOOP
.OUTLOOP            
            ; It's free
            ADD.L   D1,A0
            MOVE.W  #0,(A0)
            ADD.L   #2,A0
            MOVEM.L (A7)+,D0-D2
            RTS


; --- FREES THE GIVEN BLOCK OF DYNAMIC MEMORY
;     Input:
;           - A0.L - Slot of data in dynamic memory
;     Output:
;           - None
;     Modifies:
;           - Dynamic memory
; ---------------------------------------------------------------------------
DMFREE
            SUBQ.W   #2,A0
            MOVE.W  #1,(A0)
            RTS

DYNMEM      DS.B    DMMBLKS*DMMNBLK        ; Dynamic memory space
            DS.W    0                      ; In case it's not power of 2


*~Font name~Courier New~
*~Font size~9~
*~Tab type~0~
*~Tab size~4~
