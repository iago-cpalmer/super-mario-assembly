; CONSTANTS FOR CURRENT LOADED LEVEL
MAXMW       EQU     389                     ; MAX MAP WIDTH (For current level)
MAXMH       EQU     10                      ; MAX MAP HEIGHT (For current level)

; HERE WILL BE STORED THE CURRENT LOADED LEVEL TO MAKE CHANGES DURING GAME IN IT, TO KEEP THE ORIGINAL LEVEL UNTOUCHED
LVLCDAT     DS.W    MAXMW*MAXMH             ; CREATE SPACE IN MEMORY FOR THE CURRENT LEVEL LOADED  
MTLHGHT     DC.W    0                       ; CURRENT LOADED LEVEL HEIGHT IN TILES
MTLWDTH     DC.W    0                       ; CURRENT LOADED LEVEL WIDTH IN TILES
MAPPXSZ     DC.W    0                       ; CURRENT LOADED LEVEL WIDTH IN PIXELS        



; Tile info constants
TILEPXS     EQU     WDHEIGHT/10             ; Tile size in pixels
PXPERIM     EQU     16                      ; NUMBER OF PIXELS PER IMAGE (16x16)
PXSCALE     EQU     TILEPXS/PXPERIM         ; SCALE OF PIXELS (NUMBER OF SCREEN PIXELS FOR A SPRITE PIXEL)
NTILESC     EQU     WDWIDTH/TILEPXS+1       ; Number of tiles in camera in x-axis
TILESZB     EQU     16                      ; Size of tile info in bytes
; Tile entity type constants
TENOBEH     EQU     0                       ; IT'S NOT A TILE ENTITY
TEONCOL     EQU     1                       ; TILE ENTITY WITH BEHAVIOUR WHEN COLLIDING WITH HEAD
TEONLOA     EQU     2                       ; TILE ENTITY WITH BEHAVIOUR WHEN LOADING THE LEVEL 
; Offsets for tile info
OFFFCLR     EQU     0                       ; OFFSET OF POINTER TO FILL COLOR
OFFECLR     EQU     4                       ; OFFSET OF POINTER TO EDGE COLOR
ISTLENT     EQU     8                       ; OFFSET OF IS TILE ENTITY PROPERTY
BEHAVSR     EQU     10                       ; OFFSET OF BEHAVIOUR SUBROUTINE POINTER
ADDPROP     EQU     14                      ; OFFSET OF ADDITIONAL PROPERTY OF TILE
; --- Tile Info
            
TILE1       DC.L    $00004A9C               ; FILL COLOR
            DC.L    $0003E83                ; EDGE COLOR
            DC.W    TENOBEH                 ; Is Tile Entity? 0: No, >1: Yes
            DC.L    0                       ; Subroutine of behavior
            DC.W    0
            
TILE2       DC.L    $00C5CEFF               ; POINTER TO SPRITE
            DC.L    $00004A9C               ; EDGE COLOR
            DC.W    TENOBEH                 ; Is Tile Entity? 0: No, >1: Yes
            DC.L    0                       ; Subroutine of behavior
            DC.W    0
; BOX THAT BREAKS AND IT'S REPLACED WITH AIR
TILE3       DC.L    $00003C7E               ; POINTER TO SPRITE
            DC.L    $00031931               ; EDGE COLOR
            DC.W    TEONCOL                 ; Is Tile Entity? 0: No, >1: Yes
            DC.L    BRKTILE                 ; Subroutine of behavior
            DC.W    0                       ; Tile to replace this one when breaking
; SPAWNER OF GOOMBA           
TILE4       DC.L    $00FFFF00                      ; POINTER TO SPRITE
            DC.L    $0003E83                ; EDGE COLO
            DC.W    TEONLOA                 ; Is Tile Entity? 0: No, >1: Yes
            DC.L    SPAWNER                 ; Subroutine of behavior
            DC.W    0                       ; Entity type to spawn
; BOX OF POWER-UP (Mushroom)
TILE5
            DC.L    $00219CE6               ; POINTER TO SPRITE
            DC.L    $00004A9C               ; EDGE COLOR
            DC.W    TEONCOL                 ; Is Tile Entity? 0: No, >1: Yes
            DC.L    SPWNTOP                 ; Subroutine of behavior
            DC.W    $0601                   ; Less significant byte: Entity type to spawn, Most significant byte: block id to replace it with after        
; BLOCKED BOX TILE
TILE6
            DC.L    $00031931               ; POINTER TO SPRITE
            DC.L    $00000000               ; EDGE COLOR
            DC.W    TENOBEH                 ; Is Tile Entity? 0: No, >1: Yes
            DC.L    0                       ; Subroutine of behavior
            DC.W    0                       ; 

