// use in kismet to slow down entire world
// http://forums.epicgames.com/showthread.php?t=715436
//
class OSCSeqAct_SetGameTime extends SequenceAction;

var() float GameSpeed;

event Activated()
{
    GetWorldInfo().Game.SetGameSpeed(GameSpeed);
}

defaultproperties
{
	ObjCategory="World"
	ObjName="Set Game Speed"
	GameSpeed=1.0
}