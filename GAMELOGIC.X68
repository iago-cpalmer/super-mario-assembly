; --- UPDATES THE CURRENT STATE OF GAME
;     Input:
;           - None
;     Output:
;           - None
;     Modifies:
;           - Game variables
; ---------------------------------------------------------------------------
STAUPD
            MOVEM.L D0-D7,-(A7)
            MOVEM.L  A0-A1,-(A7)
            CLR.L   D0
            CLR.L   D1
            CLR.L   D2
            CLR.L   D3
            CLR.L   D4
            CLR.L   D5
            CLR.L   D6
            CLR.L   D7
            ; update state of game
            ; check the state of game
            ; 0 -> in main menu
            ; 1 -> loading level
            ; 2 -> in level
            ; 3 -> Death screen
            MOVE.W  GAMESTA,D0
            CMP.W   #0,D0
            BEQ     .STA0
            CMP.W   #1,D0
            BEQ     .STA1
            CMP.W   #2,D0
            BEQ     .STA2
            CMP.W   #3,D0
            BEQ     .STA3
            BRA     .RTN
            
.STA0
            ; It's in main menu
            ; Check if the mouse is in a button
            ; and if it's pressed 
            BRA     .RTN
.STA1     
            ; It's loading the level
            JSR     LOADLVL
                   
            BRA     .RTN            
.STA2
            ; It's in level, update the state
            JSR     PRUPD                   ; Update player position depending on the input and collisions with map
            JSR     CAMUPD                  ; UPDATE CAMERA POSITION DEPENDING ON NEW PLAYER'S POSITION           
            ; update enemy positions
            JSR     ENEMUPD
            ; check collisions of player with enemies
            JSR     CCOLENE
            BRA     .RTN 
.STA3
            BRA     .RTN            
.RTN            
            MOVEM.L  (A7)+,A0-A1
            MOVEM.L (A7)+,D0-D7
            RTS
            
; --- UPDATES ENEMIES STATES
;     Input:
;           - None
;     Output:
;           - None
;     Modifies:
;           - STATE OF ENEMIES
; ---------------------------------------------------------------------------
ENEMUPD
            MOVEM.L D0-D7,-(A7)
            MOVEM.L A0-A3,-(A7)
            
            LEA.L   ENEMLIS,A0
            LEA.L   GOOMBA,A2
            MOVE.W  #ENEMCOUN,D4
            BRA     .ENNEXT
.ENLOOP
            MOVE.L  (A0)+,A1                ; GET POINTER OF ENEMY IN DYNAMIC MEMORY
            MOVE.B  ENEMENBL(A1),D0         ; GET ENABLED/DISABLED PROPERTY VALUE
            CMP.B   #ENSTDSB,D0                   ; CHECK IF IT'S DISABLED            
            BEQ     .DISABL                 ; IT'S DISABLED, GO TO THE NEXT ENEMY
            CMP.B   #ENSTDTH,D0
            BEQ     .ENNEXT                 ; ENEMY IS DEAD, GO TO NEXT
            CLR.L   D0                   
            MOVE.B  ENEMTYPE(A1),D0         ; GET TYPE OF ENEMY
            MULU.W  #ENEMSZB,D0             ; GET OFFSET OF ENEMY TYPE
            MOVE.L  ENTYPSBH(A2,D0.W),A3    ; GET ADDRESS OF THE STATE UPDATE SUBROUTINE
            JSR     (A3)                    ; CALL THE STATE UPDATE SUBROUTINE  
            BRA     .ENNEXT
.DISABL
            ; CHECK DISTANCE TO PLAYER TO ENABLE THE ENEMY
            MOVE.W  ENEMXPOS(A1),D1
            SUB.W   PLPOSX,D1
            CMP.W   #ENBDIST*TILEPXS,D1
            BGT     .ENNEXT
            MOVE.B  #ENSTENB,ENEMENBL(A1)         ; ENABLE ENEMY
