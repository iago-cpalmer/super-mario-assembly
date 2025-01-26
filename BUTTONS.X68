;BUTTON CONSTANTS
STBUTWD     EQU     WDWIDTH/5               ; WDITH OF BUTTONS
STBUTHT     EQU     WDHEIGHT/10             ; HEIGHT OF BUTTONS

; BUTTON STATE CONSTANTS
BTNSTANH    EQU     0                       ; BUTTON NOT HOVERED
BTNSTAHO    EQU     1                       ; BUTTON HOVERED
BTNSTACL    EQU     2                       ; BUTTON CLICKED

; BUTTON OFFSET CONSTANTS
OFFBEDC     EQU     0                       ; OFFSET TO EDGE COLOR
OFFBCST     EQU     4                       ; OFFSET TO STATE OF BUTTON
OFFFNHO     EQU     6                       ; OFFSET TO FILL COLOR WHEN NOT HOVERED
OFFFHOC     EQU     10                      ; OFFSET TO FILL COLOR WHEN HOVERED
OFFFCLC     EQU     14                      ; OFFSET TO FILL COLOR WHEN CLICKED
OFFLTCX     EQU     18                      ; OFFSET TO LT CORNER X POS
OFFLTCY     EQU     20                      ; OFFSET TO LT CORNER Y POS
OFFRBCX     EQU     22                      ; OFFSET TO RB CORNER X POS
OFFRBCY     EQU     24                      ; OFFSET TO RB CORNER Y POS
OFFCLSU     EQU     26                      ; OFFSET TO ON CLICK SUBROUTINE
OFFBSTR     EQU     30                      ; OFFSET TO STRING OF BUTTON
; BUTTONS INFO
STARTBUT
            DC.L    $00FFFFFF               ; EDGE COLOR
            DC.W    0                       ; CURRENT STATE OF BUTTON
            DC.L    $00000000               ; FILL COLOR NOT HOVERED
            DC.L    $00AAAAAA               ; FILL COLOR ON HOVER
            DC.L    $00444444               ; FILL COLOR WHEN CLICKED
            DC.W    (WDWIDTH-STBUTWD)/2     ; LEFT-TOP CORNER X POS
            DC.W    (WDHEIGHT-STBUTHT)/2    ; LEFT-TOP CORNER Y POS
            DC.W    (WDWIDTH+STBUTWD)/2     ; RIGHT-BOTTOM CORNER X POS
            DC.W    (WDHEIGHT+STBUTHT)/2    ; RIGHT-BOTTOM CORNER Y POS
            DC.L    STARTGAME               ; POINTER TO SUBROUTINE TO CALL WHEN CLICKED
            DC.L    STRSTARTBUTTON          ; POINTER TO STRING
RETURNBUT
            DC.L    $00FFFFFF               ; EDGE COLOR
            DC.W    0                       ; CURRENT STATE OF BUTTON
            DC.L    $00000000               ; FILL COLOR NOT HOVERED
            DC.L    $00AAAAAA               ; FILL COLOR ON HOVER
            DC.L    $00444444               ; FILL COLOR WHEN CLICKED
            DC.W    (WDWIDTH-STBUTWD)/2    ; LEFT-TOP CORNER X POS
            DC.W    (WDHEIGHT-STBUTHT)/2    ; LEFT-TOP CORNER Y POS
            DC.W    (WDWIDTH+STBUTWD)/2     ; RIGHT-BOTTOM CORNER X POS
            DC.W    (WDHEIGHT+STBUTHT)/2    ; RIGHT-BOTTOM CORNER Y POS
            DC.L    RETURN                  ; POINTER TO SUBROUTINE TO CALL WHEN CLICKED
            DC.L    STRRETURN               ; POINTER TO STRING            
EXITBUT
            DC.L    $00FFFFFF               ; EDGE COLOR
            DC.W    0                       ; CURRENT STATE OF BUTTON
            DC.L    $00000000               ; FILL COLOR NOT HOVERED
            DC.L    $00AAAAAA               ; FILL COLOR ON HOVER
            DC.L    $00444444               ; FILL COLOR WHEN CLICKED
            DC.W    (WDWIDTH-STBUTWD)/2     ; LEFT-TOP CORNER X POS
            DC.W    (WDHEIGHT-STBUTHT)/2+STBUTHT    ; LEFT-TOP CORNER Y POS
            DC.W    (WDWIDTH+STBUTWD)/2     ; RIGHT-BOTTOM CORNER X POS
            DC.W    (WDHEIGHT+STBUTHT)/2+STBUTHT    ; RIGHT-BOTTOM CORNER Y POS
            DC.L    EXIT                    ; POINTER TO SUBROUTINE TO CALL WHEN CLICKED
            DC.L    STREXIT                 ; POINTER TO STRING              
; SUBROUTINE TO CHECK IF MOUSE IS INSIDE A GIVEN BUTTON
; --- SUBROUTINE TO UPDATE MOUSE STATE, ALSO CALLS ITS SUBROUTINE WHEN CLICKED
;     Input:
;           - A1.L      - POINTER TO BUTTON
;     Output:
;           - None
;     Modifies:
;           - None
; ---------------------------------------------------------------------------
CHKMOUBUT
            MOVEM.L D0-D6,-(A7)
            MOVEM.L  A1,-(A7)
            MOVE.W  OFFLTCX(A1),D3
            MOVE.W  OFFLTCY(A1),D4
            MOVE.W  OFFRBCX(A1),D5
            MOVE.W  OFFRBCY(A1),D6
            MOVE.W  MOUXPOS,D1
            MOVE.W  MOUYPOS,D2
            JSR CHKINBBO                    ; CHECK IF IT'S INSIDE GIVEN BOUNDING BOX
            CMP.B   #0,D0                   ; CHECK IF IT'S INSIDE OR NOT
            BEQ     .OUTSIDE
            ; IT'S INSIDE
            MOVE.B  MOUBSTA,D0
            CMP.B   #0,D0                   ; CHECK IF MOUSE LEFT CLICK IS PRESSED
            BEQ     .NOTPRESSED
            MOVE.W  #BTNSTACL,OFFBCST(A1)   ; SET STATE TO CLICKED
            BRA     .RTN 
