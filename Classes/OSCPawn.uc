/*******************************************************************************
	OSCPawn

	Creation date: 13/06/2010 01:00
	Copyright (c) 2010, beast
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class OSCPawn extends UTPawn
 notplaceable
 DLLBind(oscpack_1_0_2);

 // vars for moving trumbruticus trunk in code
var(NPC) SkeletalMeshComponent CurrentMesh;
var SkelControl_CCD_IK TrunkMover;

// state bools for skeletal mesh changing
var bool isValkordia;
var bool isTrumbruticus;

// test vars for camera offsets
var int camoffsetx, camoffsety, camoffsetz;

// toggles and vars for side and down traces
var bool pawnDowntrace;
var bool pawnSidetrace;
var int gtracelength;
var int gdowntracelength;
var float gLeftTrace;
var float gRightTrace;
var float gDownTrace;
var int gtesttrace;

/**/
// OSC Mode value for toggling pawn and controller modes
var int gOSCMode;

// Pawn's unique ID
var int uid;

var bool sendingOSC;	// toggle to send OSC for this pawn
var bool receivingOSC; 	// receiving OSC flag to prevent multiple calls to oscpack to instantiate listener threads
var bool sendDeltaOSC; // whether OSC messages are sent continuously or only on vector deltas

// Old iPad finger-touch code
var array<vector> fingerTouchArray;
var vector object1;
var vector object2;
var vector object3;
var vector object4;
var vector object5;

// vals for setting offsets and min/max for incoming XYZ co-ords
var vector OSCFingerOffsets;
var vector OSCFingerWorldMin;
var vector OSCFIngerWorldMax;
var vector OSCFingerSourceMax;
var vector OSCFingerSourceMin;
var bool OSCUseFingerTouches;
var int currentFingerTouches[5];
		
var float lastX;
var float lastY;
var float lastZ;
var bool lastCrouch;
var bool isCrouching;

var float seekingTurnRate;

var vector	OSCCamera;
var bool OSCFreeCamera;				// OSC Controlled Free-moving camera, not attached to Pawn
var bool OSCAttachedCamera;			// OSC Controlled rotating camera attached to Pawn

// testing
var Rotator OSCRotation;

struct MyPlayerStruct
{
	var string PlayerName;
	var string PlayerPassword;
	var float Health;
	var float Score;
	var string testval;
};

struct PlayerStateStruct_works
{
	var string Hostname;
	var int Port;
	var string PlayerName;
	var float LocX;
	var float LocY;
	var float LocZ;
	var bool crouch;
};

// Adding LookPitch... etc to track pawn view to pass for binaural testing
struct PlayerStateStruct
{
	var string Hostname;
	var int Port;
	var string PlayerName;
	var float LocX;
	var float LocY;
	var float LocZ;
	var bool crouch;
	var float Pitch;
	var float Yaw;
	var float Roll;
	var float leftTrace;
	var float rightTrace;
	var float downTrace;
};

struct PlayerStateStructTEST
{
	var string Hostname;
	var int Port;
	var string PlayerName;
	var float LocX;
	var float LocY;
	var float LocZ;
	var bool crouch;
};

struct OSCFingerController
{
	var float f1X;
	var float f1Y;
	var float f1Z;
	var float f1on;
	var float f2X;
	var float f2Y;
	var float f2Z;
	var float f2on;	
	var float f3X;
	var float f3Y;
	var float f3Z;
	var float f3on;	
	var float f4X;
	var float f4Y;
	var float f4Z;
	var float f4on;	
	var float f5X;
	var float f5Y;
	var float f5Z;
	var float f5on;	
};

struct OSCFingerMessageStruct
{
	var int fingerCount;
	var float X;
	var float Y;
	var float Z;
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

struct OSCMessageStruct
{
	var float test;
};

struct OSCGameParams
{
	var float gameGravity;
	var float gameSpeed;
};

struct OSCScriptPlayerRotationStruct
{
	var float pitch;
	var float yaw;
	var float roll;
};

// OSC Camera data from Playercontroller
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

// OSC Camera data from Playercontroller
var OSCScriptCameramoveStruct localOSCScriptCameramoveStruct;

//Global vars for this class
var OSCScriptPlayerRotationStruct localOSCScriptPlayerRotationStruct;
var OSCMessageStruct localOSCMessageStruct;
var OSCGameParams localOSCGameParamsStruct;
var OSCFingerController localOSCFingerControllerStruct;
var float lastGameGravity;
var float lastGameSpeed;


var OSCParams OSCParameters;
var string OSCHostname;
var int OSCPort;

dllimport final function sendOSCpointClick(PointClickStruct a);	
dllimport final function sendOSCPlayerState(PlayerStateStruct a);
dllimport final function OSCMessageStruct getOSCTest();
dllimport final function OSCGameParams getOSCGameParams();
dllimport final function float getOSCGameSpeed();
dllimport final function float getOSCGameGravity();
dllimport final function float getOSCTestfloat();
dllimport final function OSCFingerController getOSCFingerController();
dllimport final function vector getOSCFinger1();
dllimport final function initOSCReceiver();
dllimport final function OSCScriptPlayerRotationStruct getOSCScriptPlayerRotation();

//dllimport final function sendOSCPlayerStateTEST(PlayerStateStructTEST a);
//dllimport final function sendMotionState(string currState, vector loc);
//override to do nothing
//simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
//{
//}

//var AnimNodeBlend ThrottleBlendNode;
//simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
//{
//    super.PostInitAnimTree(SkelComp);
// 
//    if (SkelComp == Mesh)
//    {
//        ThrottleBlendNode = AnimNodeBlend(Mesh.FindAnimNode('Throttle Blend'));
//    }
//}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	
	// For Trumbruticus trunk moving demo
	//TrunkMover = SkelControl_CCD_IK(Mesh.FindSkelControl('TrunkMover'));
}