.ENNEXT
            MOVE.L  (A0),A1
            CMP     #$FFFFFFFF,A1           ; CHECK IF THE POINTER IS AN END POINT
            BEQ     .ENSTOP                 ; THERE IS STILL AN ENEMY
            DBRA    D4,.ENLOOP              ; CHECK NEXT ENEMY IN CASE IT'S NOT THE LIST LIMIT
.ENSTOP            
            MOVEM.L (A7)+,D0-D7
            MOVEM.L (A7)+,A0-A3
            RTS
            
; --- UPDATES CAMERA POSITION
;     Input:
;           - None
;     Output:
;           - None
;     Modifies:
;           - CAMERA POSITION (CAMX)
; ---------------------------------------------------------------------------
CAMUPD
            MOVEM.L  D0-D2,-(A7)
            MOVE.W  PLPOSX,D0               ; MOVE CURRENT PLAYER POSITION IN D0
            MOVE.W  #TILEPXS,D1             ; COMPUTE OFFSET FROM PLAYER TO CAMERA FOR THE PLAYER TO BE CENTERED ON SCREEN
            MOVE.W  #NTILESC,D2
            DIVS.W  #2,D2
            MULS.W  D2,D1  
                 
            SUB.W   D1,D0                   ; GET FINAL CAMERA POSITION DEPENDING ON PLAYER POSITION
            CMP.W   CAMX,D0                 ; CHECK IF PREVIOUS CAMERA POSITION IS GREATER
            BLE     .SKIP                   ; IN THAT CASE, SKIP. CAMERA SHOULD ONLY MOVE FORWARD (TO THE RIGHT)
            ADD.W   PLPOSX,D1               ; GET CAMERA POSITION OF THE RIGHT SIDE, TO CHECK IF IT'S INSIDE MAP BOUNDARIES        
            CMP.W   MAPPXSZ,D1              ; CHECK IF THE CURRENT CAMERA POSITION IS IN MAP BOUNDARIES
            BGT     .SKIP                   ; IF NOT, DO NOT SAVE IT AS NEW CAMERA POSITION, KEEP PREVIOUS
            MOVE.W  D0,CAMX                 ; SET NEW CAMERA POSITION
.SKIP
            MOVEM.L (A7)+,D0-D2
            RTS
            
; --- LOADS LEVEL
;     Input:
;           - None
;     Output:
;           - None
;     Modifies:
;           - STATE OF BUTTON
; ---------------------------------------------------------------------------
LOADLVL
            MOVEM.L D0-D4,-(A7)
            MOVEM.L A0-A5,-(A7)

            MOVE.W  #$FFFF,ENEMLIS
            LEA.L   LVLCDAT,A1              ; GET ADDRESS OF LOADED LEVEL TO COPY THE CURRENT LEVEL
            LEA.L   LVLCDAT,A4
            
            MOVE.W  CLVLLOA,D0
            MULU.W  #4,D0                   ; GET OFFSET OF POINTER IN LVL'S ADDRESS
            LEA.L   LVLADDR,A0
            MOVE.L  0(A0,D0.W),A0           ; GET ADDRESS OF LOADED LEVEL DATA IN A0
            LEA.L   TILE1,A2                ; GET ADDRESS OF TILE INFO ARRAY
            
            ; FIRST TWO WORDS ARE THE HEIGHT & WIDTH OF LEVEL TILE MAP
            MOVE.W  (A0)+,MTLHGHT           ; STORE HEIGHT IN TILES
            MOVE.W  (A0)+,MTLWDTH           ; STORE WIDTH IN TILES
            MOVE.W  MTLWDTH,D1              
            MULU.W  #TILEPXS,D1             
            MOVE.W  D1,MAPPXSZ              ; STORE WIDTH IN PIXELS
            
             ; iterate through tiles to paint
            MOVE.W  #0,D3                   ; FIRST LOOP
            MOVE.W  #0,D4                   ; SECOND LOOP
            
