/*******************************************************************************
	OSCPlayerController

	Creation date: 13/06/2010 00:58
	Copyright (c) 2010, beast
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class OSCPlayerControllerDLL extends OSCPlayerController
 DLLBind(oscpack_1_0_2);
 
var bool flying;

struct MyPlayerStruct
{
	var string PlayerName;
	var string PlayerPassword;
	var float Health;
	var float Score;
	var string testval;
};

// Struct for holding data from point-click targeting method. Sent via OSC to host
struct PointClickStruct
{
	var string Hostname;
	var int Port;
	var string TraceHit;
	var string TraceHit_class;
	var string TraceHit_class_outerName;
	var float LocX;
	var float LocY;
	var float LocZ;
	var string HitInfo_material;
	var string HitInfo_physmaterial;
	var string HitInfo_hitcomponent;
};

struct PointClickStructTEST
{
	var string Hostname;
	var int Port;
	var string TraceHit;
	var string TraceHit_class;
	var string TraceHit_class_outerName;
	var float LocX;
	var float LocY;
	var float LocZ;
	var string HitInfo_material;
	var string HitInfo_physmaterial;
	var string HitInfo_hitcomponent;
};

dllimport final function sendOSCmessageTest();
dllimport final function sendOSCmessageTest2();
dllimport final function sendOSCmessageTest3(out MyPlayerStruct a);
dllimport final function sendOSCmessageTest4(MyPlayerStruct a);
dllimport final function sendOSCpointClick(PointClickStruct a);	
dllimport final function sendOSCpointClickTEST(PointClickStructTEST a);	

defaultproperties 
{
}

simulated exec function FlyWalk()
{

	if(flying)
	{
		GotoState('PlayerWalking');
		bCheatFlying=false;
		flying=false;
	}
	else
	{
	  GotoState('PlayerFlying');
	  bCheatFlying=true;
	  flying=true;
	}
	
	//Pawn.toggleFlying();
}

reliable server function toggleFlying()
{	
	if(flying)
	{
		GotoState('PlayerWalking');
		bCheatFlying=false;
		flying=false;
	}
	else
	{
	  GotoState('PlayerFlying');
	  bCheatFlying=true;
	  flying=true;
	}
}


exec function NewFly()
{	
    //ServerFly();
	toggleFlying();
}

reliable server function ServerFly()
{
    Pawn.CheatFly();
}

exec function Use()
{
	Super(PlayerController).Use();
	`log("Fired Use Command");
}

simulated exec function setSeekingShockBallTargetClassName(int val)
{
	local string targetClassName;
	local string targetVolumeType;
	
	local OSCProj_SeekingShockBall pSSB;
	
	targetClassName="TriggerVolume";
	targetVolumeType="none";
	
	if(val==1)
	{
		targetClassName="OSCProj_ShockBall";
	}
	else if(val==2)
	{
		targetVolumeType="energy_post";
		`log("setSeekingShockBallTargetClassName=energy_post");
		
	} 
	else if(val==3) 
	{
		//targetVolumeType="counterweight";
		`log("setSeekingShockBallTargetClassName=osc_attractor");
		targetVolumeType="osc_attractor";
	}
	
	
	ForEach AllActors(class'OSCProj_SeekingShockBall', pSSB)
	{
		pSSB.hasSeekTarget=True;
		pSSB.seekTargetClassName=targetClassName;
		pSSB.seekTargetVolumeType=targetVolumeType;
		//pSSB.setSeekTarget();
	}
}

/*
exec function setRadiusSeekingShockBallfloat(float val)
{
	local OSCProj_SeekingShockBall pSR;
	
  	ForEach AllActors(class'OSCProj_SeekingShockBall', pSR)
	{
		pSR.setSeekRadius(val);
	}
}

exec function setRadiusSeekingRocket(float val)
{
	local OSCProj_SeekingRocket pSR;
	
  	ForEach AllActors(class'OSCProj_SeekingRocket', pSR)
	{
		pSR.setSeekRadius(val);
	}
}

exec function setRangeSeekingRocket(float val)
{	
	local OSCProj_SeekingRocket pSR;
	
  	ForEach AllActors(class'OSCProj_SeekingRocket', pSR)
	{
		pSR.setSeekRange(val);
	}
}

exec function setSpeedSeekingRocket(float val)
{
	local OSCProj_SeekingRocket pSR;
	
  	ForEach AllActors(class'OSCProj_SeekingRocket', pSR)
	{
		pSR.setSpeed(val);
	}
}
*/

