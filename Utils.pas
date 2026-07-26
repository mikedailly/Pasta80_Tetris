// ****************************************************************************************************************
//
// Utilities
//
//  Part of the simple Tetris game, Copyright 2026 Mike Dailly
//
//  Released under MIT License 
//  https://opensource.org/license/mit
//
// ****************************************************************************************************************

var
 	gTileData : array[0..1439] of byte absolute 'Tiles';      // tile graphics
 	gTilePal : array[0..511] of byte absolute 'TilePalette';  // tile palette	

// *********************************************************************************************************
//	Set Game State
// *********************************************************************************************************
procedure SetState( state : eState );
begin
  gGameState:=state;
end;


// *********************************************************************************************************
//	Clear the tilemap screen
// *********************************************************************************************************
procedure CLS;
begin
	memset(Ptr(Addr(gScreen)),0,40*32);
end;

// *********************************************************************************************************
//  	Print text to the screen
//  	In:  x,y = coordinate
//      	 txt = text to print. Only numbers and UPPERCASE letters
// *********************************************************************************************************
procedure Print(x,y : byte; txt : string);
var xx,len,i : byte;
    ch : char;
begin

  len:=length(txt);
  for xx:=1 to len do
  begin
    i:=0;     // space
    ch:=txt[xx];   
    if((ch>='0') and (ch<='9')) then
      begin
        i:=(ord(ch)-ord('0'))+9;           // numbers start at 8
      end
    else
    if((ch>='A') and (ch<='Z')) then
      begin
        i:=(ord(ch)-ord('A'))+19;          // Letters start at 18
      end
    else
      i:=0;                                // space or unknown

    gScreen[y,x]:=i;
    Inc(x);

  end;
end;


// *********************************************************************************************************
//  	Print text to the screen from right to left (align right)
//  	In:  x,y	= coordinate
//         txt	= text to print. Only numbers and UPPERCASE letters
// *********************************************************************************************************
procedure PrintLeft(x,y : byte; txt : string);
var xx,len,i : byte;
    ch : char;
begin

  len:=length(txt);
  for xx:=len downto 1 do
  begin
    i:=0;     // space
    ch:=txt[xx];   
    if((ch>='0') and (ch<='9')) then
      begin
        i:=(ord(ch)-ord('0'))+9;           // numbers start at 8
      end
    else
    if((ch>='A') and (ch<='Z')) then
      begin
        i:=(ord(ch)-ord('A'))+19;          // Letters start at 18
      end
    else
      i:=0;                                // space or unknown

    gScreen[y,x]:=i;
    Dec(x);

  end;
end;


// *********************************************************************************************************
//	Create out tileset, and setup the palette
// *********************************************************************************************************
procedure CreateTiles;
var
  i : Integer;
begin
  // Copy over all 45 tiles, 32 bytes each - first one is blank
  memcpy(Ptr(Addr(gTileData)), Ptr(Addr(gTiles)), 1440);


  // setup the palette
  SetNextReg($43,$30);         // select the first tilemap
  SetNextReg($40,$00);         // set the first index (0)

  // Loop over the whole 256 colours (we only use 16 really but...)
  i:=0;
  while i<512 do
  begin
    SetNextReg($44,gTilePal[i]);
    SetNextReg($44,gTilePal[i+1] and 1);
    Inc(i,2);
  end;


  // Setup the Tilemap itself
  SetNextReg($6b,$A1);      // %10100001	(enable | Eliminate Attribute | Force Tilemap on top of ULA)
  SetNextReg($6e,$28);      // Set Tilemap base address to $6800
  SetNextReg($6F,$30);      // Set Tile definition address to $7000
  SetNextReg($4c,$01);      // set pink as transparent 
end;