.LVLOOP            
            MOVE.W  (A0)+,D1                ; SAVE TILE TYPE IN D1
            MOVE.W  D1,(A1)+                ; MAKE A COPY OF THE TILE IN LOADED LEVEL                     
            ; CHECK IF IT'S A TILE ENTITY WITH LOAD BEHAVIOR
            SUBQ.W  #1,D1
            MULU.W  #TILESZB,D1
            MOVE.W  ISTLENT(A2,D1.W),D2
            CMP.W   #TEONLOA,D2                     
            BNE     .LVNEXT                 ; IT'S NOT A TILE ENTITY WITH ON LOAD BEHAVIOR
            MOVE.L  BEHAVSR(A2,D1.W),A3
            
            ; COMPUTE TILE COORDS
            MOVE.L  A1,A5
            SUB.L   #2,A5
            SUB.L   A4,A5
            MOVE.L  A5,D1
            LSR.L   #1,D1
            MOVE.L  D1,D2
            DIVU.W  MTLWDTH,D1
            DIVU.W  MTLWDTH,D2
            LSR.L   #8,D1
            LSR.L   #8,D1
            JSR     (A3)                    ; CALL BEHAVIOUR SUBROUTINE
            CLR.L   D1
            CLR.L   D2
.LVNEXT
            CMP.W   #$FFFF,(A0)             ; CHECK IF END POINT IT HAS BEEN REACHED
            BNE     .LVLOOP
     
            MOVE.W  #2,GAMESTA              ; CHANGE GAME STATE TO 2
            MOVEM.L (A7)+,A0-A5 
            MOVEM.L (A7)+,D0-D4
            RTS
            
; --- UPDATES PLAYER STATE
;     Input:
;           - None
;     Output:
;           - None
;     Modifies:
;           - PLAYER VARIABLES
; ---------------------------------------------------------------------------
PRUPD
            MOVEM.L D0-D7,-(A7)
            MOVEM.L A0-A2,-(A7)
            ; UPDATE INVINCIBILITY STATE
            MOVE.W  PLINVCB,D0
            CMP.W   #0,D0
            BLE     .CONT1
            SUB.W   DELTATIME,D0
            MOVE.W  D0,PLINVCB
            MOVE.W  #0,PLFCEY
.CONT1       
            ; CHECK IF PLAYER IS DEAD
            MOVE.W  PLHEALTH,D0   
            CMP.W   #0,D0
            BGT     .CONT2
            MOVE.W  #3,GAMESTA
            MOVE.W  #0,-(A7)
            BRA     .RTN
.CONT2
            
            ; Get current input
            CLR.W   D3                      ; X-axis direction
            CLR.W   D4                      ; Y-axis direction
            CLR.L   D2
            CLR.L   D0
            MOVE.B  KBDVAL,D2
            BTST    #KUPBMAP,D2
            BEQ     .KDOWN
            ; Up key pressed
            ; Check if player is grounded so he is able to jump or not
            CMP.W   #0,PLGNDD
            BEQ     .KDOWN
            MOVE.W   #-JMPFRCE,PLFCEY      
.KDOWN     
            BTST  #KDWBMAP, D2
            BEQ     .KLEFT
            ; ADDQ.W  #1,D4
            ; Down key pressed
.KLEFT
            BTST  #KLTBMAP, D2
            BEQ     .KRGHT
            ; Left key pressed
            SUBQ.W  #1,D3
.KRGHT        
            BTST  #KRTBMAP, D2
            BEQ     .CONT
            ; Right key pressed
            ADDQ.W  #1,D3
.CONT      
            ; Apply gravity
            ADD.W   #GRAVITY,PLFCEY
.SKIPG            
            ; Apply end y-force
            MOVE.W  PLFCEY,D4
            CMP.W   #0,D4
            BEQ     .FORCE0
            CMP.W   #0,D4
            BLT     .FORCEN
            CMP.W   #0,D4
            BGT     .FORCEP
