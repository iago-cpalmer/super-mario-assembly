; Enemy
; Memory layout (in dynamic memory):
;           - 1B - Enemy type  
;           - 1B - Enabled or disabled -> -1 dead, 0 disabled, 1 enabled
;           - 1W - Current direction of movement
;           - 1W - X position
;           - 1W - Y position
;           - 1W - YForce
; Constants of enemies
;           L->Pointer to update state subroutine
;           W->XSpeed
;           L->Fill Color
ENEMSIZE    EQU    4                        ; SIZE OF POINTER TO ENEMIES IN BYTES
ENEMCOUN    EQU    100                      ; MAX QUANTITY OF ENEMIES PER LEVEL
ENEMSZB     EQU    18                       ; SIZE OF ENEMY TYPE INFO. IN BYTES

ENSTDTH     EQU     -1                      ; CONSTANT FOR ENEMY STATE OF DEATH
ENSTENB     EQU     1                       ; CONSTANT FOR ENEMY STATE OF ENABLED
ENSTDSB     EQU     0                       ; CONSTANT FOR ENEMY STATE OF DISABLED
; OFFSETS OF ATTRIBUTES OF AN ENEMY IN MEMORY
ENEMTYPE    EQU     0                       ; OFFSET OF ENEMY TYPE IN ENEMY
ENEMENBL    EQU     1                       ; OFFSET OF ENABLE/DISABLED PROPERTY OF ENEMY 
ENEMMDIR    EQU     2                       ; OFFSET OF CURRENT DIRECTION OF MOVEMENT
ENEMXPOS    EQU     4                       ; OFFSET OF X POSITION
ENEMYPOS    EQU     6                       ; OFFSET OF Y POSITION
ENEMYFCE    EQU     8                       ; OFFSET OF CURRENT Y FORCE

ENTYPXSP    EQU     0                       ; OFFSET OF X SPEED IN ENEMY TYPE INFO
ENTYPCLR    EQU     2                       ; OFFSET OF FILL COLOR IN ENEMY TYPE INFO
ENTYPSBH    EQU     6                       ; OFFSET OF SUBROUTINE BEHAV IN ENEMY TYPE INFO
ENTYPHBH    EQU     10                      ; OFFSET OF SUBROUTINE TO CALL WHEN HEAD COLLSIION
ENTYPCOL    EQU     14                      ; OFFSET OF SUBROUTINE TO CALL WHEN COLLIDING WITH PLAYER
   
; ENEMY TYPES
GOOMBA
            DC.W    4*SPEEDMULTIPLIER       ; XSPEED
            DC.L    ANIMGOOMBA              ; POINTER TO ANIMATION
            DC.L    GMBASTU                 ; SUBROUTINE OF BEHAVIOUR
            DC.L    ENEHCOL                 ; SUBROUTINE OF HEAD COLISION WITH PLAYER
            DC.L    ENEPCOL                 ; SUBROUTINE OF OTHER TYPE OF COLLISION WITH PLAYER

MUSHROOM    DC.W    2*SPEEDMULTIPLIER       ; XSPEED
            DC.L    ANIMMUSHROOM            ; POINTER TO ANIMATION
            DC.L    GMBASTU                 ; SUBROUTINE OF BEHAVIOUR
            DC.L    MROMCOL                 ; SUBROUTINE OF HEAD COLISION WITH PLAYER
            DC.L    MROMCOL                 ; SUBROUTINE OF OTHER TYPE OF COLLISION WITH PLAYER

COIN        DC.W    0                       ; XSPEED
            DC.L    ANIMCOIN                ; POINTER TO ANIMATION
            DC.L    NOBEHAV                 ; SUBROUTINE OF BEHAVIOUR
            DC.L    COINCOL                 ; SUBROUTINE OF HEAD COLISION WITH PLAYER
            DC.L    COINCOL                 ; SUBROUTINE OF OTHER TYPE OF COLLISION WITH PLAYE

FLAG        DC.W    0                       ; XSPEED
            DC.L    ANIMFLAG                ; POINTER TO ANIMATION
            DC.L    NOBEHAV                 ; SUBROUTINE OF BEHAVIOUR
            DC.L    FLAGCOL                 ; SUBROUTINE OF HEAD COLISION WITH PLAYER
            DC.L    FLAGCOL                 ; SUBROUTINE OF OTHER TYPE OF COLLISION WITH PLAYE    
