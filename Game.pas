// ***********************************************************************************************
//
//  Game Processing
//
//  Part of the simple Tetris game, Copyright 2026 Mike Dailly
//
//  Released under MIT License 
//  https://opensource.org/license/mit
//
// ****************************************************************************************************************

type
	tBLOCK_ARRAY = array [0..15] of byte;				// Type for passing blocks into fuctions

var
 	gCompleteLines : array[0..MAPY] of byte;                  	// Mark complete lines	
 	gMap : array[0..MAPY,0..MAPX] of byte;                    	// Tetris level "Map"
 	gBlocks : array[0..62] of byte absolute 'TetrisBlocks';   	// All dropping blocks
 	
 	gBlock :  tBLOCK_ARRAY;                                   	// the block we're dropping (y)
 	gRotBlock :  tBLOCK_ARRAY;                                	// rotate block	
 	gStartDelay : Integer;                                    	// frame delay before next block
 	gBlockSelect : Byte;                                      	// Block selected or -1 for none
 	gBlockX : byte;                                           	// Dropping block X
 	gBlockY : byte;                                           	// Dropping block Y
 	gBlockDropSpeed : byte;                                   	// 
 	gBlockDropSpeed_Master : byte;                            	// Master speed
 	gBlockMoveDeBounce : boolean;                             	// left/right key debounce 
 	
 	gDumpMap : boolean;                                       	// dump map debug debounce	
 	
 	gScore : integer;                                         	// Game score
 	gLines : integer;						// Number of Lines cleared
 	gLevel : byte;							// The level we're on



// *********************************************************************************************************
//	Randomly pick the next block to drop....
// *********************************************************************************************************
procedure PickBlock;
var index,b : Byte;
    s:string;
begin
  //Debug;
  gBlockSelect:= Random((MAX_BLOCKS+1));
  index:=gBlockSelect*16;			// 16 bytes per block

  // copy the block into our buffer
  for b:=0 to 15 do
  begin
    gBlock[b]:=gBlocks[index+b];
  end;

  // drop position
  gBlockX:=4;
  gBlockY:=0;
end;




// *********************************************************************************************************
// 	Clear the game screen
// *********************************************************************************************************
procedure  DrawPlayArea;
  var x,y:byte;
      c:byte;
begin
	memset(Ptr(Addr(gMap[0])),0, ((MAPX+1)*(MAPY+1)) );     // clear map


	// Draw border sides
	c:=3;
	for y:=0 to (MAPY-1) do
	begin
		gMap[y,0]:=c;
		gMap[y,(MAPX)]:=c;
		gScreen[y,0]:=c;
		gScreen[y,MAPX]:=c;
	end;

	// Draw bottom border 
	for x:=0 to MAPX do
	begin
		gMap[MAPY,x]:=c;
		gScreen[MAPY,x]:=c;
	end;
end;


// *********************************************************************************************************
// 	Setup the screen, and addresses that we'll need 
// *********************************************************************************************************
procedure SetupScreen;
begin
	CLS;

	// Centre game play area by setting the tilemaps scroll registers
	SetNextReg($2f,2);		
	SetNextReg($30,30);
	SetNextReg($31,210);

	// Draw the screen bounds
	DrawPlayArea;

	// Draw UI
	Print(14,2,'SCORE');
	Print(14,8,'LEVEL');
	Print(14,13,'LINES');
end;



// *********************************************************************************************************
// DEBUG: Dump the map "D" key
// *********************************************************************************************************
procedure DumpMap;
var s1,s2:string;
    xx,yy:byte;
begin

  DebugPrint(' ');
  for yy:=0 to MAPY do
  begin
    s1:='';
    for xx:=0 to MAPX do
    begin
      if (s1<>'') then s1:=s1+',';
      Str(gMap[yy,xx],s2);
      s1:=s1+s2;
    end;
    DebugPrint(s1);
  end;


end;