.FORCE0
            MOVE.W  #0,D4
            BRA     .SKIPFC
.FORCEP
            MOVE.W  #1,D4
            BRA     .SKIPFC
.FORCEN                  
            MOVE.W  #-1,D4
.SKIPFC      
            ; Change state after processing the input
            ; Check collisions with map in the x-axis
            ; We must check 3 collisions. Left & right corner, and center  
            MOVE.W  D3,PLMODI               ; STORE CURRENT PLAYER DIRECTION   
            MOVE.W  D3,D1     
            MOVE.W  #TILEPXS-1,D0
            
            ; Center
            MOVE.W  #0,D2
            MOVE.W  PLPOSX,D3
            MOVE.W  PLPOSY,D4
            CMP.W   #MAXYDIE*TILEPXS,D4
            BLE     .CONT5
            MOVE.W  #3,GAMESTA
            MOVE.W  #0,-(A7)
            BRA     .RTN
.CONT5            
            JSR     PLCKCOL
            CMP.W   #0,D5
            BNE     .SKPMOVX
            
            ; Up corner
            MOVE.W  #-1,D2
            MOVE.W  PLPOSX,D3
            MOVE.W  PLPOSY,D4
            JSR     PLCKCOL
            CMP.W   #0,D5
            BNE     .SKPMOVX
            
            ; Down corner
            MOVE.W  #1,D2
            MOVE.W  PLPOSX,D3
            MOVE.W  PLPOSY,D4
            JSR     PLCKCOL
            CMP.W   #0,D5
            BNE     .SKPMOVX 
            BLT     .SKPMOVX
            ; Update player position in x-axis
            MULS.W  #PLSPEED, D1            ; Multiply speed to current movement direction  
            ADD.W   D1,PLPOSX 
            MOVE.W  #0,-(A7)
            BRA     .CHKY    
.SKPMOVX    
            MULS.W  D1,D6 
            MOVE.W  D6,-(A7)
            SUB.W   D6,PLPOSX
.CHKY        
            ; Check if player has a collision on top
            ; We have to check the corners and center as well
            CMP.W   #0,PLFCEY
            BGT     .CHKGDD            
            MOVE.W  #-1,D2
            MOVE.W  #TILEPXS+5,D0
            
            ; Center
            MOVE.W  #0,D1
            MOVE.W  PLPOSX,D3
            MOVE.W  PLPOSY,D4
            JSR     PLCKCOL
            CMP.W   #0,D5
            BNE     .COLTOP
            
            ; Left corner
            MOVE.W  #-1,D1
            MOVE.W  PLPOSX,D3
            MOVE.W  PLPOSY,D4
            JSR     PLCKCOL
            CMP.W   #0,D5
            BNE     .COLTOP
            
            ; Right corner
            MOVE.W  #1,D1
            MOVE.W  PLPOSX,D3
            MOVE.W  PLPOSY,D4
            JSR     PLCKCOL
            CMP.W   #0,D5
            BNE     .COLTOP
            
            MOVE.W  #0,PLGNDD
            MOVE.W  PLFCEY,D6          
            ADD.W   D6,PLPOSY
            BRA     .RTN
            
.COLTOP     ; Player is colliding with a tile with the top of its head
            MOVE.W  (A7)+,D6
            MOVE.W  #0,-(A7) 
            ADD.W   D6,PLPOSX 
            MOVE.W  #0,PLFCEY               ; reset force
            ADD.W   D7,PLPOSY
            ; Check if it's a tile entity
            SUBQ.W  #1,D5
            LEA.L   TILE1,A0
            MULU.W  #TILESZB,D5              ; Get tile offset
            MOVE.W  ISTLENT(A0,D5.W),D0
            CMP.W   #TEONCOL,D0
            BNE     .CHKGDD
            
            ; Get the tile coord
            MOVE.W  D3,D1
            MOVE.W  D4,D2
            ; It's a Tile Entity
            MOVE.L  BEHAVSR(A0,D5.W),A2
            JSR     (A2)
               
            BRA     .RTN