.OUTSIDE    ; MOUSE IS OUTSIDE BUTTON
            MOVE.W  #BTNSTANH,OFFBCST(A1)   ; SET STATE TO NON-HOVERED 
            BRA     .RTN      
.NOTPRESSED 
            CMP.W   #BTNSTACL,OFFBCST(A1)   ; CHECK IF IT WAS LEFT CLICKED BEFORE
            BEQ     .UNCLICKED
            MOVE.W  #BTNSTAHO,OFFBCST(A1)   ; SET STATE TO HOVERED
            BRA     .RTN
.UNCLICKED
            MOVE.W  #BTNSTANH,OFFBCST(A1)   ; SET STATE TO NON-HOVERED 
            MOVE.L  OFFCLSU(A1),A1          ; GET SUBROUTINE TO CALL WHEN CLICKED
            JSR     (A1)
                       
.RTN
            MOVEM.L (A7)+,A1
            MOVEM.L (A7)+,D0-D6
            RTS            

; --- SUBROUTINE TO DRAW A BUTTON & UPDATES ITS STATE
;     Input:
;           - A1.L      - POINTER TO BUTTON
;     Output:
;           - None
;     Modifies:
;           - STATE OF BUTTON
; --------------------------------------------------------------------------- 
RENDERBUTTON
            MOVEM.L D0-D7,-(A7)
            MOVEM.L A1,-(A7)
            
            JSR     CHKMOUBUT               ; UPDATE BUTTON STATE
            
            MOVE.L  (A1),D1                 ; GET EDGE COLOR
            MOVE.W  #80,D0                  ; SET EDGE COLOR
            TRAP    #15
            CLR.L   D1
            MOVE.W  OFFBCST(A1),D1          ; GET CURRENT STATE OF MOUSE 
            MULU.W  #4,D1                   ; GET OFFSET FOR THE POINTER OF FILL COLOR DEPENDING ON STATE
            MOVE.L  OFFFNHO(A1,D1.W),D1     ; GET FILL COLOR
            MOVE.W  #81,D0                  ; SET FILL COLOR
            TRAP    #15
            MOVE.W  OFFLTCX(A1),D1          ; GET LT CORNER X POS
            MOVE.W  OFFLTCY(A1),D2          ; GET LT CORNER Y POS
            MOVE.W  OFFRBCX(A1),D3          ; GET RB CORNER X POS
            MOVE.W  OFFRBCY(A1),D4          ; GET RB CORNER Y POS  
            
            MOVE.W  #87,D0                  ; DRAW RECTANGLE
            TRAP    #15
            
            ; DRAW STRING
            MOVE.L  OFFBSTR(A1),A1
            ADD.W   #(STBUTWD/2)+8,D1
            ADD.W   #8,D2
            JSR     CALCCENTERSTR
            MOVE.W  #95,D0
            TRAP    #15
            
            MOVE.L  #0,D1                 
            MOVE.W  #81,D0                  ; SET EDGE COLOR
            TRAP    #15
            
            MOVEM.L (A7)+,A1
            MOVEM.L (A7)+,D0-D7
            RTS
; --- SUBROUTINE THAT STARTS THE GAME AND RESETS THE GAME VARIABLES 
;     Input:
;           - None
;     Output:
;           - None
;     Modifies:
;           - All game variables
; --------------------------------------------------------------------------- 
STARTGAME     
            MOVEM.L A0-A1,-(A7)
       
            MOVE.W  #1,GAMESTA              ; SETS STATE TO LOAD LEVEL
            ; RESTART ALL PLAYER VARIABLES
            MOVE.W  #1,PLHEALTH
            MOVE.W  #0,CAMX
            MOVE.W  #0,CLVLLOA
            MOVE.W  #200,PLPOSX
            MOVE.W  #200,PLPOSY
            MOVE.W  #0,PLCOIN
            MOVE.W  #0,PLFCEY
            MOVE.W  #0,PLAPWUP
            MOVE.W  #0,PLINVCB
            ; ITERATE THROUGH ENEMY LIST
            LEA.L   ENEMLIS,A0
            BRA     .ENNEXT
.ENLOOP
            MOVE.L  (A0),A1                 ; GET POINTER OF ENEMY IN DYNAMIC MEMORY
            JSR     DMFREE                  ; FREE MEMORY OF ENEMY
            MOVE.L  #$FFFFFFFF,(A0)+         ; SET EMPTY                  
.ENNEXT
            MOVE.L  (A0),A1
            CMP     #$FFFFFFFF,A1           ; CHECK IF THE POINTER IS AN END POINT
            BEQ     .ENSTOP                 
            BRA     .ENLOOP                 ; THERE IS STILL AN ENEMY
.ENSTOP
            MOVEM.L (A7)+,A0-A1
            RTS
            

; --- SUBROUTINE THAT RETURNS TO MAIN MENU 
;     Input:
;           - None
;     Output:
;           - None
;     Modifies:
;           - GAME STATE VARIABLE
; --------------------------------------------------------------------------- 
RETURN          
            MOVE.W  #0,GAMESTA              ; SETS STATE TO LOAD LEVEL
            RTS
                        
            









*~Font name~Courier New~
*~Font size~9~
*~Tab type~0~
*~Tab size~4~