; BOX WITH COIN
TILE7
            DC.L    $00003C7E               ; POINTER TO SPRITE
            DC.L    $00031931               ; EDGE COLOR
            DC.W    TEONCOL                 ; Is Tile Entity? 0: No, >1: Yes
            DC.L    SPWNTOP                 ; Subroutine of behavior
            DC.W    $0602                   ; Less significant byte: Entity type to spawn, Most significant byte: block id to replace it with after        

; PIPE
TILE8       
            DC.L    $000000FF00             ; POINTER TO SPRITE
            DC.L    $000000AA00             ; EDGE COLOR
            DC.W    TENOBEH                 ; Is Tile Entity? 0: No, >1: Yes
            DC.L    0                       ; Subroutine of behavior
            DC.W    0                       ; 
; SPAWNER OF FLAG ENTITY
TILE9
            DC.L    $00FFFF00               ; POINTER TO SPRITE
            DC.L    $0003E83                ; EDGE COLO
            DC.W    TEONLOA                 ; Is Tile Entity? 0: No, >1: Yes
            DC.L    SPAWNER                 ; Subroutine of behavior
            DC.W    3                       ; Entity type to spawn
; SPAWNER OF FLAG TOP ENTITY
TILE10
            DC.L    $00FFFF00               ; POINTER TO SPRITE
            DC.L    $0003E83                ; EDGE COLO
            DC.W    TEONLOA                 ; Is Tile Entity? 0: No, >1: Yes
            DC.L    SPAWNER                 ; Subroutine of behavior
            DC.W    4                       ; Entity type to spawn
; --- Tile on load subroutines: (All tile behavior subroutines have the same input and output)
;     Input:
;           - A1.L  - ADDRESS OF TILE
;     Output:
;           - None
;     Modifies:
;           - Tile map
; --------------------------------------------------------------------------- 

; SPAWNS AN ENTITY AT THE TOP OF TILE
SPWNTOP
            MOVEM.L D0-D7,-(A7)
            MOVEM.L A0-A2,-(A7)
            CLR.L   D5
            MOVE.W  D1,D3                   ; SAVE X COORDS FOR LATER
            MOVE.W  D2,D4                   ; SAVE Y COORDS FOR LATER
                        
            ; GET INDEX OF TILE IN MAP 
            LEA.L   LVLCDAT,A1
            LEA.L   TILE1,A0
            MULS.W  MTLWDTH,D2
            ADD.W   D1,D2                   
            MULS.W  #2,D2
            MOVE.W  D2,D6
            MOVE.W  0(A1,D2.W),D5           ; GET TILE ID
            SUBQ.W  #1,D5
            MULU.W  #TILESZB,D5             ; GET TILE ADDRESS
            ; SPAWN ENTITY
            CLR.B   D2
            MOVE.W  ADDPROP(A0,D5.W),D2     ; GET ENEMY TYPE TO SPAWN IN D2 TO SPAWN IT 
            AND.W   #$00FF,D2           
            LEA.L   ENEMLIS,A1
            MOVE.W  #-1,D7
.FNDNXT
            ADDQ.W  #1,D7
            MOVE.L  (A1)+,D0
            CMP.L   #$FFFFFFFF,D0
            BNE     .FNDNXT
            CMP.W   #ENEMCOUN,D7
            BGE     .RTN
            SUB.L   #4,A1       
            ; WE FOUND THE LAST EMPTY PLACE IN LIST
            MOVE.W  D3,D0                   ; RESTORE TILE POSITION IN TILE COORDS - X AXIS
            MOVE.W  D4,D1                   ; RESTORE TILE POSITION IN TILE COORDS - Y AXIS
            SUBQ.W  #1,D1                   ; WE WANT IT TO SPAWN AT TOP
            MULS.W  #TILEPXS,D0             ; CONVERT IT TO PX COORD
            MULS.W  #TILEPXS,D1             ; CONVERT IT TO PX COORD
            JSR     DMALLOC
            MOVE.L  A0,(A1)+                ; STORE POINTER OF ENEMY IN THE LIST OF ENEMIES
            MOVE.L  #$FFFFFFFF,(A1)         ; SET END-POINT            
            MOVE.B  D2,(A0)+                ; SET ENEMY TYPE
            MOVE.B  #ENSTDSB,(A0)+          ; SET DISABLED
            MOVE.W  #-1,(A0)+               ; SET DIRECTION TO LEFT
            ADD.W   #TILEPXS/2,D0
            ADD.W   #TILEPXS/2,D1
            MOVE.W  D0,(A0)+                ; SET X POSITION
            MOVE.W  D1,(A0)+                ; SET Y POSITION
            MOVE.W  #0,(A0)+                ; SET Y FORCE