.CHKGDD            
            ; Check if the player is grounded
            MOVE.W  #TILEPXS,D0
            MOVE.W  #1,D2
            
            ; center
            MOVE.W  #0,D1
            MOVE.W  PLPOSX,D3
            MOVE.W  PLPOSY,D4
            JSR     PLCKCOL
            CMP.W   #0,D5
            BGT     .GROUNDED
            
            ; left corner
            MOVE.W  #-1,D1
            MOVE.W  PLPOSX,D3
            MOVE.W  PLPOSY,D4
            JSR     PLCKCOL
            CMP.W   #0,D5
            BGT     .GROUNDED
            
            ; right corner
            MOVE.W  #1,D1
            MOVE.W  PLPOSX,D3
            MOVE.W  PLPOSY,D4
            JSR     PLCKCOL
            CMP.W   #0,D5
            BGT     .GROUNDED
            
            ; Player is not grounded 
            MOVE.W  #0,PLGNDD
            MOVE.W  PLFCEY,D6          
            ADD.W   D6,PLPOSY
            BRA     .RTN
.GROUNDED   
            MOVE.W  (A7)+,D6
            ADD.W   D6,PLPOSX
            MOVE.W  #0,-(A7)        
            SUB.W   D7,PLPOSY
            MOVE.W  #1,PLGNDD
            MOVE.W  #0,PLFCEY               ; reset force
.RTN
            MOVE.W  (A7)+,D6
            MOVEM.L (A7)+,A0-A2
            MOVEM.L (A7)+,D0-D7
            RTS 


; ----------------------
; Check if it there is a tile applying the direction given by D1.W & D2.W from
; position D3.W & D4.W
; - Input: 
;           - D0.W: size of object
;           - D1.W: x-axis direction
;           - D2.W: y-axis direction 
;           - D3.W: x-axis position 
;           - D4.W: y-axis position                    
; - Output: 
;           - D5.W -> returns id of tile in that position: 0 is not colliding.
;           - D6.W -> returns x-axis position that the object should move to leave the collider
;           - D7.W -> returns y-axis position that the object should move to leave the collider
;-----------------------
PLCKCOL
            MOVEM.L D0-D2,-(A7)
            MOVE.L  A1,-(A7)
            MOVE.W  D2,D5
            LSL.L   #8,D5
            LSL.L   #8,D5    
            MOVE.W  D1,D5
            LSR.W   #1,D0
            MULS.W  D0,D1
            MULS.W  D0,D2
            ADD.W   D3,D1
            ADD.W   D4,D2
            AND.L   #$0000FFFF,D1
            AND.L   #$0000FFFF,D2
            ; Transform global position to tilemap position
            DIVU.W  #TILEPXS,D1
            DIVU.W  #TILEPXS,D2
            
            ; Save tile coords in case we need them after checking collision
            MOVE.W  D1,D3
            MOVE.W  D2,D4
             
            MOVE.L  D1,D6
            MOVE.L  D2,D7
            LSR.L   #8,D6
            LSR.L   #8,D6
            LSR.L   #8,D7
            LSR.L   #8,D7
            
            CMP.W   #0,D5
            BGT     .SKPCLMPX
            SUB.W   #TILEPXS,D6
            MULS.W  #-1,D6
.SKPCLMPX
            LSR.L   #8,D5
            LSR.L   #8,D5
            CMP.W   #0,D5
            BGT     .SKPCLMPY
            SUB.W   #TILEPXS,D7
            MULS.W  #-1,D7
