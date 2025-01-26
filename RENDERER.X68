RENDER
            MOVEM.L D0-D7,-(A7)
            CLR.L   D0
            CLR.L   D1
            CLR.L   D2
            CLR.L   D3
            CLR.L   D4
            CLR.L   D5
            CLR.L   D6
            CLR.L   D7
            MOVEM.L A0-A3,-(A7)
            
            ; RENDER CURRENT STATE OF GAME
            MOVE.W  GAMESTA,D0
            CMP.W   #0,D0
            BEQ     RNDRSTMEN
            CMP.W   #1,D0
            BEQ     RNDRGAM
            CMP.W   #2,D0
            BEQ     RNDRGAM
            CMP.W   #3,D0
            BEQ     RNDRDTHS
            CMP.W   #4,D0
            BEQ     RNDRWINS
RTN            
            MOVEM.L (A7)+,A0-A3
            MOVEM.L (A7)+,D0-D7
            
            RTS  

; RENDERS THE START MENU
RNDRSTMEN
            MOVE.B  #8,D1                   
            MOVE.W  #93,D0                  ; SET EDGE WIDTH
            TRAP    #15
            
            LEA.L   STARTBUT,A1             
            JSR     RENDERBUTTON            ; RENDER START GAME BUTTON
            
            LEA.L   EXITBUT,A1             
            JSR     RENDERBUTTON            ; RENDER EXIT BUTTON
            
            LEA.L   STRGAMETITLE1,A1        ; RENDER STRING OF GAME TITLE
            MOVE.W  #WDWIDTH/2,D1
            MOVE.W  #50,D2
            JSR     CALCCENTERSTR
            MOVE.W  #95,D0
            TRAP    #15
            
            LEA.L   STRGAMETITLE2,A1        ; RENDER STRING OF GAME TITLE
            MOVE.W  #WDWIDTH/2,D1
            MOVE.W  #100,D2
            JSR     CALCCENTERSTR
            MOVE.W  #95,D0
            TRAP    #15
            
            LEA.L   STRCONTROLS1,A1        ; RENDER STRING OF CONTROLS
            MOVE.W  #0,D1
            MOVE.W  #500,D2
            MOVE.W  #95,D0
            TRAP    #15
            
            LEA.L   STRCONTROLS2,A1        ; RENDER STRING OF CONTROLS
            MOVE.W  #02,D1
            MOVE.W  #550,D2
            MOVE.W  #95,D0
            TRAP    #15
            
            LEA.L   STRCONTROLS3,A1        ; RENDER STRING OF CONTROLS
            MOVE.W  #600,D2
            MOVE.W  #95,D0
            TRAP    #15
            
            LEA.L   STRCONTROLS4,A1        ; RENDER STRING OF CONTROLS
            MOVE.W  #650,D2
            MOVE.W  #95,D0
            TRAP    #15
            
            BRA     RTN
            
; RENDERS DEATH SCREEN 
RNDRDTHS

            MOVE.B  #8,D1
            MOVE.W  #93,D0                  ; SET EDGE WIDTH
            TRAP    #15
            
            LEA.L   RETURNBUT,A1            ; RENDER RETURN TO MAIN MENU BUTTON
            JSR     RENDERBUTTON
            
            LEA.L   STRDEATH,A1             ; RENDER DEATH STRING 
            MOVE.W  #WDWIDTH/2,D1
            MOVE.W  #100,D2
            JSR     CALCCENTERSTR
            MOVE.W  #95,D0
            TRAP    #15
            
            BRA     RTN

; RENDERS WIN SCREEN
RNDRWINS 
            MOVE.B  #8,D1
            MOVE.W  #93,D0                  ; SET EDGE WIDTH
            TRAP    #15
            
            LEA.L   RETURNBUT,A1            ; RENDER RETURN TO MAIN MENU BUTTON
            JSR     RENDERBUTTON
            
            LEA.L   STRWINNER,A1            ; RENDER DEATH STRING 
            MOVE.W  #WDWIDTH/2,D1
            MOVE.W  #100,D2
            JSR     CALCCENTERSTR
            MOVE.W  #95,D0
            TRAP    #15
            
            BRA     RTN   
