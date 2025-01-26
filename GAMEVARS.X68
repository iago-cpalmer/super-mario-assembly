CAMX        DC.W    0
GAMESTA     DC.W    0
CLVLLOA     DC.W    0
; Player position
PLPOSX      DC.W    200                     ; X
PLPOSY      DC.W    200                     ; Y
PLMODI      DC.W    1                       ; CURRENT DIRECTION OF MOVEMENT
; Player animations
PLSPRR1     DC.L    ANIMPLWALKRIGHT         ; SMALL MARIO WALK TO RIGHT
PLSPRL1     DC.L    ANIMPLWALKLEFT          ; SMALL MARIO WALK TO LEFT
PLSPRID     DC.L    ANIMPLIDLE              ; SMALL MARIO IDLE
PLSPRIV     DC.L    ANIMPLINV               ; MARIO INVINCIBLE
PLSPRMS     DC.L    ANIMPLMSIDLE            ; MARIO ON MUSHROOM POWER-UP
PLSPRMSWR   DC.L    ANIMPLMSWALKRIGHT       ; MARIO ON MUSHROOM WALK TO RIGHT
PLSPRMSWL   DC.L    ANIMPLMSWALKLEFT        ; MARIO ON MUSHROOM WALK TO LEFT
; Coin counter
PLCOIN      DC.W    0       
; Player y-force
PLFCEY      DC.W    0

; Player was grounded variable;             0 = not grounded, 1 = grounded
PLGNDD      DC.W    0

; Player health points
PLHEALTH    DC.W    1                       

; Player active power-up
PLAPWUP     DC.W    0

; TIME LEFT OF INVINCIBILITY OF PLAYER
PLINVCB     DC.W    0                       
            

; DELTA TIME: TIME ELAPSED BETWEEN THE BEGINNING OF LAST FRAME AND BEGINNING OF CURRENT ONE
; IN HUNDRETHS OF A SECOND
DELTATIME   DC.L    0



























*~Font name~Courier New~
*~Font size~9~
*~Tab type~0~
*~Tab size~4~
