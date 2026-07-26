// ****************************************************************************************************************
//
//  A simple Tetris game, Copyright 2026 Mike Dailly
//
//  Released under MIT License 
//  https://opensource.org/license/mit
//
// ****************************************************************************************************************
program Hello;

{$m 1024}
{$ifndef SYS_ZXNEXT}
  {$error ZX Spectrum Next required.}
{$endif}


  procedure SetUpIRQs; register; external 'SetUpIRQs';
  procedure WaitVBlank; register; external 'WaitVBlank';
  procedure memset(X : Pointer; v : byte; size: Integer); register; external 'memset';
  procedure memcpy(src : Pointer; dest : Pointer; size: Integer); register; external 'memcpy';
  procedure ReadKeyboard; register; external 'ReadKeyboard';
  procedure DebugPrint(src : string); external 'DebugPrint';

type
    eState = (State_InitFrontEnd, State_FrontEnd, State_QuitFrontEnd, State_InitGame,State_Game,State_QuitGame );


const
  MAPY = 20;
  MAPX = 11;
  BLANK = 0;
  SOLID = 1;
  BOX = 2;
  MAX_BLOCKS = 6;     // 0 to 6

  VK_CAPS   =0;   // half row 1
  VK_Z      =1;
  VK_X      =2;
  VK_C      =3;
  VK_V      =4;

  VK_A      =5;   // half row 2
  VK_S      =6;
  VK_D      =7;
  VK_F      =8;
  VK_G      =9;

  VK_Q      =10;    // half row 3
  VK_W      =11;
  VK_E      =12;
  VK_R      =13;
  VK_T      =14;

  VK_1      =15;    // half row 4
  VK_2      =16;
  VK_3      =17;
  VK_4      =18;
  VK_5      =19;

  VK_0      =20;    // half row 5
  VK_9      =21;
  VK_8      =22;
  VK_7      =23;
  VK_6      =24;

  VK_P      =25;    // half row 6
  VK_O      =26;
  VK_I      =27;
  VK_U      =28;
  VK_Y      =29;

  VK_ENTER  =30;    // half row 7
  VK_L      =31;
  VK_K      =32;
  VK_J      =33;
  VK_H      =34;

  VK_SPACE  =35;    // half row 8
  VK_SYM    =36;
  VK_M      =37;
  VK_N      =38;
  VK_B      =39;


var 
  gScreen   : array[0..31,0..39] of byte absolute $6800;    // Hardware Screen mapped to a variable directly
  gTiles    : array[0..1024] of byte absolute $7000;        // Hardware tile data mapped to a variable directly
  gKeys     : array[0..287] of byte absolute 'Keys';        // Keyboard pressed

  gStartLevel : byte;                                       // starting game level  
  gGameState : eState;                                      // Main loop game state


  {$I Utils.pas}          //  Common Utilities
  {$I FrontEnd.pas}       //  Front End Code
  {$I Game.pas}           //  Game Code


// *********************************************************************************************************
// Main Start up
// *********************************************************************************************************
begin
  SetCpuSpeed(3);
  SetUpIRQs;
  CreateTiles;
  Randomize;


  SetState(State_InitFrontEnd);
  while true do
  begin    
        WaitVBlank;
        ReadKeyboard;
        Random(255);
        // Do game states
        Case gGameState of

            State_InitFrontEnd:
              begin
                  FE_Init;
              end;            
            State_FrontEnd:
              begin
                  FE_Process;
              end;
            State_QuitFrontEnd:
              begin
                  FE_Quit;
              end;


            State_InitGame:
            begin
                Game_Init;
            end;
            State_Game:
            begin
                Game_Process;
            end;
            State_QuitGame:
            begin
                Game_Quit;
            end;
        else            
            SetState(State_InitFrontEnd);              
        end;

  end;


    // ASM needs to be included last, so org addresses can move about for the IRQ vector
    {$l kernal.asm}
end.


