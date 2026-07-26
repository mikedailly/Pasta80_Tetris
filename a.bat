
pasta --zxnext --dep --opt --keepint tetris.pas
if ERRORLEVEL 1 goto doexit

..\Demo\snasm.exe -map tetris_launcher.asm tetristmp.bin
if ERRORLEVEL 1 goto doexit

..\Demo\CSpect.exe -sound -vsync -w3 -debug -brk -dscale -pasta80=tetris.lst tetris.nex

:doexit