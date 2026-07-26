;
;
;
                opt             ZXNEXT


                org     $7f00
Start:
                call    $8000
                di                      
                ld      a,0
Lp:
                out     ($fe),a
                inc     a
                jp      Lp


                org     $8000
                incbin "tetris.bin"


                savenex "tetris.nex", Start

