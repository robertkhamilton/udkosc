/*******************************************************************************
	OSCPlayerController

	Creation date: 13/06/2010 00:58
	Copyright (c) 2010, beast
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

//class OSCPlayerController extends PlayerController 
class OSCPlayerController extends UTPlayerController 
 config(ut3osc);
 
defaultproperties
{
}
 



exec function StartFire( optional byte FireModeNum )
{
	Super.StartFIre(FireModeNum);
}
/* 
function PlayerTick(float DeltaTime)
{
// ClientMessage("TESTING123");
}
 
function PlayerMove(float DeltaTIme)
{
//ClientMessage("THis is s a atest");
}
function ClientUpdatePosition()
{
//ClientMessage("TESTING");
}
*/


