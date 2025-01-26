; POWER-UPS
NONEPWI     EQU     0                       ; ID OF NONE POWER-UP
MRMPWID     EQU     1                       ; ID OF MUSHROOM POWER-UP 

NONEPWUP
            DC.L    PWUPNOB                 ; SUBROUTINE OF BEHAVIOR WHEN USING POWER-UP
MROMPWUP    
            DC.L    PWUPNOB                 ; SUBROUTINE OF BEHAVIOR WHEN USING POWER-UP
          
  
; SUBROUTINE OF POWER-UP WITH NO BEHAVIOR WHEN USING IT
PWUPNOB    RTS

; Subroutine to do the fire-flower-up action when using power-up
FIREFLR
            RTS     

*~Font name~Courier New~
*~Font size~9~
*~Tab type~0~
*~Tab size~4~
