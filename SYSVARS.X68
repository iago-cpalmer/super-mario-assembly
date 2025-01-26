; --- KEYBOARD RELATED VARIABLES ----------------------------------------------

KBDVAL      DC.B    0                       ; KEY PRESSED=1
KBDEDGE     DC.B    0                       ; KEY CHANGED=1
            DS.W    0

; --- MOUSE RELATED VARIABLES -------------------------------------------------

MOUXPOS     DC.W    0                       ; CURRENT X MOUSE POSITION IN WINDOW
MOUYPOS     DC.W    0                       ; CURRENT Y MOUSE POSITION IN WINDOW
MOUBSTA     DC.B    0                       ; CURRENY MOUSE BUTTONS STATE: 0 - LEFT CLICK

; --- SCREEN RELATED VARIABLES ------------------------------------------------

SCRINTCT    DS.B    1                       ; INTERRUPT COUNTER/FLAG
SCRCYCCT    DS.B    1                       ; CYCLE COUNTER
            DS.W    0

; DELTA TIME
DELTATME    DC.W    0                       ; DELTA TIME

*~Font name~Courier New~
*~Font size~9~
*~Tab type~0~
*~Tab size~4~
