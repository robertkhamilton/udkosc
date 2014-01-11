/*******************************************************************************
	OSCPlayerInput

	Creation date: 13/06/2010 00:58
	Copyright (c) 2010, beast
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class OSCPlayerInput extends PlayerInput within OSCPlayerController 
 config(ut3osc);
 
 
 event PlayerInput (float DeltaTime)
 {
    
	bEnableMouseSmoothing  = True;
 
	Super.PlayerInput(DeltaTime);
	
	aMouseX = 0.f;
//	aTurn		= 0.f;
	
 }
 
 /*
// Postprocess the player's input. 
event PlayerInput( float DeltaTime )
{
	local float FOVScale, TimeScale;

	bEnableMouseSmoothing  = True;
	
	// ROB TESTING:  CANCEL MOUSE TURN
	aMouseX =  0.f;
	aTurn = 0.f;

	
	// Save Raw values
	RawJoyUp		= aBaseY;
	RawJoyRight		= aStrafe;
	RawJoyLookRight	= aTurn;
	RawJoyLookUp	= aLookUp;
	
	// PlayerInput shouldn't take timedilation into account
	DeltaTime /= WorldInfo.TimeDilation;
	if (Outer.bDemoOwner && WorldInfo.NetMode == NM_Client)
	{
		DeltaTime /= WorldInfo.DemoPlayTimeDilation;
	}

	PreProcessInput( DeltaTime );

	// Scale to game speed
	TimeScale = 100.f*DeltaTime;
	aBaseY		*= TimeScale * MoveForwardSpeed;
	aStrafe		*= TimeScale * MoveStrafeSpeed;
	aUp			*= TimeScale * MoveStrafeSpeed;
	aTurn		*= TimeScale * LookRightScale;
	aLookUp		*= TimeScale * LookUpScale;

	PostProcessInput( DeltaTime );

	ProcessInputMatching(DeltaTime);

	// Check for Double click movement.
	CatchDoubleClickInput();

	// Take FOV into account (lower FOV == less sensitivity).

	if ( bEnableFOVScaling )
	{
		FOVScale = GetFOVAngle() * 0.01111; // 0.01111 = 1 / 90.0
	}
	else
	{
		FOVScale = 1.0;
	}

	AdjustMouseSensitivity(FOVScale);

	// mouse smoothing
	if ( bEnableMouseSmoothing )
	{
		aMouseX = SmoothMouse(aMouseX, DeltaTime,bXAxis,0);
		aMouseY = SmoothMouse(aMouseY, DeltaTime,bYAxis,1);
	}

	aLookUp			*= FOVScale;
	aTurn			*= FOVScale;

	// Turning and strafing share the same axis.
	if( bStrafe > 0 )
		aStrafe		+= aBaseX + aMouseX;
	else
		aTurn		+= aBaseX + aMouseX;

	// Look up/down.
	aLookup += aMouseY;
	if (bInvertMouse)
	{
		aLookup *= -1.f;
	}

	if (bInvertTurn)
	{
		aTurn *= -1.f;
	}

	// Forward/ backward movement
	aForward		+= aBaseY;

	// Handle walking.
	HandleWalking();

	// check for turn locking
	if (bLockTurnUntilRelease)
	{
		if (RawJoyLookRight != 0)
		{
			aTurn = 0.f;
			if (AutoUnlockTurnTime > 0.f)
			{
				AutoUnlockTurnTime -= DeltaTime;
				if (AutoUnlockTurnTime < 0.f)
				{
					bLockTurnUntilRelease = FALSE;
				}
			}
		}
		else
		{
			bLockTurnUntilRelease = FALSE;
		}
	}

	// ignore move input
	// Do not clear RawJoy flags, as we still want to be able to read input.
	if( IsMoveInputIgnored() )
	{
		aForward	= 0.f;
		aStrafe		= 0.f;
		aUp			= 0.f;
	}

	// ignore look input
	// Do not clear RawJoy flags, as we still want to be able to read input.
	if( IsLookInputIgnored() )
	{
		aTurn		= 0.f;
		aLookup		= 0.f;
	}

}

 */

 defaultproperties
{
//    MouseSamplingTotal=+0.0083
//	MouseSamples=1

//    MouseSamplingTotal=+0.83
//	MouseSamples=1000
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