FLAGTOP 
            DC.W    0                       ; XSPEED
            DC.L    ANIMFLAGTOP             ; POINTER TO ANIMATION
            DC.L    NOBEHAV                 ; SUBROUTINE OF BEHAVIOUR
            DC.L    FLAGCOL                 ; SUBROUTINE OF HEAD COLISION WITH PLAYER
            DC.L    FLAGCOL                 ; SUBROUTINE OF OTHER TYPE OF COLLISION WITH PLAYE    
                      
    
; List of enemies; Pointer to dynamic memory
ENEMLIS     DS.L    ENEMSIZE*(ENEMCOUN+1)
            DC.L    $FFFF

; Subroutine of behavior for enemies when the player collides with their heads
; INPUT: 
;           A1.L    - POINTER TO ENEMY
ENEHCOL     
            MOVE.B  #ENSTDTH,ENEMENBL(A1)   ; KILL ITSELF
            MOVE.W   #-JMPFRCE/2,PLFCEY     ; GIVE JUMP FORCE TO PLAYER
            RTS
            
; SUBROUTINE OF BEHAVIOUR FOR ENEMIES WHEN THE PLAYER COLLIDES WITH OTHER PART THAN HEAD
ENEPCOL   
            SUBQ.W  #1,PLHEALTH             ; DAMAGE PLAYER
            MOVE.W  #INVCTIM,PLINVCB        ; SET PLAYER'S INVINCIBILITY TIMER
            MOVE.W  #0,PLAPWUP              ; REMOVE POWER-UP TO PLAYER
            RTS

; SUBROUTINE OF BEHAVIOR FOR MUSHROOM POWER-UP WHEN PLAYER COLLIDES
MROMCOL
            MOVE.W  #2,PLHEALTH             ; SET PLAYER HEALTH TO 2
            MOVE.W  #MRMPWID,PLAPWUP        ; SET POWER-UP TO MUSHROOM
            MOVE.B  #ENSTDTH,ENEMENBL(A1)   ; KILL ITSELF
            RTS

; SUBROUTINE OF BEHAVIOR FOR NON-BEHAVIORAL ENTITIES
NOBEHAV
            RTS  

; SUBROUTINE OF BEHAVIOR FOR COINS WHEN PICKING UP
COINCOL
            ADDQ.W  #1,PLCOIN               ; ADD COIN TO PLAYER
            MOVE.B  #ENSTDTH,ENEMENBL(A1)   ; KILL ITSELF
            RTS          

; SUBROUTINE OF BEHAVIOR FOR FLAG
FLAGCOL
            MOVE.W  #4,GAMESTA              ; WIN STATE SCREEN
            RTS            
; ----------------------------------------------------------------
; Subroutines of behavior
; ----------------------------------------------------------------

; Subroutine to update the state of a goomba
; Input:
;           - A1.L  - ADDRESS OF ENEMY IN DYNAMIC MEMORY
GMBASTU        
            MOVEM.L D0-D7,-(A7)
            MOVE.L  A2,-(A7) 
            ; MOVE applying current direction
            ; check collisions with map horizontally
            ; if colliding, change direction
            ; check collisions in vertical axis: down, if not grounded, apply gravity
            ; if current Y position is bigger than a threshold, kill enemy
            LEA.L   GOOMBA,A2        
.MOVHOR     ; HORIZONTAL MOVEMENT
            MOVE.W  #1,D2                   ; CHECK IF IT'S GROUNDED
            MOVE.W  #TILEPXS,D0             ; GET BOUNDING BOX OF ENEMY IN PX
            MOVE.W  ENEMXPOS(A1),D3
            MOVE.W  ENEMYPOS(A1),D4
            
            ; CHECK IF THE Y THRESHOLD HAS BEEN SURPASSED, ENEMY MUST BE DISABLED
            CMP.W   #MAXYDIE*TILEPXS,D4
            BGT     .DIE
            
            ;CHECK AT RIGHT
            MOVE.W  #1,D1
            JSR     ENCKCOL
            CMP.W   #0,D5
            BGT     .GRONDD
            ; CHECK AT CENTER
            MOVE.W  #0,D1
            JSR     ENCKCOL
            CMP.W   #0,D5
            BGT     .GRONDD
            ; CHECK AT LEFT 
            MOVE.W  #-1,D1
            JSR     ENCKCOL
            CMP.W   #0,D5
            BGT     .GRONDD
    
            ; IT'S NOT GROUNDED, APPLY GRAVITY
            JSR APPGRAV
            ; SET NEW Y-POSITION AFTER APPLYING GRAVITY
            MOVE.W  ENEMYPOS(A1),D4
            ADD.W   ENEMYFCE(A1),D4
            MOVE.W  D4,ENEMYPOS(A1)
            BRA     .RTN                    ; DON'T APPLY VERTICAL SPEED IF FALLING
