; UTILS FILE
; CHECK IF A POINT (X,Y) IS INSIDE A BOUNDING BOX
; D1.W      - X COORD OF POINT
; D2.W      - Y COORD OF POINT
; D3.W      - LEFT-TOP X COORD
; D4.W      - LEFT-TOP Y COORD
; D5.W      - RIGHT-BOTTOM X COORD
; D6.W      - RIGHT-BOTTOM Y COORD
;           RETURNS:
;           D0.B    - 0 IF NOT INSIDE, 1 IF INSIDE
CHKINBBO
            ; LEFT-TOP CORNER
            CMP.W   D3,D1                   ; COMPARE X COORDS
            BLT     .OUT                    ; IS OUTSIDE OF BOUNDING BOX
            CMP.W   D4,D2                   ; COMPARE Y COORDS
            BLT     .OUT                    ; IS OUTSIDE OF BOUNDING BOX
            
            ; RIGHT-BOTTOM CORNER
            CMP.W   D5,D1                   ; COMPARE X COORDS
            BGT     .OUT
            CMP.W   D6,D2                   ; COMPARE Y COORDS
            BGT     .OUT
            ; IT'S INSIDE BOUNDING BOX
            MOVE.B  #1,D0                   ; RETURN 1, IT'S IN BOUNDING BOX
            BRA     .RTN
.OUT
            MOVE.B  #0,D0                   ; RETURN 0, IT'S OUT OF BOUNDING BOX
.RTN
            RTS      


; Subroutine to calculate top-left corner for centered string drawing
; Input: A1 = Address of string, D1 = Center X, D2 = Center Y
; Output: D1 = Top-left X, D2 = Top-left Y
; Assumes fixed character width of 36 pixels

CALCCENTERSTR
            MOVE.L  D3,-(A7)
            MOVE.L  D0,-(A7)
            MOVE.L  A2,-(A7)

            MOVE.W  #0, D0         ; D0 will be used to count the string length
            MOVE.L A1, A2         ; Copy string address to A2 to preserve A1

            ; Calculate length of the string
COUNT_LOOP:
            MOVE.B  (A2)+, D3  ; Load next character into D3
            CMP.B   #0,D3
            BEQ     END_COUNT  ; If character is 0 (string terminator), end loop
            ADDQ.W  #1, D0     ; Increment string length count
            BRA     COUNT_LOOP
END_COUNT:

            ; Calculate total string width
            MOVE.W  D0, D3         ; Move string length to D3
            MULU.W  #36, D3        ; D3 = String Length * Character Width (36 pixels)

            ; Adjust D1 and D2 to get top-left coordinates
            LSR.W   #1, D3         ; D3 = D3 / 2 (half width of string)
            SUB.W   D3, D1         ; Adjust X-coordinate
            ; Adjust Y-coordinate if necessary (depends on character height)
            ; SUB.W   #HalfCharHeight, D2
            
            MOVE.L  (A7)+,A2
            MOVE.L  (A7)+,D0
            MOVE.L  (A7)+,D3
            
            RTS  ; Return with D1 and D2 containing top-left coordinates
            

; SUBROUTINE TO DRAW IMAGE
; INPUT:    A1.L    - POINTER TO IMAGE
;           D5.L    - X (HIGH WORD) OF LEFT-TOP CORNER, Y (LOW WORD) OF LEFT-TOP CORNER
DRAWIMG

            MOVEM.L D0-D7,-(A7)
            MOVEM.L A0-A1,-(A7)
            ADD.W   #PXSCALE*2,D5
            CLR.W   D6                      ; CLEAR D6 TO STORE X COORDINATE OF PIXEL
            CLR.W   D7                      ; CLEAR D7 TO STORE Y COORDINATE OF PIXEL
.LOOP
            MOVE.L  (A1)+,D1                ; GET COLOR
            CMP.W   #0,D1
            BEQ     .NEXT                   ; IF IT'S BLACK, SKIP IT, AS ALPHA
            MOVE.W  #81,D0                  ; SET FILL COLOR
            TRAP    #15
            MOVE.W  #80,D0                  ; SET EDGE COLOR            
            TRAP    #15
            
            MOVE.L  D5,D1                   ; GET X COORD
            LSR.L   #8,D1
            LSR.L   #8,D1                   ; GET X COORD IN LOW WORD
            ADD.W   D6,D1                   ; GET X COORD OF IMGPX TO DRAW
            MOVE.W  D1,D3                   ; GET X COORD IN D3
            ADD.W   #PXSCALE,D3             ; GET X OFFSET OF IMGPX,
            MOVE.W  D5,D2                   ; GET Y COORD
            ADD.W   D7,D2                   ; GET Y COORD OF IMGPX TO DRAW
            MOVE.W  D2,D4                   ; GET Y COORD IN D4
            ADD.W   #PXSCALE,D4             ; GET Y OFFSET OF IMGPX
            
            MOVE.W  #87,D0                  ; DRAW RECTANGLE (IMGPX)
            TRAP    #15
.NEXT            
            CMP.W   #TILEPXS-PXSCALE*3,D6
            BGE     .NEXTYCO                ; RESET X PX OFFSET AND GET NEW Y OFFSET
            ADD.W   #PXSCALE,D6             ; NEXT PX OFFSET
            BRA     .LOOP
.NEXTYCO    
            CMP.W   #TILEPXS-PXSCALE*3,D7
            BGE    .LEAVE
            MOVE.W  #0,D6                   ; RESET X OFFSET
            ADD.W   #PXSCALE,D7             ; GET NEW Y OFFSET
            BRA     .LOOP
.LEAVE             
            MOVEM.L (A7)+,A0-A1
            MOVEM.L (A7)+,D0-D7
            RTS
            
; SUBROUTINE TO UPDATE FRAME OF ANIMATION
UPDANIMFRAME
            MOVEM.L D0,-(A7)        
            MOVE.W  ANIMACTI,D0
            ADDQ.W  #1,D0
            CMP.W   #ANIMTIME,D0
            BGE     .NEXTFRAME
            MOVE.W  D0,ANIMACTI 
            BRA     .RTN
.NEXTFRAME
            ADDQ.W  #1,ANIMFRAME
            MOVE.W  #0,ANIMACTI
.RTN            
            MOVEM.L (A7)+,D0
            RTS

; A1.L      POINTER TO ANIMATION
; RETURNS A1.L - POINTER TO IMAGE
GETIMGOFANIM
            MOVEM.L D0-D1,-(A7)
            MOVE.W  (A1)+,D0                 ; GET NUMBER OF FRAMES OF THE GIVEN ANIMATION
            MOVE.W  ANIMFRAME,D1            ; GET CURRENT FRAME OF ANIMATION
            DIVU.W  D0,D1                   
            LSR.L   #8,D1
            LSR.L   #8,D1                   ; GET CURRENT NUMBER OF FRAME OF GIVEN ANIMATION FROM GLOBAL ANIMATION FRAME NUMBER
            MULU.W  #4,D1                   ; GET OFFSET OF IMAGE IN POINTER
            ADD.L   D1,A1
            MOVE.L  (A1),A1
            MOVEM.L (A7)+,D0-D1
            RTS


*~Font name~Courier New~
*~Font size~9~
*~Tab type~0~
*~Tab size~4~