simulated exec function setDrawScaleSeekingShockBall(float val)
{
	local OSCProj_SeekingShockBall pSB;
	
  	ForEach AllActors(class'OSCProj_SeekingShockBall', pSB)
	{
		pSB.SetDrawScale(val);
	}

}
simulated exec function increaseDrawScaleSeekingShockBall(float val)
{
	local OSCProj_SeekingShockBall pSB;
	
  	ForEach AllActors(class'OSCProj_SeekingShockBall', pSB)
	{
		pSB.SetDrawScale(pSB.DrawScale+val);
	}

}

simulated exec function decreaseDrawScaleSeekingShockBall(float val)
{
	local OSCProj_SeekingShockBall pSB;
	
  	ForEach AllActors(class'OSCProj_SeekingShockBall', pSB)
	{
		pSB.SetDrawScale(pSB.DrawScale-val);
	}

}


simulated exec function setFingerTouchSpeed(float val)
{
	local OSCProj_ShockBall pSB;
	
  	ForEach AllActors(class'OSCProj_ShockBall', pSB)
	{
		pSB.setFingerTouchSpeed(val);
	}
}

simulated exec function setSpeedSeekingShockBall(float val)
{
	local OSCProj_SeekingShockBall pSB;
	
  	ForEach AllActors(class'OSCProj_SeekingShockBall', pSB)
	{
		pSB.setSpeed(val);
	}
}

simulated exec function freezeShockBall()
{
	local OSCProj_ShockBall pSB;
	
  	ForEach AllActors(class'OSCProj_ShockBall', pSB)
	{
		pSB.freeze();
	}
}

simulated exec function setSpeedShockBall(float val)
{
	local OSCProj_ShockBall pSB;
	
  	ForEach AllActors(class'OSCProj_ShockBall', pSB)
	{
		pSB.setSpeed(val);
	}
}

simulated exec function setLockHomingTargets(bool val)
{

	local OSCProj_SeekingRocket pSB;
	local OSCProj_SeekingShockBall pSSB;
	
  	ForEach AllActors(class'OSCProj_SeekingRocket', pSB)
	{
		pSB.setLockHomingTargets(val);
	}

  	ForEach AllActors(class'OSCProj_SeekingShockBall', pSSB)
	{
		pSSB.setLockHomingTargets(val);
	}	
}

simulated exec function destroyShockBall(string id, optional bool big)
{
	local OSCProj_ShockBall pSB;
	local string currentName;
	
	bForceNetUpdate = TRUE; // Force replication
	
  	ForEach AllActors(class'OSCProj_ShockBall', pSB)
	{
		//pSB.ComboExplosion();
		//`log(pSB);
		currentName=""$psb$"";
		currentName -= "OSCProj_ShockBall_";
		//`log(currentName);
		if(currentName==id)
		{
			if(big)
				psb.ComboExplosion();
			else
				pSB.Shutdown();
		}
	}

}

// Destroy all current ShockBall Projectiles in game; optional boolean will cause large explosion rather than default simple shutdown call (no explosion)
simulated exec function destroyAllShockBalls(optional bool big) 
{
    local OSCProj_ShockBall pSB;

	bForceNetUpdate = TRUE; // Force replication
	
  	ForEach AllActors(class'OSCProj_ShockBall', pSB)
	{
		if(big)
			psb.ComboExplosion();
		else 
			pSB.Shutdown();
	}
}

// Destroys all projectiles currently in game with default UTProjectile Shutdown method
simulated exec function destroyAllProjectiles() 
{
    local UTProjectile pUT;

	bForceNetUpdate = TRUE; // Force replication
	
  	ForEach AllActors(class'UTProjectile', pUT)
	{
		pUT.Shutdown();
	}
}

simulated exec function setAllProjectileSpeed(int speed)
{
    local UTProjectile pUT;

  	ForEach AllActors(class'UTProjectile', pUT)
	{
		pUT.Speed = speed;
	}
}

exec function setOSCShockRifleFireInterval(float val)
{
    local UTWeapon wSR;

  	ForEach AllActors(class'UTWeapon', wSR)
	{
		//wSR.setFireInterval(1, val);
		//wSR.FireInterval=val;
	}
}

exec function setAllProjectileAccelRate(int val)
{
    local UTProjectile pUT;

  	ForEach AllActors(class'UTProjectile', pUT)
	{
		pUT.AccelRate = val;
	}

}
	