; RENDERS GAME
RNDRGAM
            JSR UPDANIMFRAME
            
            ; compute offset when changing the height of tilemap being drawn
            MOVE.W  MTLWDTH,D5
            SUB.W   #NTILESC,D5
            MULU.W  #2,D5
            ; get camera position
            MOVE.W  CAMX, D0
            DIVS.W  #TILEPXS,D0
            MULU.W  #2,D0                   ; GET POSITION OF WORD
            ; get address of map
            LEA.L   LVLCDAT, A0
            ; get address of first tile 
            LEA.L   TILE1, A1       
            ; get initial position to look up in map     
            ADD.L   D0,A0
            ; DRAW BACKGROUND AS SKY
            MOVE.L  #$00FF9494,D1
            MOVE.W  #81,D0
            TRAP    #15
            MOVE.W  #0,D1
            MOVE.W  #0,D2
            MOVE.W  #WDWIDTH,D3
            MOVE.W  #WDHEIGHT,D4
            MOVE.W  #87,D0
            TRAP    #15                     
            ; iterate through tiles to paint
            MOVE.W  #0,D3                   ; FIRST LOOP
            MOVE.W  #0,D4                   ; SECOND LOOP
            MOVE.B  #8,D1
            MOVE.W  #93,D0
            TRAP    #15
.LOOP
            MOVE.W  (A0)+,D6          ; Store tile id of map
            TST.W   D6
            BEQ     .SKIP
            SUBQ.W   #1,D6
            ; GET OFFSET FOR ADDRESS OF TILE                
            MULU.W  #TILESZB,D6
            
            ; SET FILL COLOR
            MOVE.L  OFFFCLR(A1,D6.W),D1
            MOVE.W  #81,D0
            TRAP #15 
            ; SET PEN COLOR
            MOVE.L  OFFECLR(A1,D6.W),D1
            MOVE.W  #80,D0
            TRAP    #15 
            
            ; DRAW TILE
            ; SAVE IN STACK CURRENT D3 & D4 VALUES FOR LATER
            MOVEM.L  D3-D4,-(A7)
            ; SET COORDINATES IN WINDOW OF TILE TO DRAW
            MULU.W  #TILEPXS,D3
            MULU.W  #TILEPXS,D4
            MOVE.L  A1,A3            
            CLR.L   D1
            MOVE.W  CAMX,D1
            DIVS.W  #TILEPXS,D1
            LSR.L   #8,D1
            LSR.L   #8,D1
            SUB.W   D1,D3
            MOVE.W  D3,D1
            MOVE.W  D4,D2
            ADD.W   #TILEPXS,D3
            ADD.W   #TILEPXS,D4
            MOVE.W  #87,D0
            TRAP    #15

            MOVEM.L (A7)+,D3-D4
            ; NEXT TILE 
.SKIP                  
            ADDQ.W  #1,D3
            CMP.W   #NTILESC,D3
            BNE     .LOOP
.SKIP2            
            ; RESET SECOND LOOP        
            ADD.L   D5,A0
            MOVE.W  #0,D3             
            ADDQ.W  #1,D4
            CMP.W   MTLHGHT,D4
            BNE     .LOOP
            MOVE.W  #0,D4
            
            MOVE.B  #1,D1
            MOVE.W  #93,D0
            TRAP    #15
            
            ; MAP HAS BEEN DRAWN
            ; DRAW PLAYER
            MOVE.W  PLMODI,D0               ; GET CURRENT MOVEMENT OF DIRECTIONS TO FLIP SPRITE
            CMP.W   #-1,D0
            BEQ     .LEFTDIR
            CMP.W   #0,D0
            BEQ     .IDLE
            MOVE.L  PLSPRR1,A1
            BRA     .SKIPDIR
.LEFTDIR
            MOVE.L  PLSPRL1,A1 
            BRA     .SKIPDIR
.IDLE
            MOVE.L  PLSPRID,A1           
.SKIPDIR         
            ; CHECK IF IT'S INVINCIBLE   
            MOVE.W  PLINVCB,D0
            CMP.W   #0,D0
            BGT     .INV
            
            ; CHECK IF IT HAS POWER-UP
            MOVE.W  PLAPWUP,D0
            CMP.W   #0,D0
            BGT     .PWUP
            BRA     .STCLR
.INV
            MOVE.L  PLSPRIV,A1
            BRA     .STCLR
