// ****************************************************************************************************************
//
// Front End
//
//  Part of the simple Tetris game, Copyright 2026 Mike Dailly
//
//  Released under MIT License 
//  https://opensource.org/license/mit
//
// ****************************************************************************************************************

var
	gMenuDebounce : boolean;


// *********************************************************************************************************
// Clear and 
// *********************************************************************************************************
procedure  DrawMenu;
var s : string;
begin
	Print(5,7,'1  -  START GAME');
	Print(5,9,'2  -  INCREASE START LEVEL');
	Print(5,11,'3  -  DECREASE START LEVEL');

	Print(14,18,'START LEVEL');

	Str(gStartLevel,s);
	PrintLeft(20,20,'  '+s);

	Print(5,25,'PASCAL TETRIS BY MIKE DAILLY');
end;


// ****************************************************************************************
//  Handle the main loop and state changes
// ****************************************************************************************
procedure FE_Init;
begin
	CLS;
	SetNextReg($2f,0);		// reset tilemap scrolling
	SetNextReg($30,0);
	SetNextReg($31,0);
	
	DrawMenu;
	SetState(State_FrontEnd);
end;

// ****************************************************************************************
//  Front End processing
// ****************************************************************************************
procedure FE_Process;
var k1,k2,k3 : byte;
begin
	k1 :=gKeys[VK_1];
	k2 :=gKeys[VK_2];
	k3 :=gKeys[VK_3];


	if ((k1<>0) or (k2<>0) or (k3<>0)) and (gMenuDebounce=false) then
	begin
		gMenuDebounce:=true;

		if k1<>0 then
		begin
			SetState(State_QuitFrontEnd);
		end
		else if k2<>0 then
		begin
			if gStartLevel>0 then Dec(gStartLevel);
			DrawMenu;
		end
		else if k3<>0 then
		begin
			if gStartLevel<20 then Inc(gStartLevel);
			DrawMenu;
		end
	end
	else if ((k1=0) and (k2=0) and (k3=0)) then
	begin
		gMenuDebounce:=false;
	end;

end;

// ****************************************************************************************
//  Quit Front End
// ****************************************************************************************
procedure FE_Quit;
begin
	SetState(State_InitGame);
end;