// *********************************************************************************************************
//  Check to see if there is a collision at the point we want to put a block,
//  making sure to skip "0's" in the selected block
//
//  In:   X   = X position in the game map
//        Y   = Y position in the game map
//	Block = The block to test with
//      
//  Out:  TRUE for Empty
//        FALSE for no NOT Empty
// *********************************************************************************************************
function IsEmpty(X,Y : Byte; var Block: tBLOCK_ARRAY) : Boolean;
var 
  test : byte;
  s:string;
begin
  test := 0;

  // X is unsigned, so if we go negative, it's actually 255
  if (x<240) then
  begin
    if Block[0]>0 then test := test or gMap[Y,X];
    if Block[4]>0 then test := test or gMap[Y+1,X];
    if Block[8]>0 then test := test or gMap[Y+2,X];
    if Block[12]>0 then test := test or gMap[Y+3,X];
  end;

  Inc(X);
  if (x<240) then
  begin
    if Block[1]>0 then test := test or gMap[Y,X];
    if Block[5]>0 then test := test or gMap[Y+1,X];
    if Block[9]>0 then test := test or gMap[Y+2,X];
    if Block[13]>0 then test := test or gMap[Y+3,X];
  end;

  Inc(X);
  if (x<240) then
  begin
    if Block[2]>0 then test := test or gMap[Y,X];
    if Block[6]>0 then test := test or gMap[Y+1,X];
    if Block[10]>0 then test := test or gMap[Y+2,X];
    if Block[14]>0 then test := test or gMap[Y+3,X];
  end;

  Inc(X);
  if (x<240) then
  begin
    if Block[3]>0 then test := test or gMap[Y,X];
    if Block[7]>0 then test := test or gMap[Y+1,X];
    if Block[11]>0 then test := test or gMap[Y+2,X];
    if Block[15]>0 then test := test or gMap[Y+3,X];
  end;


  if test=0 then 
    IsEmpty := true          //  Empty
  else
    IsEmpty := false
end;



// *********************************************************************************************************
//  Draw the block to the MAP
//  In:   X   = X position in the game map
//        Y   = Y position in the game map
// *********************************************************************************************************
procedure DrawInToMap(X,Y : Byte);
begin
  if gBlock[0]>0 then gMap[Y,X]:=gBlock[0];
  if gBlock[1]>0 then gMap[Y,X+1]:=gBlock[1];
  if gBlock[2]>0 then gMap[Y,X+2]:=gBlock[2];
  if gBlock[3]>0 then gMap[Y,X+3]:=gBlock[3];

  Inc(Y);
  if gBlock[4]>0 then gMap[Y,X]:=gBlock[4];
  if gBlock[5]>0 then gMap[Y,X+1]:=gBlock[5];
  if gBlock[6]>0 then gMap[Y,X+2]:=gBlock[6];
  if gBlock[7]>0 then gMap[Y,X+3]:=gBlock[7];

  Inc(Y);
  if gBlock[8]>0 then gMap[Y,X]:=gBlock[8];
  if gBlock[9]>0 then gMap[Y,X+1]:=gBlock[9];
  if gBlock[10]>0 then gMap[Y,X+2]:=gBlock[10];
  if gBlock[11]>0 then gMap[Y,X+3]:=gBlock[11];

  Inc(Y);
  if gBlock[12]>0 then gMap[Y,X]:=gBlock[12];
  if gBlock[13]>0 then gMap[Y,X+1]:=gBlock[13];
  if gBlock[14]>0 then gMap[Y,X+2]:=gBlock[14];
  if gBlock[15]>0 then gMap[Y,X+3]:=gBlock[15];
end;