.SKPCLMPY  
            CMP.W   #0,D1
            BLT     .OUTMAPX
            CMP.W   MTLWDTH,D1
            BGT     .OUTMAPX
            
             
            CMP.W   #0,D2
            BLT     .OUTMAPY
            CMP.W   MTLHGHT,D2
            BGT     .OUTMAPY
            
            ; CHECK IF THERE IS A NON-AIR BLOCK IN TILEMAP
            MULS.W  MTLWDTH,D2
            ADD.W   D1,D2                   ; Get index in tilemap
            MULS.W  #2,D2
            LEA.L   LVLCDAT,A1
            MOVE.W  0(A1,D2.W),D5           ; Tile in map
            BRA .RTN
.OUTMAPX
            MOVE.W  #-1,D5
            SUB.W   #TILEPXS,D6
            MULS.W  #-1,D6

            BRA .RTN
.OUTMAPY
            MOVE.W  #0,D7
            MOVE.W  #0,D5
            
.RTN
            MOVE.L  (A7)+,A1
            MOVEM.L (A7)+,D0-D2
            RTS
            

; --- CHECKS COLLISIONS OF PLAYER WITH ENEMIES
;     Input:
;           - None
;     Output:
;           - None
;     Modifies:
;           - STATE OF BUTTON
; ---------------------------------------------------------------------------
CCOLENE
            MOVEM.L D0-D7,-(A7)
            MOVEM.L A0-A4,-(A7)
            CLR.W   D0
            CLR.W   D1
            CLR.W   D2
            CLR.W   D3
            CLR.W   D4
            CLR.W   D5
            CLR.W   D6
            CLR.W   D7
            ; COMPUTE BOUNDING BOX OF PLAYER                  
            MOVE.W  PLPOSX,D3               ; GET X POSITION OF ENEMY
            SUB.W   #(TILEPXS/2-10),D3        ; GET LEFT-TOP CORNER X POSITION
            MOVE.W  D3,D5
            ADD.W   #(TILEPXS-20),D5          ; GET RIGHT-BOTTON CORNER X POSITION
            
            MOVE.W PLPOSY,D4                ; GET Y POSITION OF PLAYER
            SUB.W   #(TILEPXS/2),D4           ; GET LEFT-TOP CORNER Y POSITION
            MOVE.W  D4,D6
            ADD.W   #TILEPXS,D6             ; GET RIGHT-BOTTON CORNER Y POSITION
            
            ; ITERATE THROUGH ENEMY LIST
            LEA.L   ENEMLIS,A0
            LEA.L   GOOMBA,A2
            BRA     .ENNEXT
.ENLOOP
            MOVE.L  (A0)+,A1                ; GET POINTER OF ENEMY IN DYNAMIC MEMORY
            MOVE.B  ENEMENBL(A1),D0         ; GET ENABLED/DISABLED PROPERTY VALUE
            CMP.B   #ENSTDSB,D0             ; CHECK IF IT'S DISABLED            
            BLE     .ENNEXT                 ; IT'S DISABLED, GO TO THE NEXT ENEMY
            CLR.W   D7
            MOVE.B  ENEMTYPE(A1),D7         ; GET TYPE OF ENEMY
            MULU.W  #ENEMSZB,D7              ; GET OFFSET OF ENEMY TYPE IN MEMORY
            MOVE.W  ENEMXPOS(A1),D1         ; GET X POSITION OF ENEMY
            MOVE.W  ENEMYPOS(A1),D2         ; GET Y POSITION OF ENEMY
            
            ; CHECK HEAD COLLISION
            ; CHECK CENTER
            SUB.W   #(TILEPXS/2+20),D2       ; ADD OFFSET TO GET THE HEAD POINT OF ENEMY
            JSR     CHKINBBO                ; CHECK IF IT'S INSIDE OF BOUNDING BOX
            CMP.B   #0,D0                   ; CHECK RETURN VALUE
            BNE     .COLHEA 
            ; CHECK LEFT
            SUB.W   #TILEPXS/2-20,D1         ; CHECK LEFT
            JSR     CHKINBBO                ; CHECK IF IT'S INSIDE OF BOUNDING BOX
            CMP.B   #0,D0                   ; CHECK RETURN VALUE
            BNE     .COLHEA 
            ; CHECK RIGHT
            ADD.W   #TILEPXS-10,D1             ; CHECK RIGHT
            JSR     CHKINBBO                ; CHECK IF IT'S INSIDE OF BOUNDING BOX
            CMP.B   #0,D0                   ; CHECK RETURN VALUE
            BNE     .COLHEA 
            BRA     .LEHCOL