.RTN            
            LEA.L   LVLCDAT,A1
            LEA.L   TILE1,A0
            CLR.W   D2
            MOVE.W  ADDPROP(A0,D5.W),D2     ; GET ADDITIONAL PROPERTY OF TILE
            LSR.W   #8,D2                   ; GET TILE TO REPLACE IT WITH IN MAP
            MOVE.W  D2,0(A1,D6.W)           ; Replace tile in map
            
            MOVEM.L (A7)+,A0-A2
            MOVEM.L (A7)+,D0-D7
            RTS   

; SPAWNS AN ENEMY
SPAWNER
            MOVEM.L D0-D7,-(A7)
            MOVEM.L A0-A2,-(A7)
            CLR.L   D5
            MOVE.W  D1,D3                   ; SAVE X COORDS FOR LATER
            MOVE.W  D2,D4                   ; SAVE Y COORDS FOR LATER
                        
            ; GET INDEX OF TILE IN MAP 
            LEA.L   LVLCDAT,A1
            LEA.L   TILE1,A0
            MULS.W  MTLWDTH,D2
            ADD.W   D1,D2                   
            MULS.W  #2,D2
            MOVE.W  D2,D6
            MOVE.W  0(A1,D2.W),D5           ; GET TILE ID
            SUBQ.W  #1,D5
            MULU.W  #TILESZB,D5             ; GET TILE ADDRESS
            ; SPAWN ENEMY
            MOVE.W  ADDPROP(A0,D5.W),D2     ; GET ENEMY TYPE TO SPAWN IN D2 TO SPAWN IT            
            LEA.L   ENEMLIS,A1
            MOVE.W  #-1,D7
.FNDNXT
            ADDQ.W  #1,D7
            MOVE.L  (A1)+,D0
            CMP.L   #$FFFFFFFF,D0
            BNE     .FNDNXT
            CMP.W   #ENEMCOUN,D7
            BGE     .RTN
            ;MOVE.L  A1,D7
            SUB.L   #4,A1
            ;MOVE.L  D7,A1         
            ; WE FOUND THE LAST EMPTY PLACE IN LIST
            MOVE.W  D3,D0                   ; RESTORE TILE POSITION IN TILE COORDS - X AXIS
            MOVE.W  D4,D1                   ; RESTORE TILE POSITION IN TILE COORDS - Y AXIS
            MULS.W  #TILEPXS,D0             ; CONVERT IT TO PX COORD
            MULS.W  #TILEPXS,D1             ; CONVERT IT TO PX COORD
            JSR     DMALLOC
            MOVE.L  A0,(A1)+                ; STORE POINTER OF ENEMY IN THE LIST OF ENEMIES
            MOVE.L  #$FFFFFFFF,(A1)         ; SET END-POINT            
            MOVE.B  D2,(A0)+                ; SET ENEMY TYPE
            MOVE.B  #ENSTDSB,(A0)+          ; SET DISABLED
            MOVE.W  #-1,(A0)+               ; SET DIRECTION TO LEFT
            ADD.W   #TILEPXS/2,D0
            ADD.W   #TILEPXS/2,D1
            MOVE.W  D0,(A0)+                ; SET X POSITION
            MOVE.W  D1,(A0)+                ; SET Y POSITION
            MOVE.W  #0,(A0)+                ; SET Y FORCE
.RTN            
            LEA.L   LVLCDAT,A1
            MOVE.W  #0,0(A1,D6.W)           ; Replace tile in map
            MOVEM.L (A7)+,A0-A2
            MOVEM.L (A7)+,D0-D7
            RTS   
; --- Tile behavior functions: (All tile behavior subroutines have the same input and output)
;     Input:
;           - D1.W: X position of tile in tile coords
;           - D2.W: Y position of tile in tile coords
;     Output:
;           - None
;     Modifies:
;           - Tile map
; ---------------------------------------------------------------------------             
; Breaks the tile in tilemap            
BRKTILE
            MOVEM.L D1-D2,-(A7)
            MOVEM.L A1,-(A7)
            
            ; GET INDEX OF TILE IN MAP
            LEA.L   LVLCDAT,A1
            LEA.L   TILE1,A2
            MULS.W  MTLWDTH,D2
            ADD.W   D1,D2                   
            MULS.W  #2,D2
            
            MOVE.W  0(A1,D2.W),D3           ; GET TILE ID
            SUBQ.W  #1,D3
            MULU.W  #TILESZB,D3             ; GET TILE ADDRESS
            
            MOVE.W  ADDPROP(A2,D3.W),0(A1,D2.W)           ; Replace tile in map
            
            MOVEM.L (A7)+,A1
            MOVEM.L (A7)+,D1-D2
            RTS

            




























*~Font name~Courier New~
*~Font size~9~
*~Tab type~0~
*~Tab size~4~