// *********************************************************************************************************
//  Clear the block from the SCREEN
//  In:   X   = X position in the game map
//        Y   = Y position in the game map
// *********************************************************************************************************
procedure ClearBlock(X,Y : Byte);
begin
  if gBlock[0]>0 then gScreen[Y,X]:=0;
  if gBlock[1]>0 then gScreen[Y,X+1]:=0;
  if gBlock[2]>0 then gScreen[Y,X+2]:=0;
  if gBlock[3]>0 then gScreen[Y,X+3]:=0;

  Inc(Y);
  if gBlock[4]>0 then gScreen[Y,X]:=0;
  if gBlock[5]>0 then gScreen[Y,X+1]:=0;
  if gBlock[6]>0 then gScreen[Y,X+2]:=0;
  if gBlock[7]>0 then gScreen[Y,X+3]:=0;

  Inc(Y);
  if gBlock[8]>0 then gScreen[Y,X]:=0;
  if gBlock[9]>0 then gScreen[Y,X+1]:=0;
  if gBlock[10]>0 then gScreen[Y,X+2]:=0;
  if gBlock[11]>0 then gScreen[Y,X+3]:=0;

  Inc(Y);
  if gBlock[12]>0 then gScreen[Y,X]:=0;
  if gBlock[13]>0 then gScreen[Y,X+1]:=0;
  if gBlock[14]>0 then gScreen[Y,X+2]:=0;
  if gBlock[15]>0 then gScreen[Y,X+3]:=0;
end;

// *********************************************************************************************************
//  Draw the block to the SCREEN
//  In:   X   = X position in the game map
//        Y   = Y position in the game map
// *********************************************************************************************************
procedure DrawBlock(X,Y : Byte);
begin
  if gBlock[0]>0 then gScreen[Y,X]:=gBlock[0];
  if gBlock[1]>0 then gScreen[Y,X+1]:=gBlock[1];
  if gBlock[2]>0 then gScreen[Y,X+2]:=gBlock[2];
  if gBlock[3]>0 then gScreen[Y,X+3]:=gBlock[3];

  Inc(Y);
  if gBlock[4]>0 then gScreen[Y,X]:=gBlock[4];
  if gBlock[5]>0 then gScreen[Y,X+1]:=gBlock[5];
  if gBlock[6]>0 then gScreen[Y,X+2]:=gBlock[6];
  if gBlock[7]>0 then gScreen[Y,X+3]:=gBlock[7];

  Inc(Y);
  if gBlock[8]>0 then gScreen[Y,X]:=gBlock[8];
  if gBlock[9]>0 then gScreen[Y,X+1]:=gBlock[9];
  if gBlock[10]>0 then gScreen[Y,X+2]:=gBlock[10];
  if gBlock[11]>0 then gScreen[Y,X+3]:=gBlock[11];

  Inc(Y);
  if gBlock[12]>0 then gScreen[Y,X]:=gBlock[12];
  if gBlock[13]>0 then gScreen[Y,X+1]:=gBlock[13];
  if gBlock[14]>0 then gScreen[Y,X+2]:=gBlock[14];
  if gBlock[15]>0 then gScreen[Y,X+3]:=gBlock[15];
end;


// *********************************************************************************************************
// Rotate the current 4x4 block
// *********************************************************************************************************
procedure RotateBlock;
var b  : byte;
    i  : byte;
begin
  gRotBlock[0] := gBlock[12];
  gRotBlock[1] := gBlock[8];
  gRotBlock[2] := gBlock[4];
  gRotBlock[3] := gBlock[0];
  
  gRotBlock[4] := gBlock[13];
  gRotBlock[5] := gBlock[9];
  gRotBlock[6] := gBlock[5];
  gRotBlock[7] := gBlock[1];

  gRotBlock[8] := gBlock[14];
  gRotBlock[9] := gBlock[10];
  gRotBlock[10] := gBlock[6];
  gRotBlock[11] := gBlock[2];

  gRotBlock[12] := gBlock[15];
  gRotBlock[13] := gBlock[11];
  gRotBlock[14] := gBlock[7];
  gRotBlock[15] := gBlock[3];


  // Before copying the rotated block over, check we CAN rotate, and that it doesn't hit anything.
  if( isEmpty(gBlockX,gBlockY,gRotBlock)) then
    begin
      // no collision, then copy it over
      for i:=0 to 15 do
        gBlock[i]:=gRotBlock[i];
    end
end;



// *********************************************************************************************************
// Process a dropping block - from starting, to moving down and shifting left/right.
// *********************************************************************************************************
procedure ProcessBlock;
var hit : Boolean;
    s1,s2:string;
    left: byte;
    right: byte;
    down: byte;
    rotate: byte;
    LastX : byte;
    LastY : byte;
    draw : boolean;
