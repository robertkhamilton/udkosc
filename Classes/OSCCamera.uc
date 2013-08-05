class OSCCamera extends GamePlayerCamera;

struct OSCScriptCameramoveStruct
{
	var float x;
	var float y;
	var float z;
	var float speed;
	var float pitch;
	var float yaw;
	var float roll;
};

var OSCScriptCameramoveStruct localOSCScriptCameramoveStruct;

/*
event float GetDesiredFOV( Pawn ViewedPawn )
{
	if( bFocusPointSet && ( FocusPoint.CameraFOV > 0.f ) && bFocusPointSuccessful )
	{
		return FocusPoint.CameraFOV;
	}
	
	return CurrentCamMode.GetDesiredFOV( ViewedPawn );

}
*/

defaultproperties
{

}