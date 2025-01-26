; ANIMATIONS DATA
ANIMFRAME   DC.W    0                       ; GLOBAL FRAME OF ANIMATION
ANIMACTI    DC.W    0                       ; CURRENT ACCUMULATED TIME OF FRAME
ANIMTIME    EQU     15                    ; TIME BETWEEN FRAMES OF ANIMATIONS IN HUNDRETHS OF A SECOND

; ANIMATIONS LIST
ANIMGOOMBA
            DC.W    2                       ; NUMBER OF FRAMES
            DC.L    IMGGOOMBALFEET          ; FIRST FRAME
            DC.L    IMGGOOMBARFEET          ; SECOND FRAME
ANIMMUSHROOM
            DC.W    1
            DC.L    IMGMUSHROOMPWUP         ; FIRST FRAME
ANIMCOIN
            DC.W    4
            DC.L    IMGCOINONE
            DC.L    IMGCOINTWO
            DC.L    IMGCOINTHREE
            DC.L    IMGCOINFOUR
ANIMFLAG
            DC.W    1
            DC.L    IMGFLAGSTICK
ANIMFLAGTOP
            DC.W    1
            DC.L    IMGFLAGTOP            
ANIMPLWALKRIGHT
            DC.W    4
            DC.L    IMGMARIOWALKONE
            DC.L    IMGMARIOWALKTWO
            DC.L    IMGMARIOWALKTHREE
            DC.L    IMGMARIOWALKTWO
            
ANIMPLWALKLEFT
            DC.W    4
            DC.L    IMGMARIOWALKONELEFT
            DC.L    IMGMARIOWALKTWOLEFT
            DC.L    IMGMARIOWALKTHREELEFT
            DC.L    IMGMARIOWALKTWOLEFT 
ANIMPLMSWALKRIGHT
            DC.W    4
            DC.L    IMGMSWALKONE
            DC.L    IMGMSWALKTWO
            DC.L    IMGMSWALKTHREE
            DC.L    IMGMSWALKTWO
            
ANIMPLMSWALKLEFT
            DC.W    4
            DC.L    IMGMSWALKLEFTONE
            DC.L    IMGMSWALKLEFTTWO
            DC.L    IMGMSWALKLEFTTHREE
            DC.L    IMGMSWALKLEFTTWO

ANIMPLIDLE
            DC.W    1
            DC.L    IMGMARIOSMALL 

ANIMPLMSIDLE
            DC.W    1
            DC.L    IMGMSWALKTWO

ANIMPLINV
            DC.W    1
            DC.L    IMGMARIOINVENCIBLE 

*~Font name~Courier New~
*~Font size~9~
*~Tab type~0~
*~Tab size~4~