begin
    LastX:=-1;
    LastY:=-1;
    draw:=false;

    // delay before next block - if >0 then waiting....
    if gStartDelay>0 then
      begin
        Dec(gStartDelay);
      end
    else
      begin
          // have we picked a block yet?
          if gBlockSelect=255 then
              begin
                  // if not, pick one and draw it at the top of the screen - but ALSO check to see if it's hitting anything.
                  PickBlock;
                  hit:=IsEmpty(gBlockX,gBlockY,gBlock);      // test block in this location
                  gBlockDropSpeed := gBlockDropSpeed_Master;
                  DrawBlock(gBlockX,gBlockY);

                  if hit = false then
                  begin
                    // if hit, then game over.
                      SetState(State_QuitGame);
                  end;
              end
          else
              begin
                  if gBlockDropSpeed>0 then
                      begin
                        Dec(gBlockDropSpeed);
                      end
                  else
                      begin
                            gBlockDropSpeed := gBlockDropSpeed_Master;
                            if IsEmpty(gBlockX,gBlockY+1,gBlock) then 
                                begin
                                  ClearBlock(gBlockX,gBlockY);
                                  Inc(gBlockY);
                                  DrawBlock(gBlockX,gBlockY);
                                end
                            else
                                begin
                                  // draw block in final location
                                  DrawInToMap(gBlockX,gBlockY);
                                  draw:=false;
                                  gStartDelay:=60;
                                  gBlockSelect:=255;
                                end;
                      end;  // else - if gBlockDropSpeed>0 then


                  // Block falling, do movement+rotate keys
                  if gBlockSelect<255 then
                  begin
                      // Move block left and right
                      left:=gKeys[VK_Z] or gKeys[VK_O] or gKeys[VK_5];
                      right:=gKeys[VK_X] or gKeys[VK_P] or gKeys[VK_8];
                      down:=gKeys[VK_A] or gKeys[VK_P] or gKeys[VK_6];
                      rotate:=gKeys[VK_SPACE];

                      if ((left<>0) or (right<>0) or (down<>0) or (rotate<>0)) and (gBlockMoveDeBounce=true) then
                        begin
                            // debounce key
                        end
                      else
                        begin
                        gBlockMoveDeBounce:=false;
                        if (left<>0) and (right<>0) and (down<>0) and (rotate<>0) then
                          begin
                            // multiple keys pressed? don't move.
                          end
                        else
                          begin
                              if left<>0 then
                                begin
                                    gBlockMoveDeBounce:=true;
                                    if IsEmpty(gBlockX-1,gBlockY,gBlock) then 
                                    begin
                                      ClearBlock(gBlockX,gBlockY);
                                      Dec(gBlockX);
                                      DrawBlock(gBlockX,gBlockY);
                                    end
                                end
                              else if right <> 0 then
                                begin
                                  gBlockMoveDeBounce:=true;
                                  if IsEmpty(gBlockX+1,gBlockY,gBlock) then 
                                    begin
                                      ClearBlock(gBlockX,gBlockY);
                                      Inc(gBlockX);
                                      DrawBlock(gBlockX,gBlockY);
                                    end
                                end
                              else if down <> 0 then
                                begin
                                  gBlockMoveDeBounce:=true;
                                  gBlockDropSpeed:=1;
                                end
                              else if (rotate <> 0) then
                                begin
                                  gBlockMoveDeBounce:=true;
                                  ClearBlock(gBlockX,gBlockY);
                                  RotateBlock;
                                  DrawBlock(gBlockX,gBlockY);
                                end;
                          end;

                      end;
                  end;
              end;  // else
      end;

end;