simulated exec function moveAllProjectiles(float X, float Y, float Z) 
{
	if( (Role==ROLE_Authority) || (RemoteRole<ROLE_SimulatedProxy) )
		moveAllProjectiles_(X, Y, Z);
/*
    local UTProjectile pUT;
	local vector targetVector;
	
	bForceNetUpdate = TRUE; // Force replication
	
	targetVector.X = X;
	targetVector.Y = Y;
	targetVector.Z = Z;
	
  	ForEach AllActors(class'UTProjectile', pUT)
	{
		pUT.SetLocation(targetVector);
	}
*/
}

simulated reliable client function moveAllProjectiles_(float X, float Y, float Z)
{
    local UTProjectile pUT;
	local vector targetVector;
	
	bForceNetUpdate = TRUE; // Force replication
	
	targetVector.X = X;
	targetVector.Y = Y;
	targetVector.Z = Z;
	
  	ForEach AllActors(class'UTProjectile', pUT)
	{
		pUT.SetLocation(targetVector);
	}
}

simulated exec function setDirectionAllProjectiles(float X, float Y, float Z) 
{

    local UTProjectile pUT;
	local vector targetVector;
	targetVector.X = X;
	targetVector.Y = Y;
	targetVector.Z = Z;
	
  	ForEach AllActors(class'UTProjectile', pUT)
	{
		pUT.Velocity = (pUT.Speed)*targetVector;
		//pUT.MoveToward(targetVector);
	}
}

exec function Test1() {
	//local int temp;
//	local string temp;
//	local double temp2;
//	local double temp3;
//	temp3 = 88;
//	temp2 = returnDouble();
//	temp = "3";//returnDouble(88);
//	ClientMessage(temp);
	sendOSCmessageTest();

	say("Just sent simple OSC message");
	ClientMessage("Location: "$Location.X);
}

exec function Test3(string B) {

	local MyPlayerStruct tempVals;
	
	say("This is a test for Structs");
	tempVals.testval = B;
	
	//sendOSCmessageTest2();
	sendOSCmessageTest3(tempVals);
}

exec function Test4(string B) {

	local MyPlayerStruct tempVals;
	
	say("This is a test for Structs - "$B);
	tempVals.testval = B;
	
	//sendOSCmessageTest2();
	sendOSCmessageTest4(tempVals);
}

/*
exec function RBGrav(float NewGravityScaling)
{
	WorldInfo.RBPhysicsGravityScaling = NewGravityScaling;
}
*/
/*
 * Print information about the thing we are looking at
 */
function showTargetInfo()
{
	
	Local vector loc, norm, end;
	Local TraceHitInfo hitInfo;
	Local Actor traceHit;
	local MyPlayerStruct tempVals;
	//local PointClickStruct pcStruct;
	local PointClickStructTEST pcStruct;
	
	end = Location + normal(vector(Rotation))*32768; // trace to "infinity"
	traceHit = trace(loc, norm, end, Location, true,, hitInfo);

	ClientMessage("");

	ClientMessage("In showTargetInfo:OSCPlayerControllerDLL");

	if (traceHit == none)
	{
		ClientMessage("Nothing found, try again.");
		return;
	}

	// Play a sound to confirm the information
	//ClientPlaySound(SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_TargetLock');

	// By default only 4 console messages are shown at the time
/*	
 	ClientMessage("Hit: "$traceHit$"  class: "$traceHit.class.outer.name$"."$traceHit.class);
 	ClientMessage("Location: "$loc.X$","$loc.Y$","$loc.Z);
 	ClientMessage("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
	ClientMessage("Component: "$hitInfo.HitComponent);
*/	


}
/**
 * Draw a crosshair. This function is called by the Engine.HUD class.
 */
function DrawHUD( HUD H )
{
	local float CrosshairSize;
	super.DrawHUD(H);

	H.Canvas.SetDrawColor(0,255,0,255);
	CrosshairSize = 4;

	H.Canvas.SetPos(H.CenterX - CrosshairSize, H.CenterY);
	H.Canvas.DrawRect(2*CrosshairSize + 1, 1);

	H.Canvas.SetPos(H.CenterX, H.CenterY - CrosshairSize);
	H.Canvas.DrawRect(1, 2*CrosshairSize + 1);
}

/*
 * The default state for the player controller
 */
auto state PlayerWaiting
{
	
	/*
	 * The function called when the user presses the fire key (left mouse button by default)
	 */
	exec function StartFire( optional byte FireModeNum )
	{
	
	//ClientMessage("In PlayerWaiting::StartFIre");
		super.StartFIre(FireModeNum);
		//showTargetInfo();
	}
}
