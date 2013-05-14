/*******************************************************************************
	UDKOSC

	Creation date: 12/06/2010 23:55
	Copyright (c) 2010, Rob Hamilton
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

//class udkosc extends GameInfo
class UDKOSC extends UTGame
 config(UDKOSC);

var config string OSCHostname;
var config int OSCPort;

//var vector object1;
//var vector object2;
//var vector object3;
//var vector object4;
//var vector object5;

//var array<vector> fingerTouchArray;



event PostLogin( PlayerController NewPlayer )
{
    super.PostLogin(NewPlayer);
    NewPlayer.ClientMessage("Welcome to the grid "$NewPlayer.PlayerReplicationInfo.PlayerName);
    NewPlayer.ClientMessage("Point at an object and press the left mouds button to retrieve the target's information");
	
	// Call custom console commands for setting up games
	initUDKOSC(NewPlayer);	
}


event PlayerController Login(string Portal, string Options, const UniqueNetID UniqueID, out string ErrorMessage)
{
	local PlayerController PC;
	PC = super.Login(Portal, Options, UniqueID, ErrorMessage);
	ChangeName(PC, "UDKOSC", true);
	
    return PC;
}

function initUDKOSC(PlayerController PC)
{
	`log("In Here...");
	PC.ConsoleCommand("ToggleHUD");	
	PC.ConsoleCommand("HideWeapon");		
	PC.ConsoleCommand("ChangePlayerMesh 2");
	PC.ConsoleCommand("BehindView");	
	PC.ConsoleCommand("BehindViewSet 28 0 -40");
	PC.ConsoleCommand("FlyWalk");	
}

/*
event PostBeginPlay() 
{
	`log ("Game Started - spawning OSCParams class!");
	spawn(class'OSCParams');
}
*/
defaultproperties
{
 //DefaultWorldInfoClass=class'UDKOSC.OSCWorldInfo'
 DefaultPawnClass=class'UDKOSC.OSCPawn'
 PawnClass=class'UDKOSC.OSCPawnBot'
 PlayerControllerClass=class'UDKOSC.OSCPlayerControllerDLL'

 // HIDING THESE FOR VALKORDIA
//   DefaultInventory[0] = class'UDKOSC.OSCWeap_SeekingShockRifle'
//   DefaultInventory[1] = class'UDKOSC.OSCWeap_ShockRifle'
// DefaultInventory[2] = class'UDKOSC.OSCWeap_LinkGun'


 //DefaultInventory[2] = class'UDKOSC.OSCWeap_RocketLauncher_Content'
 //fingerTouchArray=(object1, object2, object3, object4, object5);
 
// PlayerReplicationInfoClass=class'UDKOSC.OSCPlayerReplicationInfo'
	
 BotClass=class'UDKOSC.OSCBot'
 
 TimeLimit=0
 

 }