// *********************************************************************************************************
// Debug code
// *********************************************************************************************************
procedure DebugCode;
var x,y : byte;
begin
      // D to dump the map to the CSpect command line
      if (gKeys[VK_D]<>0) then
        if( gDumpMap=false) then
        begin
          gDumpMap:=true;
          DumpMap;
        end
        else
          begin
          end
      else
        gDumpMap:=false;


      if (gKeys[VK_S]<>0) then
        if( gDumpMap=false) then
        begin
            gDumpMap:=true;
            for y:=(MAPY-1) downto (MAPY-4) do
            begin
                for x:=1 to (MAPX-1) do
                begin
                  gMap[y,x]:=3;
                  gScreen[y,x]:=3;
                end;
            end;
        end
        else
          begin
          end
      else
          gDumpMap:=false;
end;



// ***************************************************************************************************
// Compress all solid lines out the map
// ***************************************************************************************************
procedure  CompressMap;
  var x,y,line : byte;
begin

    line:=(MAPY-1);
    while line>0 do
    begin
        if( gCompleteLines[line]=1) then
            begin        
                for x:=1 to  (MAPX-1) do
                begin
                    for y:=(line-1) downto 0 do
                      begin
                        gMap[y+1,x]:=gMap[y,x];
                        gScreen[y+1,x]:=gScreen[y,x];
                      end;
                end;


                for y:=(line-1) downto 0 do
                    gCompleteLines[y+1]:=gCompleteLines[y];

            end
        else
            begin
                Dec(line);
            end;
    end;


    for x:=1 to  (MAPX-1) do
    begin
      gMap[0,x]:=0;
      gScreen[0,x]:=0;
    end;

end;


// ***************************************************************************************************
// Detect solid lines, and if found, flash them and increase the score.
// ***************************************************************************************************
procedure DetectFullLines;
var i,x,y,count : byte;
var found : boolean;
var s : string;

begin

  // First detect filled lines
  found:=true;
  count:=MAPY;
  for y:=0 to MAPY-1 do 
  begin
    gCompleteLines[y]:=1;
    for x:=0 to MAPX do
    begin
        if (gMap[y,x]=0) then
        begin
            gCompleteLines[y]:=0;
            dec(count);
            break;
        end;
    end;
  end;


  if count=0 then exit;
  Inc(gLines,count);

  // 1=40, 2=100, 3=300, 4=1200
  case count of
    1  : Inc(gScore,40);
    2  : Inc(gScore,100);
    3  : Inc(gScore,300);
    4  : Inc(gScore,1200);
  end;


  // flash 5 times
  for i:=0 to 4 do
  begin

      // first set the row
      for y:=0 to MAPY-1 do 
      begin
        if( gCompleteLines[y]=1 ) then
        begin
            for x:=1 to MAPX-1 do
            begin
                gScreen[y,x]:=6;
            end;
        end;
      end;


      delay(200);


      // next clear the row
      for y:=0 to MAPY-1 do 
      begin
        if( gCompleteLines[y]=1 ) then
        begin
            for x:=1 to MAPX-1 do
            begin
                gScreen[y,x]:=0;
            end;
        end;
      end;

      delay(200);
  end;


  // Now move blocks down.
  CompressMap;
end;


// *********************************************************************************************************
// Print panel numbers - perhaps only update when changed?
// *********************************************************************************************************
procedure PrintPanel;
var s :string;
begin


  Str(gScore,s);
  PrintLeft(18,3,s);

  Str(gLevel,s);
  PrintLeft(17,9,s);

  Str(gLines,s);
  PrintLeft(17,14,s);
end;


// *********************************************************************************************************
// Init the game
// *********************************************************************************************************
procedure Game_Init;
begin
  gBlockSelect := -1;
  gStartDelay := 60;
  gBlockMoveDeBounce:=false;
  gScore := 0;

  gDumpMap:=false;
  gBlockDropSpeed_Master := 30;
  SetupScreen;

  SetState(State_Game);
end;


// *********************************************************************************************************
// Process the game
// *********************************************************************************************************
procedure Game_Process;
begin
        ProcessBlock;
        DetectFullLines;
        PrintPanel;

        DebugCode;	
end;


// *********************************************************************************************************
// Process the game9
// *********************************************************************************************************
procedure Game_Quit;
begin
	Print(1,10,'GAME  OVER');
	delay(3000);
  	SetState(State_InitFrontEnd);
end;