.GRONDD    
            MOVE.W  ENEMYPOS(A1),D6         ; GET CURRENT Y-POSITION
            SUB.W   D7,D6                   ; APPLY OFFSET TO LEAVE COLLISION
            MOVE.W  D6,ENEMYPOS(A1)         ; SET NEW Y-POSITION
            MOVE.W  #0,ENEMYFCE(A1)         ; SET Y-FORCE TO 0
.MOVERT
            MOVE.W  #TILEPXS,D0             ; GET SIZE OF BOUNDING BOX OF ENEMY IN PX
            MOVE.W  ENEMMDIR(A1),D1         ; GET CURRENT MOVEMENT DIRECTION IN THE X-AXIS
            MOVE.W  #0,D2                   ; SET DIRECTION IN THE Y-AXIS AS 0, TO CHECK VERTICAL COLLISIONS
            MOVE.W  ENEMXPOS(A1),D3         ; GET CURRENT X POSITION
            MOVE.W  ENEMYPOS(A1),D4         ; GET CURRENT Y POSITION

            
            JSR     ENCKCOL                  ; CHECK IF IT'S COLLIDING
            CMP.W   #0,D5
            BNE     .COLVERT                 ; IT'S COLLIDING VERTICALLY
            ; IT'S NOT COLLIDING, MOVE VERTICALLY
            MOVE.B  ENEMTYPE(A1),D5         ; GET ENEMY TYPE
            MULU.W  #ENEMSZB,D5             ; GET ENEMY TYPE OFFSET
            MULS.W  ENTYPXSP(A2,D5.W),D1    ; APPLY VERTICAL SPEED TO CURRENT DIR
            MOVE.W  ENEMXPOS(A1),D3         ; GET CURRENT X POSITION
            ADD.W   D1,D3   
            MOVE.W  D3,ENEMXPOS(A1)         ; SET NEW X POSITION OF ENEMY
            BRA     .RTN                    ; LEAVE
.COLVERT
            MOVE.W  ENEMMDIR(A1),D7
            MULS.W  #-1,D7                  ; INVERT CURRENT MOVEMENT OF DIRECTION IN X-AXIS
            MOVE.W  D7,ENEMMDIR(A1)  
            BRA     .RTN
.DIE                    
            MOVE.B  #0,ENEMENBL(A1)
.RTN
            MOVE.L  (A7)+,A2
            MOVEM.L (A7)+,D0-D7
            RTS 

; APPLY GRAVITY TO ENTITY
; A1.L      - ADDRESS OF ENTITY IN MEMORY
APPGRAV
            MOVE.L  D1,-(A7)
            MOVE.W  ENEMYFCE(A1),D1         ; GET CURRENT Y-FORCE
            ADD.W   #GRAVITY,D1             ; APPLY GRAVITY TO CURRENT Y-FORCE
            MOVE.W  D1,ENEMYFCE(A1)         ; SET NEW Y-FORCE
            
            MOVE.L (A7)+,D1
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
ENCKCOL
            MOVEM.L D0-D4,-(A7)
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
            ADD.W   D1,D2                   ; GET INDEX IN TILEMAP
            MULS.W  #2,D2
            LEA.L   LVLCDAT,A1
            MOVE.W  0(A1,D2.W),D5           ; GET TILE OF COLISION
            BRA .RTN
.OUTMAPX
            MOVE.W  #-1,D5                  ; IT'S OUTSIDE OF MAP IN X AXIS
            SUB.W   #TILEPXS,D6
            MULS.W  #-1,D6
            BRA .RTN
.OUTMAPY
            MOVE.W  #0,D7                   ; IT'S OUTSIDE OF MAP IN Y AXIS
            MOVE.W  #0,D5
            
.RTN
            MOVE.L  (A7)+,A1
            MOVEM.L (A7)+,D0-D4
            RTS
            




                       








*~Font name~Courier New~
*~Font size~9~
*~Tab type~0~
*~Tab size~4~