.COLHEA            
            ; IT'S COLLIDING ON HEAD
            MOVE.L  ENTYPHBH(A2,D7.W),A3    ; GET POINTER TO SUBROUTINE OF BEHAVIOR WHEN COLLIDING ON HEAD
            JSR     (A3)                    ; CALL THAT SUBROUTINE
            BRA     .ENSTOP                 ; LEAVE
.LEHCOL        
            MOVE.W  PLINVCB,D0              ; CHECK IF IT'S INVINCIBLE OR NOT
            CMP.W   #0,D0                   
            BGT     .INV
            ;BGT     .ENNEXT                 ; IT'S INVINCIBLE, CHECK NEXT ENEMY    
            ; CHECK VERTICAL LEFT COLLISION
            CLR.W   D2
            MOVE.W  ENEMYPOS(A1),D2         ; GET Y POSITION OF ENEMY
            MOVE.W  ENEMXPOS(A1),D1         ; GET X POSITION OF ENEMY
            
            ; IT'S NOT COLLIDING VERTICALLY ON RIGHT, CHECK BOTTOM
            ADD.W   #TILEPXS/2+1,D2         ; GET BOTTOM Y COORD OF ENEMY
            JSR     CHKINBBO                ; CHECK IF IT'S INSIDE BOUNDING BOX
            CMP.B   #0,D0                   ; CHECK RETURN VALUE
            BNE     .DMGPLAY                ; DAMAGE PLAYER
            
            MOVE.W  ENEMYPOS(A1),D2         ; GET Y POSITION OF ENEMY
            SUB.W   #TILEPXS/2-5,D1         ; GET LEFT X COORD
            JSR     CHKINBBO                ; CHECK IF IT'S INSIDE BOUNDING BOX
            CMP.B   #0,D0                   ; CHECK RETURN VALUE
            BNE     .DMGPLAY                ; DAMAGE PLAYER
            
            ; IT'S NOT COLLIDING VERTICALLY ON LEFT, CHECK RIGHT
            ADD.W   #TILEPXS-10,D1          ; GET RIGHT X COORD
            JSR     CHKINBBO                ; CHECK IF IT'S INSIDE BOUNDING BOX
            CMP.B   #0,D0                   ; CHECK RETURN VALUE
            BNE     .DMGPLAY                ; DAMAGE PLAYER
            
            ; IT'S NOT COLLIDING IN ANY WAY, CHECK NEXT ENEMY
            BRA     .ENNEXT
.DMGPLAY    
            ; IT'S COLLIDING IN OTHER PART THAN HEAD
            MOVE.L  ENTYPCOL(A2,D7.W),A3    ; GET POINTER TO SUBROUTINE OF BEHAVIOR WHEN COLLIDING
            JSR     (A3)                    ; CALL THAT SUBROUTINE
            BRA     .ENSTOP                 ; PLAYER HAS BEEN DAMAGED, STOP CHECKING FOR COLLISIONS            
.INV
            MOVE.W  #3,A4
.ENNEXT
            MOVE.L  (A0),A1
            CMP     #$FFFFFFFF,A1           ; CHECK IF THE POINTER IS AN END POINT
            BEQ     .ENSTOP                 ; THERE IS STILL AN ENEMY
            BRA     .ENLOOP
.ENSTOP            
            MOVEM.L (A7)+,D0-D7
            MOVEM.L (A7)+,A0-A4
            RTS
      







*~Font name~Courier New~
*~Font size~9~
*~Tab type~0~
*~Tab size~4~