.PWUP       
            MOVE.L  PLSPRMS,A1
            MOVE.W  PLMODI,D0               ; GET CURRENT MOVEMENT OF DIRECTIONS TO FLIP SPRITE
            CMP.W   #-1,D0
            BEQ     .LEFTDIR2
            CMP.W   #0,D0
            BEQ     .STCLR
            MOVE.L  PLSPRMSWR,A1
            BRA     .STCLR
.LEFTDIR2
            MOVE.L  PLSPRMSWL,A1 
.STCLR            
            JSR GETIMGOFANIM                ; GET SPRITE DEPENDING ON CURRENT ANIMATION FRAME
            MOVE.W  PLPOSX,D1
            MOVE.W  PLPOSY,D2
            SUB.W   CAMX,D1
            SUB.W   #TILEPXS/2,D1
            SUB.W   #TILEPXS/2,D2
            MOVE.W  D1,D5
            LSL.L   #8,D5
            LSL.L   #8,D5
            MOVE.W  D2,D5                   ; GET COORDINATES TO DRAW IMAGE
            JSR DRAWIMG

            ; DRAW ENEMIES
            LEA.L   ENEMLIS,A0
            LEA.L   GOOMBA,A2
            MOVE.W  #ENEMCOUN,D4
            BRA     .ENNEXT
.ENLOOP
            MOVE.L  (A0)+,A1                ; GET POINTER OF ENEMY IN DYNAMIC MEMORY
            MOVE.B  ENEMENBL(A1),D0
            CMP.B   #ENSTDSB,D0             ; CHECK IF IT'S DISABLED            
            BLE     .ENNEXT                 ; IT'S DEAD OR DISABLED
            MOVE.W  ENEMXPOS(A1),D1        ; X POSITION IN TILE COORDS
            MOVE.W  ENEMYPOS(A1),D2        ; Y POSITION IN TILE COORDS
            CMP.W   CAMX,D1                 
            BLT     .ENNEXT                 ; IF IT OUT OF SCREEN, DO NOT DRAW
            SUB.W   CAMX,D1
            SUB.W   #TILEPXS/2,D1           ; GET LEFT-TOP CORNER X POSITION
            SUB.W   #TILEPXS/2,D2           ; GET LEXT-TOP CORNER Y POSITION
            MOVE.W  D1,D5
            LSL.L   #8,D5
            LSL.L   #8,D5
            MOVE.W  D2,D5
            CLR.L   D0
            MOVE.B  ENEMTYPE(A1),D0         ; GET TYPE OF ENEMY
            MULU.W  #ENEMSZB,D0             ; GET OFFSET OF ENEMY TYPE
            MOVE.L  ENTYPCLR(A2,D0.W),A1    ; GET ANIMATION POINTER OF ENTITY
            JSR GETIMGOFANIM            
            JSR DRAWIMG
.ENNEXT
            MOVE.L  (A0),A1
            CMP     #$FFFFFFFF,A1           ; CHECK IF THE POINTER IS AN END POINT
            BEQ     .ENSTOP                 ; THERE IS STILL AN ENEMY
            DBRA    D4,.ENLOOP              ; CHECK NEXT ENEMY IN CASE IT'S NOT THE LIST LIMIT
.ENSTOP            
                         
            ; SET PEN COLOR
            MOVE.L  #$00FFFFFF,D1           
            MOVE.W  #80,D0
            TRAP    #15
            ; SET FILL COLOR
            MOVE.L  #$00FF9494,D1           
            MOVE.W  #81,D0
            TRAP    #15
            
            
            ; DRAW UI
            ; DRAW STRING OF COINS     
            LEA.L   STRCOIN,A1     
            MOVE.W  #0,D1
            MOVE.W  #0,D2
            MOVE.W  #95,D0
            TRAP    #15
            ; DRAW NUMBER OF COINS
            MOVE.W  #6,D1
            LSL.W   #8,D1
            MOVE.B  #0,D1
            MOVE.W  #11,D0
            TRAP    #15
            CLR.L   D1
            MOVE.W  PLCOIN,D1
            MOVE.W  #3,D0
            TRAP    #15           
 
            BRA     RTN






*~Font name~Courier New~
*~Font size~9~
*~Tab type~0~
*~Tab size~4~
