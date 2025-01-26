;-----------------------------------------------------------
; CONSTANTS
; ----------------------------------------------------------

KBUTRAP     EQU     0                       ; keyboard update trap
WDUTRAP     EQU     1                       ; update window trap

KEYUP       EQU     'W'                     ; w key         
KEYLEFT     EQU     'A'                     ; a key
KEYRGHT     EQU     'D'                     ; d key
KEYDOWN     EQU     'S'                     ; s key

; -- Bit map positions for keyboard
KUPBMAP     EQU     0
KDWBMAP     EQU     1
KLTBMAP     EQU     2
KRTBMAP     EQU     3

; -- Bit map positions for mouse
MLBUMAP     EQU     0

; -- Bit masks for mouse buttons
MLBUMSK     EQU     1<<MLBUMAP

; -- Bit masks for keys

KUPMSK      EQU     1<<KUPBMAP
KDWMSK      EQU     1<<KDWBMAP
KLTMSK      EQU     1<<KLTBMAP
KRTMSK      EQU     1<<KRTBMAP

; -- Window constants
WDHEIGHT    EQU     720                     ; Window height
WDWIDTH     EQU     1024                    ; Window width
WDIRQ       EQU     1                       ; Window interrupt number
WDFPS       EQU     30                      ; Window frames per second
WDRTIME     EQU     1000/WDFPS              ; Window refresh timer (ms)
SPEEDMULTIPLIER EQU 4

















*~Font name~Courier New~
*~Font size~9~
*~Tab type~0~
*~Tab size~4~
