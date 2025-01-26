*-----------------------------------------------------------
* Title      : Super Mario Bros Clone
* Written by : Iago 'Haukrr' Caldentey Palmer
* Date       :
* Description:
*-----------------------------------------------------------
            ORG    $1000
            INCLUDE "SPRITES.X68"
            INCLUDE "ANIMATIONSDATA.X68"
            INCLUDE "POWER-UPS.X68"
            INCLUDE "UTILS.X68"
            INCLUDE "STRINGS.X68"
            INCLUDE "SYSCONST.X68"
            INCLUDE "MAPDATA.X68"
            INCLUDE "LEVELDATA.X68"
            INCLUDE "ENEMIES.X68"
            INCLUDE "SYSVARS.X68"
            INCLUDE "BUTTONS.X68"
            INCLUDE "RENDERER.X68"
            INCLUDE "GAMECONSTS.X68"
            INCLUDE "GAMEVARS.X68"
            INCLUDE "GAMELOGIC.X68"
            INCLUDE "DYNAMICMEMORY.X68"
            INCLUDE "SYSTEM.X68"
; ------ Initialization -----------------------------------	
START:               
            JSR     SYSINIT                 ; INIT SYSTEM
            JSR     STRINIT
            ; INIT GAME STATE
; ------ Main Game Loop -----------------------------------
.LOOP:
            ; GET CURRENT TIME
            MOVE.W  #8,D0
            TRAP    #15
            SUB.L   D2,D1                   ; GET ELAPSED TIME
            MOVE.L  D2,DELTATIME
            MOVE.L  D1,D2                   ; SAVE CURRENT TIME IN D2

            ; READ INPUT
            TRAP    #KBUTRAP
            ; UPDATE STATE
            JSR     STAUPD
            
            ; DRAW ON WINDOW
.WINT       TST.B   (SCRINTCT)              ; WAIT FOR INTERRUPT
            BEQ     .WINT
            CLR.B   (SCRINTCT)
            
            JSR     RENDER                  ; PLOT DEPENDING ON THE STATE
            TRAP    #WDUTRAP                ; SHOW GRAPHICS

            BRA     .LOOP


EXIT            
    SIMHALT             ; halt simulator
    END    START        ; last line of source


            
            
            
            
            
            






















*~Font name~Courier New~
*~Font size~9~
*~Tab type~0~
*~Tab size~4~
