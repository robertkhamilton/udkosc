/*******************************************************************************
	ut3osc

	Creation date: 12/06/2010 23:55
	Copyright (c) 2010, Rob Hamilton
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

//class ut3osc extends GameInfo
class UT3OSC extends UTGame
 config(UT3OSC);

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
}


event PlayerController Login(string Portal, string Options, const UniqueNetID UniqueID, out string ErrorMessage)
{
	local PlayerController PC;
	PC = super.Login(Portal, Options, UniqueID, ErrorMessage);
	ChangeName(PC, "Teleharmonium", true);
    return PC;
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
 //DefaultWorldInfoClass=class'UT3OSC.OSCWorldInfo'
 DefaultPawnClass=class'UT3OSC.OSCPawn'
 PawnClass=class'UT3OSC.OSCPawnBot'
 PlayerControllerClass=class'UT3OSC.OSCPlayerControllerDLL'

 DefaultInventory[0] = class'UT3OSC.OSCWeap_SeekingShockRifle'
 DefaultInventory[1] = class'UT3OSC.OSCWeap_ShockRifle'
 //DefaultInventory[2] = class'UT3OSC.OSCWeap_RocketLauncher_Content'
 DefaultInventory[2] = class'UT3OSC.OSCWeap_LinkGun'
 //fingerTouchArray=(object1, object2, object3, object4, object5);
 
// PlayerReplicationInfoClass=class'UT3OSC.OSCPlayerReplicationInfo'
	
 BotClass=class'UT3OSC.OSCBot'

 }