simulated exec function ChangePlayerMesh(float a)
{
	local AnimNode temp;

	if(a==1)
	{
		self.Mesh.SetSkeletalMesh(SkeletalMesh'thesis_characters.trumbruticus.CHA_trumbruticus_skel_01');
		self.Mesh.SetPhysicsAsset(PhysicsAsset'thesis_characters.trumbruticus.CHA_trumbruticus_skel_01_Physics');
		self.Mesh.AnimSets[0]=AnimSet'thesis_characters.trumbruticus.CHA_trumbruticus_skel_01_Anims';
		self.Mesh.SetAnimTreeTemplate(AnimTree'thesis_characters.trumbruticus.CHA_trumbruticus_AnimTree_spawntest');

		//self.Mesh.GlobalAnimRateScale=self.GroundSpeed/440.0;
		//`log("Groundspeed = "$self.GroundSpeed);
		
		//Pawn.GroundSpeed
		isValkordia=false;
		isTrumbruticus=true;
		
		} else if(a==2) {
		self.Mesh.SetSkeletalMesh(SkeletalMesh'thesis_characters.valkordia.CHA_valkordia_skel_01');
		self.Mesh.SetPhysicsAsset(PhysicsAsset'thesis_characters.valkordia.CHA_valkordia_skel_01_Physics');
		self.Mesh.AnimSets[0]=AnimSet'thesis_characters.valkordia.CHA_valkordia_skel_01_Anims';
		self.Mesh.SetAnimTreeTemplate(AnimTree'thesis_characters.valkordia.CHA_valkordia_AnimTree_01');	
		
		 // Search for the animation node blend list by name.
		//temp = self.Mesh.FindAnimNode('UDKAnimBlendByFlying');
		
		isValkordia=true;
		isTrumbruticus=false;
		
	} else if(a==3) {	
		self.Mesh.SetSkeletalMesh(SkeletalMesh'CH_LIAM_Cathode.Mesh.SK_CH_LIAM_Cathode');
		self.Mesh.SetPhysicsAsset(PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics');
		self.Mesh.AnimSets[0]=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale';
		self.Mesh.SetAnimTreeTemplate(AnimTree'CH_AnimHuman_Tree.AT_CH_Human');
		
		isValkordia=false;
		isTrumbruticus=false;
		
	} else if(a==4) {
		self.Mesh.SetSkeletalMesh(SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA');
		self.Mesh.SetPhysicsAsset(PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics');
		self.Mesh.AnimSets[0]=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale';
		self.Mesh.SetAnimTreeTemplate(AnimTree'CH_AnimHuman_Tree.AT_CH_Human');
		
		isValkordia=false;
		isTrumbruticus=false;
	} else if(a==5) {
	
		self.Mesh.SetSkeletalMesh(SkeletalMesh'thesis_characters.Test.test_trumbruticus_skel_01');
		self.Mesh.SetPhysicsAsset(PhysicsAsset'thesis_characters.Test.test_trumbruticus_skel_01_Physics');
		self.Mesh.AnimSets[0]=AnimSet'thesis_characters.Test.test_trumbruticus_skel_01_Anims';
		self.Mesh.SetAnimTreeTemplate(AnimTree'thesis_characters.Test.test_trumbruticus_AnimTree_spawntest');

		isValkordia=false;
		isTrumbruticus=false;		
	}
}

simulated exec function setEyeHeight(float X)
{
  BaseEyeheight=X;
}

simulated exec function setOSCFingerOffsets(float X, float Y, float Z)
{
	OSCFingerOffsets.X=X;
	OSCFingerOffsets.Y=Y;
	OSCFingerOffsets.Z=Z;
}

simulated exec function setOSCFingerWorldMin(float X, float Y, float Z)
{
	OSCFingerWorldMin.X = X;
	OSCFingerWorldMin.Y = Y;
	OSCFingerWorldMin.Z = Z;
}

simulated exec function setOSCFingerWorldMax(float X, float Y, float Z)
{
	OSCFingerWorldMax.X = X;
	OSCFingerWorldMax.Y = Y;
	OSCFingerWorldMax.Z = Z;
}

simulated exec function setOSCFingerSourceMax(float X, float Y, float Z)
{
	OSCFingerSourceMax.X = X;
	OSCFingerSourceMax.Y = Y;
	OSCFingerSourceMax.Z = Z;
}

simulated exec function setOSCFingerSourceMin(float X, float Y, float Z)
{
	OSCFingerSourceMin.X = X;
	OSCFingerSourceMin.Y = Y;
	OSCFingerSourceMin.Z = Z;
}

simulated function vector getScaledFingerTouch(int fingerTouch)
{
	local vector scaledFingerTouch;
// for iPad
// x range = 0 to 320
// y range = 0 to 420
// finger touch ~ 7 to 20
//	`log("OSCFingerSourceMin: "$OSCFingerSourceMin);
//	`log("OSCFingerSourceMax: "$OSCFingerSourceMax);
//	`log("OSCFingerWorldMax: "$OSCFingerWorldMax);
//	`log("OSCFingerWorldMin: "$OSCFingerWorldMin);
	
	scaledFingerTouch.X = scaleRange( fingerTouchArray[fingerTouch].X, OSCFingerSourceMin.X, OSCFingerSourceMax.X, OSCFingerWorldMin.X, OSCFingerWorldMax.X);
	scaledFingerTouch.Y = scaleRange( fingerTouchArray[fingerTouch].Y, OSCFingerSourceMin.Y, OSCFingerSourceMax.Y, OSCFingerWorldMin.Y, OSCFingerWorldMax.Y);
	scaledFingerTouch.Z = scaleRange( fingerTouchArray[fingerTouch].Z, OSCFingerSourceMin.Z, OSCFingerSourceMax.Z, OSCFingerWorldMin.Z, OSCFingerWorldMax.Z);
	
	return scaledFingerTouch;
}

simulated function float scaleRange(float in, float oldMin, float oldMax, float newMin, float newMax)
{
	return ( in / ((oldMax - oldMin) / (newMax - newMin))) + newMin;
}

simulated exec function setSeekingTurnRate(float val)
{
	//`log("seekingTurnRate was now "$seekingTurnRate);
	seekingTurnRate=val;
	//`log("seekingTurnRate is now "$seekingTurnRate);
}

simulated function float getSeekingTurnRate()
{
	//ClientMessage("seekingTurnRate value: "$seekingTurnRate);
	return seekingTurnRate;
}

simulated exec function initOSCFingerTouches(bool val)
{
	OSCUseFingerTouches=val;
}

simulated exec function getOSCFingerTouches()
{
	ClientMessage("Current OSC FingerTouches value: "$OSCUseFingerTouches);
}

simulated exec function getOSCHostname()
{
	ClientMessage("Current OSC Hostname value: "$OSCParameters.getOSCHostname());
}

simulated exec function getOSCPort()
{
	ClientMessage("Current OSC Port value: "$OSCParameters.getOSCPort());
}

simulated exec function getOSC()
{
	ClientMessage("Current OSC Hostname::Port values: "$OSCParameters.getOSCHostname()$"::"$OSCParameters.getOSCPort());
}

simulated exec function setOSCHostname(string hostname)
{
	OSCParameters.setOSCHostname(hostname);
}

simulated exec function setOSCPort(int port)
{
	OSCParameters.setOSCPort(port);
}

simulated exec function setOSC(string hostname, int port)
{
	OSCParameters.setOSCHostname(hostname);
	OSCParameters.setOSCPort(port);
}

simulated exec function getAirSpeed()
{
	ClientMessage("AirSpeed: "$AirSpeed);
}

simulated exec function setAirSPeed(float as)
{
	AirSpeed=as;
}

simulated exec function getGroundSpeed()
{
	ClientMessage("GroundSpeed: "$groundspeed);
}

simulated exec function setGroundSpeed(float gs)
{
	groundspeed=gs;
}

simulated event PreBeginPlay()
{
	Super.PreBeginPlay();
	
	OSCParameters = spawn(class'OSCParams');	
	OSCHostname = OSCParameters.getOSCHostname();
	OSCPort = OSCParameters.getOSCPort();	

	object1.X=0;
	object1.Y=0;
	object1.Z=0;
	object2.X=0;
	object2.Y=0;
	object2.Z=0;
	object3.X=0;
	object3.Y=0;
	object3.Z=0;
	object4.X=0;
	object4.Y=0;
	object4.Z=0;
	object5.X=0;
	object5.Y=0;
	object5.Z=0;
	
	fingerTouchArray[0]=object1;
	fingerTouchArray[1]=object2;
	fingerTouchArray[2]=object3;
	fingerTouchArray[3]=object4;
	fingerTouchArray[4]=object5;
	
	OSCFingerSourceMax = vect(320.00000, 420.00000, 20.00000);
	OSCFingerSourceMin = vect(0.00001, 0.00001, 7.40000);
	OSCFingerWorldMax = vect(2000.00000, 2000.00000, 2300.00000);
	OSCFingerWorldMin = vect(-2000.00000, -2000.00000, 0.00001);
	OSCFingerOffsets = vect(-160.00000, -210.00000, 0.00001);	
}

// Overloading FaceRotation from UTPawn to let pawn pitch follow camera
simulated function FaceRotation(rotator NewRotation, float DeltaTime)
{
	if ( Physics == PHYS_Ladder )
	{
		NewRotation = OnLadder.Walldir;
	}
	else if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
	{
		//NewRotation.Pitch = 0;
	}

	if(OSCFreeCamera || OSCAttachedCamera)
	{
			SetRotation(NewRotation);	
	} else {
		//NewRotation.Roll = Rotation.Roll;
		//NewRotation.Pitch = Rotation.Pitch;
		
		SetRotation(NewRotation);	
	}
}

simulated function sendPlayerState()
{
	
	Local vector loc, norm, end;
	Local TraceHitInfo hitInfo;
	Local Actor traceHit;
	local MyPlayerStruct tempVals;
	local PlayerStateStruct psStruct;
	local bool sendOSC;
	local Rotator viewrotator;

	end = Location + normal(vector(Rotation))*32768; // trace to "infinity"
	traceHit = trace(loc, norm, end, Location, true,, hitInfo);
	
	// Populate pcStruct with tracehit info using rkh String format hack
	psStruct.PlayerName ="bob";
	psStruct.LocX = Location.X;
	psStruct.LocY = Location.Y;
	psStruct.LocZ = Location.Z;
	psStruct.Crouch = isCrouching;
    
	psStruct.leftTrace = gLeftTrace;
	psStruct.rightTrace = gRightTrace;
	psStruct.downTrace = gDownTrace;
	
	// adding rotation to the player output call
	psStruct.Yaw = Rotation.Yaw%65535;

    // get view rotation for Pitch for osc output
	viewrotator = GetViewRotation();	
	psStruct.Pitch = viewrotator.Pitch%65535;
	psStruct.Roll = Rotation.Roll%65535;

	OSCHostname = OSCParameters.getOSCHostname();
	OSCPort = OSCParameters.getOSCPort();

	psStruct.Hostname = OSCParameters.getOSCHostname();
	psStruct.Port = OSCParameters.getOSCPort();

	sendOSC=true;

	// only send OSC if nothing has changed (XYZ or crouch)
	if(sendDeltaOSC) {
		if( (Location.X == lastX) && (Location.Y == lastY) && (Location.Z == lastZ) && (isCrouching==lastCrouch))
			sendOSC=false;
	}

	if(sendOSC)
		sendOSCPlayerState(psStruct);

	// update last xyz coordinates
	lastX = Location.X;
	lastY = Location.Y;
	lastZ = Location.Z;
	lastCrouch = isCrouching;
	
}

function showTargetInfo()
{
	
	Local vector loc, norm, end;
	Local TraceHitInfo hitInfo;
	Local Actor traceHit;
	local MyPlayerStruct tempVals;
	local PointClickStruct pcStruct;
	
	end = Location + normal(vector(Rotation))*32768; // trace to "infinity"
	traceHit = trace(loc, norm, end, Location, true,, hitInfo);

	ClientMessage("");
	ClientMessage("In showTargetInfo: oscpawn.");

	if (traceHit == none)
	{
		ClientMessage("Nothing found, try again.");
		return;
	}

	// Play a sound to confirm the information
	//ClientPlaySound(SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_TargetLock');

	// By default only 4 console messages are shown at the time
 	ClientMessage("Hit: "$traceHit$"  class: "$traceHit$"."$traceHit.class);
 	ClientMessage("Location: "$loc.X$","$loc.Y$","$loc.Z);
 	ClientMessage("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
	ClientMessage("Component: "$hitInfo.HitComponent);
	
	// Populate pcStruct with tracehit info using rkh String format hack
	pcStruct.TraceHit = ""$traceHit$"";
	pcStruct.TraceHit_class = ""$traceHit.class$"";
	pcStruct.TraceHit_class_outerName = ""$traceHit.class.outer.name$"";
	pcStruct.LocX = loc.X;
	pcStruct.LocY = loc.Y;
	pcStruct.LocZ = loc.Z;
	pcStruct.HitInfo_material = ""$hitInfo.Material$"";
	pcStruct.HitInfo_physmaterial = ""$hitInfo.PhysMaterial$"";
	pcStruct.HitInfo_hitcomponent = ""$hitInfo.HitComponent$"";

	
	
	sendOSCPointClick(pcStruct);
}

//function showHitLocation(vector HitLocation)
simulated function showHitLocation()
{

	Local vector loc, norm, end;
	Local TraceHitInfo hitInfo;
	Local Actor traceHit;
	local MyPlayerStruct tempVals;
	local PointClickStruct pcStruct;
	
	end = Location + normal(vector(Rotation))*32768; // trace to "infinity"
	traceHit = trace(loc, norm, end, Location, true,, hitInfo);

	ClientMessage("");

	ClientMessage("In showhitlocation: oscpawn.");

	if (traceHit == none)
	{
		ClientMessage("Nothing found, try again.");
		return;
	}

	// Play a sound to confirm the information
	//ClientPlaySound(SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_TargetLock');

	// By default only 4 console messages are shown at the time
 	ClientMessage("Hit: "$traceHit$"  class: "$traceHit.class.outer.name$"."$traceHit.class);
 	//ClientMessage("HitLocation: "$tracehit.Location.X$", "$tracehit.Location.Y$", "$tracehit.Location.Z$"");//$HitLocation.X$","$HitLocation.Y$","$HitLocation.Z);
 	ClientMessage("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
	ClientMessage("Component: "$hitInfo.HitComponent);
	/*
	// Populate pcStruct with tracehit info using rkh String format hack
	pcStruct.TraceHit = ""$traceHit$"";
	pcStruct.TraceHit_class = ""$traceHit.class$"";
	pcStruct.TraceHit_class_outerName = ""$traceHit.class.outer.name$"";
	pcStruct.LocX = HitLocation.X;
	pcStruct.LocY = HitLocation.Y;
	pcStruct.LocZ = HitLocation.Z;
	pcStruct.HitInfo_material = ""$hitInfo.Material$"";
	pcStruct.HitInfo_physmaterial = ""$hitInfo.PhysMaterial$"";
	pcStruct.HitInfo_hitcomponent = ""$hitInfo.HitComponent$"";
*/
	setProjectileTargets(Loc.X, Loc.Y, Loc.Z);
	//setProjectileTargets(tracehit.Location.X, tracehit.Location.Y, tracehit.Location.Z);
	`log("SEnding target location:"$loc.X$","$loc.Y$","$loc.Z);
//	sendOSCPointClick(pcStruct);
}



simulated function StartFire(byte FireModeNum)
{

	Super.StartFire(FireModeNum);
	if(FireModeNum==0)
	{
		showHitLocation();
	}

}

simulated exec function OSCStartInput() {

	`log("Initializing OSC Input...");
	if(!receivingOSC) 
	{
		initOSCReceiver();
		receivingOSC=True;
	}
}

simulated exec function OSCStartOutput() {
	`log("Initializing OSC Output...");
	sendingOSC = true;
}

simulated exec function OSCStopOutput() {
	`log("stopping OSC Output...");
	sendingOSC = false;
}

// Toggle whether OSC sends in continuous mode or only on Deltas
simulated exec function OSCSendDeltas() {
	if(sendDeltaOSC) {
	   sendDeltaOSC=false;
	} else {
		sendDeltaOSC=true;
	}
}

simulated event StartCrouch(float HeightAdjust)
{
	Super.StartCrouch(HeightAdjust);
	
	//if(sendingOSC)
		//showTargetInfo();
	
	isCrouching=true;
	
}

simulated event EndCrouch(float HeightAdjust)
{
	Super.EndCrouch(HeightAdjust);
	isCrouching=false;
}


simulated exec function setGrav(float val)
{
//	`log("setting WorldGravitzZ from: "$WorldInfo.WorldGravityZ);
`log("Setting Grav: "$val);
	WorldInfo.WorldGravityZ=val-500.0;
}

simulated function TakeFallingDamage() {

}


simulated exec function setGameSpeed(float val)
{
`log("Setting Game Speed: "$val);
	WorldInfo.Game.SetGameSpeed(val);
}

simulated function getOSCFingerData()
{
	local vector vals;
	vals = getOSCFinger1();
	`log("vals: "$vals);
	
}


simulated function setOSCFingerTouches(OSCFingerController fstruct)
{

	//`log("in setOSCFingerTouches");
	//`log("fstruct = "$fstruct.f1X);

	currentFingerTouches[0]=fstruct.f1on;
	currentFingerTouches[1]=fstruct.f2on;
	currentFingerTouches[2]=fstruct.f3on;
	currentFingerTouches[3]=fstruct.f4on;
	currentFingerTouches[4]=fstruct.f5on;
	
	if(fstruct.f1on>0.0)
	{
/*	
	`log("in setOSCFingerTouches");
	`log("fstruct.f1X = "$fstruct.f1X);
	`log("fstruct.1fon: "$fstruct.f1on);
*/	
	
		fingerTouchArray[0].X=fstruct.f1X;	
		fingerTouchArray[0].Y=fstruct.f1Y;
		fingerTouchArray[0].Z=fstruct.f1Z;
	}

	if(fstruct.f2on>0.0)
	{
/*
	`log("fstruct.f2X = "$fstruct.f2X);
	`log("fstruct.2fon: "$fstruct.f2on);
*/
		fingerTouchArray[1].X=fstruct.f2X;	
		fingerTouchArray[1].Y=fstruct.f2Y;
		fingerTouchArray[1].Z=fstruct.f2Z;
	}
	
	if(fstruct.f3on>0.0)
	{
		fingerTouchArray[2].X=fstruct.f3X;	
		fingerTouchArray[2].Y=fstruct.f3Y;
		fingerTouchArray[2].Z=fstruct.f3Z;
	}
	
	if(fstruct.f4on>0.0)
	{
		fingerTouchArray[3].X=fstruct.f4X;	
		fingerTouchArray[3].Y=fstruct.f4Y;
		fingerTouchArray[3].Z=fstruct.f4Z;
	}
	
	if(fstruct.f5on>0.0)
	{
		fingerTouchArray[4].X=fstruct.f5X;	
		fingerTouchArray[4].Y=fstruct.f5Y;
		fingerTouchArray[4].Z=fstruct.f5Z;
	}
	
/*	
	if(fstruct.f1on>0)
	{
	`log("in setOSCFingerTouches");
	`log("fstruct = "$fstruct.f1X);
	
		UT3OSC(WorldInfo.Game).fingerTouchArray[0].X=fstruct.f1X;	
		UT3OSC(WorldInfo.Game).fingerTouchArray[0].Y=fstruct.f1Y;
		UT3OSC(WorldInfo.Game).fingerTouchArray[0].Z=fstruct.f1Z;
	}

	if(fstruct.f2on>0)
	{
		UT3OSC(WorldInfo.Game).fingerTouchArray[1].X=fstruct.f2X;	
		UT3OSC(WorldInfo.Game).fingerTouchArray[1].Y=fstruct.f2Y;
		UT3OSC(WorldInfo.Game).fingerTouchArray[1].Z=fstruct.f2Z;
	}
	
	if(fstruct.f3on>0)
	{
		UT3OSC(WorldInfo.Game).fingerTouchArray[2].X=fstruct.f3X;	
		UT3OSC(WorldInfo.Game).fingerTouchArray[2].Y=fstruct.f3Y;
		UT3OSC(WorldInfo.Game).fingerTouchArray[2].Z=fstruct.f3Z;
	}
	
	if(fstruct.f4on>0)
	{
		UT3OSC(WorldInfo.Game).fingerTouchArray[3].X=fstruct.f4X;	
		UT3OSC(WorldInfo.Game).fingerTouchArray[3].Y=fstruct.f4Y;
		UT3OSC(WorldInfo.Game).fingerTouchArray[3].Z=fstruct.f4Z;
	}
	
	if(fstruct.f5on>0)
	{
		UT3OSC(WorldInfo.Game).fingerTouchArray[4].X=fstruct.f5X;	
		UT3OSC(WorldInfo.Game).fingerTouchArray[4].Y=fstruct.f5Y;
		UT3OSC(WorldInfo.Game).fingerTouchArray[4].Z=fstruct.f5Z;
	}
*/	
}


function setFingerTouchesTest(float val)
{
	//UT3OSC(WorldInfo.Game).fingerTouchArray[0].X = val;
	//`log("TESTING"$UT3OSC(WorldInfo.Game).fingerTouchArray[0].X);
}

/*
// Try to grab the WorldInfo and use that to write the message to the screen.
public static function WorldInfoClientMessage(string message)
{
    local WorldInfo wi;
 
    wi = GetWorldInfo();
 
    if(wi != none)
        ClientMessage(wi, message);
    else
    {
        LogMessage(message);
        LogMessage("Could not send the previous message to clients because WorldInfo0 was not found.");
    }
}
 */
// Try to grab the WorldInfo.

private static function WorldInfo GetWorldInfo()
{
    return WorldInfo(FindObject("WorldInfo_0", class'WorldInfo'));
	
}


simulated event Landed(vector HitNormal, Actor FloorActor)
{
	Super.Landed(HitNormal, FloorActor);
	//showTargetInfo();
}

function testInputData()
{
	//`log("AAAAAAAAAAAAAAAAAA");
	if(localOSCMessageStruct.test > 0.000)
	{
	`log("..."$localOSCMessageStruct.test$"...");
	}
	
	
}

function setOSCCamera(vector val) {
	OSCCamera = val;
}

simulated exec function OSCSetAttachedCamera() {
	if(OSCAttachedCamera) {
		setOSCAttachedCamera(0);
	} else {
		setOSCAttachedCamera(1);
	}
}


simulated exec function setOSCAttachedCamera(int val) {
	if(val == 0) {
		OSCAttachedCamera=false;
	} else {
		OSCAttachedCamera=true;
		OSCFreeCamera=false;
	}
}

simulated exec function OSCSetFreeCamera() {
	if(OSCFreeCamera) {
		setOSCFreeCamera(0);
	} else {
		setOSCFreeCamera(1);
	}
}


simulated exec function setOSCFreeCamera(int val) {
	if(val == 0) {
		OSCFreeCamera=false;
	} else {
		OSCFreeCamera=true;
	}
}

state OSCPlayerMoving {

	exec function oscplayermoveTEST2()
	{
	
		`log("PAWN: IN OSCPLAYERMOVING");
	
	}

	exec function oscRotate(float xval, float yval, float zval)
	{
		local vector locVect;
		locVect.X = xval;
		locVect.Y = yval;
		locVect.Z = zval;
	
		OSCRotation.Pitch=xval;
		OSCRotation.Roll=yval;
		OSCRotation.Yaw=zval;
	
	
		UpdatePawnRotation(Rotator(locVect));
		`log("OSCROTATETEST *******************: "$xval);
	
	}
	
	simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
	{
	/**/
//		`log("IN OSCPAWN::CalcCamera");
	
		if(OSCFreeCamera) 
		{
		
		out_CamLoc.X = localOSCScriptCameramoveStruct.x;
		out_CamLoc.Y = localOSCScriptCameramoveStruct.y;
		out_CamLoc.Z = localOSCScriptCameramoveStruct.z;

		out_CamRot.Pitch = localOSCScriptCameramoveStruct.pitch;
		out_CamRot.Yaw = localOSCScriptCameramoveStruct.yaw;
		out_CamRot.Roll = localOSCScriptCameramoveStruct.roll;		
		
		//out_CamLoc = Location;
//			out_CamLoc.X = OSCCamera.X;
//			out_CamLoc.Y = OSCCamera.Y;  //1800;
//			out_CamLoc.Z = OSCCamera.Z;  //128;
		} else {
	
			if(OSCAttachedCamera)
			{
			// relative camera motion (relative to pawn)
			out_CamLoc = Location;
			out_CamLoc.X += localOSCScriptCameramoveStruct.x;
			out_CamLoc.Y += localOSCScriptCameramoveStruct.y;
			out_CamLoc.Z += localOSCScriptCameramoveStruct.z;	
				
			out_CamRot = Rotation;
			out_CamRot.Pitch += localOSCScriptCameramoveStruct.pitch;
			out_CamRot.Yaw += localOSCScriptCameramoveStruct.yaw;
			out_CamRot.Roll += localOSCScriptCameramoveStruct.roll;
			} else {
				Super.CalcCamera(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
			}
//			out_CamLoc = Location;
//			out_CamLoc.X += OSCCamera.X;
//			out_CamLoc.Y += OSCCamera.Y;  //1800;		
//			out_CamLoc.Z += OSCCamera.Z;  //128;
		}
/*
		`log("IN OSCPAWN::CalcCamera::OSCFreeCamera = "$OSCFreeCamera);
		
		`log("CalcCamera::out_CamLoc.X = "$out_CamLoc.X);
		`log("CalcCamera::localOSCScriptCameramoveStruct.x = "$localOSCScriptCameramoveStruct.x);
		`log("CalcCamera::out_CamLoc.Y = "$out_CamLoc.Y);
		`log("CalcCamera::localOSCScriptCameramoveStruct.y = "$localOSCScriptCameramoveStruct.y);
		`log("CalcCamera::out_CamLoc.Z = "$out_CamLoc.Z);		
		`log("CalcCamera::localOSCScriptCameramoveStruct.z = "$localOSCScriptCameramoveStruct.z);
		
		`log("CalcCamera::out_CamRot.Pitch = "$out_CamRot.Pitch);
		`log("CalcCamera::out_CamRot.Yaw = "$out_CamRot.Yaw);
		`log("CalcCamera::out_CamRot.Roll = "$out_CamRot.Roll);
*/		
		// Testing camera rotation fixes
//		out_CamRot = Rot(0,0,0);
		
//		out_CamRot.Pitch = 0;
//		out_CamRot.Yaw = -16384;
//		out_CamRot.Roll = 0;

		return true;

	}	

/*	
	simulated function setOSCScriptPlayerRotationData(OSCScriptPlayerRotationStruct fstruct)
	{
		localOSCScriptPlayerRotationStruct = fstruct;
	}

	simulated function setOSCRotation()
	{
		local vector localPawnRotation;
		
				
	//	localPawnRotation.X = localOSCScriptPlayerRotationStruct.Pitch;
	//	localPawnRotation.Y = localOSCScriptPlayerRotationStruct.Yaw;
	//	localPawnRotation.Z = localOSCScriptPlayerRotationStruct.Roll;
		
		// Causes problems with PawnBots using OSCPawn
		localPawnRotation.X = OSCPlayerControllerDLL(Controller).localOSCPlayerStateValuesStruct.Pitch;
		localPawnRotation.Y = OSCPlayerControllerDLL(Controller).localOSCPlayerStateValuesStruct.Yaw;
		localPawnRotation.Z = OSCPlayerControllerDLL(Controller).localOSCPlayerStateValuesStruct.Roll;

		`log("localPawnRotation.X: "$localPawnRotation.X );
		`log("localPawnRotation.Y: "$localPawnRotation.Y );
		`log("localPawnRotation.Z: "$localPawnRotation.Z );
		
		UpdatePawnRotation(Rotator(localPawnRotation));
		
	}
	*/
	simulated function Tick(float DeltaTime)
	{
//		THESE AREN'T VALID ANYMORE: don't do anything right now

		//setOSCScriptPlayerRotationData(getOSCScriptPlayerRotation());
		
		//setOSCRotation();
	}
	
}

simulated function setPawnAnimSpeed()
{
	if(isTrumbruticus) {
		self.Mesh.GlobalAnimRateScale=self.GroundSpeed/440.0;
	} else  if(isValkordia) {
		self.Mesh.GlobalAnimRateScale=self.GroundSpeed/440.0;
	}
	
	//`log("GlobalAnimRateScale = "$self.Mesh.GlobalAnimRateScale);
	//`log("Groundspeed = "$self.GroundSpeed);
}

simulated function Tick(float DeltaTime)
{
	//SetMeshVisibility(true);
	//local OSCMessageStruct localOSCMessageStruct;
	
	localOSCMessageStruct.test = getOSCTestfloat();
	testInputData(); // rkh testing input data
	
	localOSCGameParamsStruct.gameGravity = getOSCGameGravity();
	localOSCGameParamsStruct.gameSpeed = getOSCGameSpeed();
	
	// Control ShockBall movements via OSC Finger touch data 
	if(OSCUseFingerTouches)
  	  setOSCFingerTouches(getOSCFingerController());
	
	//getOSCFingerData();
	
	if( localOSCGameParamsStruct.gameGravity != lastGameGravity ) 
	{
		setGrav(localOSCGameParamsStruct.gameGravity);
		`log("set Gravity to "$localOSCGameParamsStruct.gameGravity$"");
	}

	if( localOSCGameParamsStruct.gameSpeed != lastGameSpeed ) 
	{
		setGameSpeed(localOSCGameParamsStruct.gameSpeed);
	}
	
	lastGameGravity = localOSCGameParamsStruct.gameGravity;
	lastGameSpeed = localOSCGameParamsStruct.gameSpeed;

	Super.Tick(DeltaTIme);

	if(sendingOSC)
		sendPlayerState();

	// Scale player animation speed by pawn speed
	setPawnAnimSpeed();
	
	if(pawnDowntrace) {
		downTrace();
	}
	
	if(pawnSidetrace) {
		psideTrace();	
	}
}

exec function sidetrace(int val)
{
	gtracelength = val;
	
	if(pawnSidetrace)
	{
		pawnSidetrace = false;
	} else {
		pawnSidetrace = true;
	}
}


exec function pawntrace(int val)
{
	gdowntracelength = val;
	
	if(pawnDowntrace)
	{
		pawnDowntrace = false;
	} else {
		pawnDowntrace = true;
	}
}

exec function testtrace(int val)
{
	gtesttrace = val;
}

simulated function psideTrace()
{
	// Left and Right traces
//	sideTracer(16384);
//	sideTracer(-16384);

	sideTracer(1);
	sideTracer(-1);
	
}

simulated function sideTracer(int rval)
{

	local vector loc, norm, end;
	local TraceHitInfo hitInfo;
	local Actor traceHit;
    local vector tempRotation;
	
	local vector out_Location;
	local rotator out_Rotation;
	local vector startTrace;
	local vector viewVector;
	
	local Rotator currRot;
	local bool left;
	local string msg;
	
	local vector lVector, localLeft;
	local float trace_distance;
	
    startTrace = Location;
    startTrace.Z +=BaseEyeHeight;
	
//	viewVector .X+= 90*DegToUnrRot;
	//"
/*
	if(gtesttrace==0)
	{
		currRot = Rotation;
		currRot.Yaw += rval;    //+=16384 for L or R, or +-90*DegToUnrRot;
		end = startTrace + normal(vector(currRot))*gtracelength;
		traceHit = trace(loc, norm, end, startTrace, true,, hitInfo);
		DrawDebugLine(startTrace, end, 255,0,0,false);
		
	} else if (gtesttrace==1) { */
		localLeft.X = 0;
		localLeft.Y = rval;
		localLeft.Z = 0;
//		localLeft = vect(0, rval, 0);
		end = Location + (localLeft*gtracelength >> Rotation);		
		traceHit = trace(loc, norm, end, startTrace, true,, hitInfo);
		//cb,,    DrawDebugLine(startTrace, end, 255, 0, 0, false);
//	}
	
	/*
	if (traceHit == none)
	{
		gRightTrace = 0;
		gLeftTrace = 0;
		return;
	}
	else
	{
*/	
		trace_distance = VSize(Location - loc);
		
		if(trace_distance > gtracelength)
		{
			trace_distance = 0;
		}
		
//		if(rval==16384)	// Right
		if(rval==1)	
		{
			left=false;
			msg = "Right";
			gRightTrace = trace_distance;
//		} else if(rval==-16384)  // Left 
		} else if(rval==-1)  // Left 
		{
			left=true;
			msg="Left";
			gLeftTrace = trace_distance;
		}
		
		// float distance between Pawn (Location) and object (loc)
		ClientMessage(msg$": "$trace_distance);//VSize(Location - loc));
		
// 		ClientMessage("Hit: "$traceHit$"  class: "$traceHit.class.outer.name$"."$traceHit.class);
// 		ClientMessage("Location: "$loc.X$","$loc.Y$","$loc.Z);
// 		ClientMessage("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
//		ClientMessage("Component: "$hitInfo.HitComponent);
//	}
	
}



simulated function downTrace()
{

	local vector loc, norm, end;
	local TraceHitInfo hitInfo;
	local Actor traceHit;
    local vector tempRotation;
	local float trace_distance;
	
	//end = Location + normal(vector(Rotation))*gtracelength; // trace to "infinity"
	end = Location + vect(0, 0, -1)*gdowntracelength;
	traceHit = trace(loc, norm, end, Location, true,, hitInfo);
	trace_distance = VSize(Location - loc);
	
	if(trace_distance > gdowntracelength)
	{
		trace_distance = 0;
	}
	
	//DrawDebugLine(Location, end, 255,0,0,false);
	
	/*
	if (traceHit == none)
	{
		ClientMessage("Trace failed.");
		gDownTrace = 0;
		return;		
	}
	else
	{
*/	
		gDownTrace = trace_distance;

		//ClientMessage("Down: "$trace_distance);

		// Play a sound to confirm the information
//		ClientPlaySound(SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_TargetLock');

		// By default only 4 console messages are shown at the time
 //		ClientMessage("Hit: "$traceHit$"  class: "$traceHit.class.outer.name$"."$traceHit.class);
 //		ClientMessage("Location: "$loc.X$","$loc.Y$","$loc.Z);
 //		ClientMessage("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
//		ClientMessage("Component: "$hitInfo.HitComponent);
}

simulated exec function setProjectileTargets(float X, float Y, float Z)
{
	local OSCProj_SeekingShockBall pSSB;
	local vector currentTarget;
	
	bForceNetUpdate = TRUE; // Force replication
	
	currentTarget.X = X;
	currentTarget.Y = Y;
	currentTarget.Z = Z;
	
	ForEach AllActors(class'OSCProj_SeekingShockBall', pSSB) {
		pSSB.setSeekLocation(currentTarget);
	}
}

// Try outputting WeaponFired's HitLocation if exists with OSC
simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	Super.WeaponFIred(InWeapon, bViaReplication, HitLocation);
	//showHitLocation(HitLocation);
}


event Possess(Pawn inPawn, bool bVehicleTransition)
{
	//super.Possess(inPawn, bVehicleTransition);
	SetMovementPhysics();
	`log("******************DONE POSSESSING OSCPawn");

}

exec function getPawnUid()
{
	ClientMessage("Pawn UID = "$getUID());
}

simulated function int getUID()
{
	return uid;
}

simulated function setUID(int val)
{
	if (uid >= 0)
		`log("UID IS:"$uid);
	else
	{
		`log("UID IS NONE");
		uid = val;
	}
}

simulated exec function behindviewset(int _x, int _y, int _z)
{
//  CamOffset = (X=60, Y=0, Z= 0);
	camoffsetx = _x;
	camoffsety = _y;
	camoffsetz = _z;
	CamOffset.X = _x;
	CamOffset.Y = _y;
	CamOffset.Z = _z;//= (X=camoffsetx, Y=camoffsety, Z=camoffsetz)
}




/*
// CUSTOM CAMERA CODE
simulated function name GetDefaultCameraMode( PlayerController RequestedBy )
{
	return 'default';
}
*/





defaultproperties
{
	//groundspeed=10000.0
	seekingTurnRate=20.00000
	
	bHidden=false;
	
	
	// for iPad
	// x range = 0 to 320
	// y range = 0 to 420
	// finger touch ~ 7 to 20
	/*
	OSCFingerSourceMax.X=320.00000
	OSCFingerSourceMin.X=0.00000
	OSCFingerSourceMax.Y=420.00000
	OSCFingerSourceMin.Y=0.00000
	OSCFingerSourceMax.Z=20.00000
	OSCFingerSourceMin.Z=7.00000
	OSCFingerOffsets.X = -160.00000
	OSCFingerOffset.Y = -210.0000
	OSCFingerOffset.Z = 0.00000
	OSCFingerWorldMax.X = 3000.00000
	OSCFingerWorldMin.X = -3000.00000
	OSCFingerWorldMax.Y = 3000.00000
	OSCFingerWorldMin.Y = -3000.00000
	OSCFingerWorldMax.Z = 3000.00000
	OSCFingerWorldMin.Z = 0.00001
*/


Begin Object Name=WPawnSkeletalMeshComponent
AnimTreeTemplate=AnimTree'thesis_characters.valkordia.CHA_valkordia_AnimTree'
End Object



 CamOffset = (X=60, Y=0, Z= 0)
 // CamOffset = (X=camoffsetx, Y=camoffsety, Z=camoffsetz)
  
}