class OSCThirdPersonCameraMode_Default extends GameThirdPersonCameraMode_Default;


/** Returns FOV that this camera mode desires */
function float GetDesiredFOV( Pawn ViewedPawn )
{
	return 70.0;
}


defaultproperties
{

	ViewOffset={)
		OffsetHigh=(X=-256,Y=56,Z=40),
		OffsetLow=(X=-320,Y=48,Z=56),
		OffsetMed=(X=-320,Y=48,Z=16),
	)}
}