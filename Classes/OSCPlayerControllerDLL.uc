/*******************************************************************************
	OSCPlayerController

	Creation date: 13/06/2010 00:58
	Copyright (c) 2010, beast
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class OSCPlayerControllerDLL extends OSCPlayerController
 DLLBind(oscpack_1_0_2);
 
var class<UTFamilyInfo> CharacterClass;

var bool testPawnStruct;

var bool flying;
var bool oscmoving;
var int currentFingerTouches[5]; //borrowing this for multiparameter testing
var array<vector> fingerTouchArray; //borrowing this for multiparameter testing
var vector object1;
var vector object2;
var vector object3;
var vector object4;
var vector object5;
var Rotator RLeft, RRight;

var array<int> OSCBotUIDs;
var array<int> OSCPawnBotUIDs;

var int OSCBotCount;
var int OSCPawnBotCount;

var Pawn newPawn;
var array<Pawn> OSCBot_Pawns;
var array<Pawn> OSCPawns;
var array<Pawn> OSCPawnBots;
var array<Pawn> OSCBots;


// borrowing this for multiparameter testing
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

//Global vars for this class
var OSCMessageStruct localOSCMessageStruct;
var OSCFingerController localOSCFingerControllerStruct; // borrowing this for multiparameter testing

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


struct OSCScriptPlayerTeleportStruct
{
	var float id;
	var float teleport;
	var float teleportx;
	var float teleporty;
	var float teleportz;
};

struct OSCScriptPlayermoveStruct
{
	var float x;
	var float y;
	var float z;
	var float speed;
	var float jump;
	var float stop;
	var float id;
	var float fly;
	var float airspeed;
	var float pitch;
	var float yaw;
	var float roll;
};

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

struct OSCConsoleCommandStruct
{
	var float command;
};
/*
struct OSCScriptPlayerStopStruct
{
	var float stop;
	var float id;
};

struct OSCScriptPlayerSpeedStruct
{
	var float speed;
	var float id;
};

*/

struct OSCPawnBotStateValuesStruct
{
	var int id;
	var float x;
	var float y;
	var float z;
	var float speed;
	var float pitch;
	var float yaw;
	var float roll;
	var float fly;
	var float airspeed;
	var float crouch;	
};

struct OSCPlayerStateValuesStruct
{
	var int id;
	var float x;
	var float y;
	var float z;
	var float speed;
	var float pitch;
	var float yaw;
	var float roll;
	var float fly;
	var float airspeed;
	var float crouch;	
};

struct OSCPawnBotTeleportStruct
{
	var float id;
	var float teleport;
	var float teleportx;
	var float teleporty;
	var float teleportz;
};

struct OSCPlayerTeleportStruct
{
	var float id;
	var float teleport;
	var float teleportx;
	var float teleporty;
	var float teleportz;
};

struct OSCPawnBotDiscreteValuesStruct
{
	var float id;
	var float jump;
	var float stop;
};

struct OSCPlayerDiscreteValuesStruct
{
	var float id;
	var float jump;
	var float stop;
};

/*
struct OSCSinglePawnBotStateValues
{
	var int id;
	var float x;
	var float y;
	var float z;
	var float speed;
	var float pitch;
	var float yaw;
	var float tilt;
	var float airspeed;
};

struct OSCPawnBotState
{
	var int id;
	var float x;
	var float y;
	var float z;
	var float speed;
	var float pitch;
	var float yaw;
	var float tilt;
	var float airspeed;
};
*/
// OSC Script structs /**/
var OSCScriptPlayermoveStruct localOSCScriptPlayermoveStruct;
var OSCScriptCameramoveStruct localOSCScriptCameramoveStruct;
var OSCConsoleCommandStruct localOSCConsoleCommandStruct;
var OSCScriptPlayerTeleportStruct localOSCScriptPlayerTeleportStruct;
//var OSCScriptPlayerSpeedStruct localOSCScriptPlayerSpeedStruct;
//var OSCScriptPlayerStopStruct localOSCScriptPlayerStopStruct;
//var OSCPawnBotStateValuesStruct localOSCPawnBotStateValuesStruct;
//var OSCPawnBotTeleportStruct localOSCPawnBotTeleportStruct;

// Referenced in OSCPawnController
var array<OSCScriptPlayermoveStruct> OSCScriptPawnBotStructs;
var array<OSCScriptPlayerTeleportStruct> OSCScriptPlayerTeleportStructs;
//var array<OSCScriptPlayerJumpStruct> OSCScriptPlayerJumpStructs;
//var array<OSCScriptPlayerSpeedStruct> OSCScriptPlayerSpeedStructs;
//var array<OSCScriptPlayerStopStruct> OSCScriptPlayerStopStructs;
/**/
var OSCPlayerStateValuesStruct 		localOSCPlayerStateValuesStruct;
var OSCPlayerDiscreteValuesStruct 	localOSCPlayerDiscreteValuesStruct;
var OSCPlayerTeleportStruct 				localOSCPlayerTeleportStruct;

dllimport final function sendOSCpointClick(PointClickStruct a);	
dllimport final function OSCFingerController getOSCFingerController(); //borrowing this for multiparameter testing
dllimport final function OSCScriptPlayermoveStruct getOSCScriptPlayermove();
dllimport final function OSCScriptCameramoveStruct getOSCScriptCameramove();
dllimport final function float getOSCConsoleCommand();
dllimport final function OSCScriptPlayerTeleportStruct getOSCScriptPlayerTeleport();

dllimport final function OSCPawnBotStateValuesStruct getOSCPawnBotStateValues(int id);
dllimport final function OSCPawnBotTeleportStruct getOSCPawnBotTeleportValues(int id);
dllimport final function OSCPawnBotDiscreteValuesStruct getOSCPawnBotDiscreteValues(int id);

dllimport final function OSCPlayerStateValuesStruct getOSCPlayerStateValues(int id);
dllimport final function OSCPlayerTeleportStruct getOSCPlayerTeleportValues(int id);
dllimport final function OSCPlayerDiscreteValuesStruct getOSCPlayerDiscreteValues(int id);


// borrowing this for multiparameter testing
simulated event PreBeginPlay()
{
	Super.PreBeginPlay();

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
	
//	OSCFingerSourceMax = vect(320.00000, 420.00000, 20.00000);
//	OSCFingerSourceMin = vect(0.00001, 0.00001, 7.40000);
//	OSCFingerWorldMax = vect(2000.00000, 2000.00000, 2300.00000);
//	OSCFingerWorldMin = vect(-2000.00000, -2000.00000, 0.00001);

	//OSCPawns.addItem(Pawn);

}

simulated exec function trunkmove(float valx, float valy, float valz)
{
	local vector TrunkLocation;
	local OSCPawn Utp;

	TrunkLocation.Z = valx; //giant multiplier so we extend the trunk more.
	TrunkLocation.X = valz;
	TrunkLocation.Y = valy;
	Utp=OscPawn(Pawn); //this simply gets our pawn so we can then point to our SkelControl
	Utp.TrunkMover.EffectorLocation=Pawn.Location + TrunkLocation; 
}

simulated event PostBeginPlay()
{
  super.PostBeginPlay();
   
	SetupPlayerCharacter();
  
  // Set player mesh to Valkordia
//  OSCPawn(Pawn).SetTimer(1, false, 'changeplayermesh 2');
//  SetTimer(1, false, 'BehindView');
    
//ConsoleCommand("ToggleHUD");
//ConsoleCommand("ToggleHUD");

//ConsoleCommand("SpawnOSCBot");

  //ConsoleCommand("BehindView");
  
//  ConsoleCommand("ToggleHUD");
	// Spawn lead and 5 followers
/*	SetTimer(1,false,'SpawnOSCBot');	
	SetTimer(1,false,'SpawnOSCBot');
	SetTimer(1,false,'SpawnOSCBot');
	SetTimer(1,false,'SpawnOSCBot');
	SetTimer(1,false,'SpawnOSCBot');
	SetTimer(1,false,'SpawnOSCBot');
*/
}

simulated exec function initPiece()
{
//	self.ConsoleCommand("SpawnOSCBot");
	self.ConsoleCommand("ToggleHUD");	
	self.ConsoleCommand("ChangePlayerMesh 2");
	self.ConsoleCommand("BehindView");
	self.ConsoleCommand("FlyWalk");
	self.ConsoleCommand("TeleportPawn 500 500 2000");
	self.ConsoleCommand("spawnPawnBot");
	SetTimer(1);
	self.ConsoleCommand("OSCCheckPawnBots");
	self.ConsoleCommand("OSCPawnMove");
	self.ConsoleCommand("OSCStartInput");	
//	SetTimer(1,false,'ToggleHUD');
	SetTimer(1,true,'SpawnOSCBots');	


}

function SpawnOSCBots()
{	
	// GROUPING CURRENTLY IS SET IN OSCAICONTROLLER Follow state
	`log("OSCBots length: "$OSCBots.length);
	
	if(OSCBots.length==5)
		ClearTimer('SpawnOSCBots');

	// Spawn lead and 5 followers
	self.ConsoleCommand("SpawnOSCBot"); 
}







/** Set player's character info class & perform any other initialization */
function SetupPlayerCharacter()
{
  //Set character to our custom character
  ServerSetCharacterClass(CharacterClass);
}
/**/
simulated exec function OSCStartBotOutput() {
	`log("Initializing OSCBot OSC Output...");

	// Set OSCOutput flag for each OSCBot
	setOSCBotState(true);
}

simulated exec function OSCStopBotOutput() {
	`log("stopping OSCBot OSC Output...");

	// Set OSCOutput flag for each PawnBot
	setOSCBotState(false);
}

simulated exec function OSCStartPawnBotOutput() {
	`log("Initializing PawnBot OSC Output...");

	// Set OSCOutput flag for each PawnBot
	setPawnBotState(true);
}

simulated exec function OSCStopPawnBotOutput() {
	`log("stopping PawnBot OSC Output...");

	// Set OSCOutput flag for each PawnBot
	setPawnBotState(false);
}

simulated exec function getPawnStruct(int pid)
{
	local OSCPawnBotStateValuesStruct tempstruct;	
	local OSCScriptPlayermoveStruct temp2struct;
	
	//testPawnStruct = true;

	temp2struct = getOSCScriptPlayermove();
	tempstruct =  getOSCPawnBotStateValues(pid);
	`log("PawnBot id: "$tempstruct.id$" x = "$tempstruct.x$" y = "$tempstruct.y$" z = "$tempstruct.z);
	
	`log("OSCScriptPlayermoveStruct.x = "$temp2struct.x$", .id = "$temp2struct.id);
}


simulated exec function spawnOSCBot()
{
	spawnOSCBotAt(0, 0, 2000);
}

simulated exec function spawnOSCBotAt(int x, int y, int z)
{

	local OSCBot bot;
	local string PClassName;
	local string CClassName;
	local OSCBot P;
	local OSCAIController C;
	//local OSCPawnController C;
	
	local Vector PawnLocation;
	local Rotator PawnRotation;
	local class <actor> PNewClass; 
	local class <actor> CNewClass;
	
	PClassName = "UT3OSC.OSCBot";
	CClassName = "UT3OSC.OSCAIController";	

	PawnLocation.X = x;		
	PawnLocation.Y = y;
	PawnLocation.Z = z; //-100*OSCBotCount;
	
	PawnRotation = Pawn.Rotation; 
	PNewClass = class<actor>(DynamicLoadObject(PClassName, class'Class'));
	CNewClass = class<Controller>(DynamicLoadObject(CClassName, class'Class'));

	//spawn a new pawn and attach this controller
	C = OSCAIController(Spawn(CNewClass));
	P = OSCBot(Spawn(PNewClass, C, ,PawnLocation,PawnRotation));	
	
	P.setUID(OSCBotCount);	
	OSCBotCount++;

		
	P.SetOwner(C);
	P.SetHidden(false);
	//C = OSCPawnController(Spawn(CNewClass));

//	P.GoToState('PlayerWalking');
	P.setPhysics(PHYS_Falling);
	P.SetMovementPhysics();
	
	if(P!=None)
	{
		C.Possess(P, false);
		//C.PostControllerIdChange(); //TEST Trying to fix OSC Output bug
		OSCBots.addItem(P);
		`log("Added OSCBot with uid: "$P.getUID());
	}
	else
	{
		`log("P WAS NONE***********");
	}	

}
/* */
simulated exec function spawnPawnBot()
{
	local string PClassName;
	local string CClassName;
	local OSCPawnBot P;
	local OSCPawnController C;
	
	local Vector PawnLocation;
	local Rotator PawnRotation;
	local class <actor> PNewClass;
	local class <actor> CNewClass;
	
	PClassName = "UT3OSC.OSCPawnBot";
	CClassName = "UT3OSC.OSCPawnController";	
	
	PawnLocation.X = 0;		
	PawnLocation.Y = 0;
	PawnLocation.Z = 2000;
	
	PawnRotation = Pawn.Rotation; 
	PNewClass = class<actor>(DynamicLoadObject(PClassName, class'Class'));
	CNewClass = class<actor>(DynamicLoadObject(CClassName, class'Class'));

	//spawn a new pawn and attach this controller
	P = OSCPawnBot(Spawn(PNewClass, , ,PawnLocation,PawnRotation));	
	
	P.setUID(OSCPawnBotCount);	
	OSCPawnBotCount++;
	P.SetOwner(C);
	P.SetHidden(false);

	C = OSCPawnController(Spawn(CNewClass));

	if(P!=None)
	{
		C.Possess(P, false);
		C.PostControllerIdChange(); //TEST Trying to fix OSC Output bug
		OSCPawnBots.addItem(P);
		//OSCScriptPawnBotStructs.addItem(localOSCScriptPlayermoveStruct);		// create array instance of playermove structs for each new pawnbot
		//OSCScriptPlayerTeleportStructs.addItem(localOSCScriptPlayerTeleportStruct);
		`log("Added OSCPawnBot with uid: "$P.getUID());
	}
	else
	{
		`log("P WAS NONE***********");
	}	

SetTimer(2);
// Initialize PawnBots after being created
self.ConsoleCommand("OSCCheckPawnBots");
self.ConsoleCommand("OSCPawnMove");
	
}

simulated exec function OSCCheckBots()
{
	local OSCBot C;
	local int uid;
	
	foreach WorldInfo.AllActors(class 'OSCBot', C)
	{
		uid = C.getUID();
		
		if(uid == -1)
		{
			OSCBotCount++;
			C.setUID(OSCBotCount);
			`log("------------------------- BOT DIDN'T HAVE UID");
		}
		else
		{
			`log("------------------------- BOT HAD UID");
		}
		
		`log("BotCount = "$C.getUID());		
	}
}

simulated exec function OSCCheckPawnBots()
{
	local OSCPawnBot C;
	local int uid;
	
	foreach WorldInfo.AllActors(class 'OSCPawnBot', C)
	{
		uid = C.getUID();
		
		if(uid == -1)
		{
			OSCPawnBotCount++;
			C.setUID(OSCPawnBotCount);
			`log("------------------------- PAWN DIDN'T HAVE UID");
			`log(OSCPawnBotCount);
		}
		else
		{
			`log("------------------------- PAWN HAD UID: "$c.getUID());
		}
		
		`log("PawnBotCount = "$C.getUID());
		
	}
}

simulated exec function followOSCBots()
{
	local OSCBot P;
	/**/
	foreach WorldInfo.AllActors(class 'OSCBot', P)
	{
		OSCAIController(P.Controller).target=OSCPawnBot(OSCPawnBots[0]);
		OSCAIController(P.Controller).gotoState('Follow');
		P.SetPhysics(PHYS_Flying);
	}
}


simulated exec function followPawnBots()
{
	local OSCPawnBot C;
	
	foreach WorldInfo.AllActors(class 'OSCPawnBot', C)
	{

		if(C.follow)
		{
			C.follow=false;
		} else {
			C.follow=true;
		}
	}
}

simulated exec function OSCTeleportPawnBot(int valID, int valX, int valY, int valZ)
{
	local OSCPawnBot C;
	local int uid;
	
	`log("IN OSCTeleportPawnBot in OSCPlayerControllerDLL.uc");
	
	foreach WorldInfo.AllActors(class 'OSCPawnBot', C)
	{
		uid = C.getUID();
		
		if (uid==valID)
			C.teleport(valX, valY, valZ);
	}
}

simulated exec function OSCTeleportOSCBot(int valID, int valX, int valY, int valZ)
{
	local OSCBot C;
	local int uid;
	
	`log("IN OSCTeleportOSCBot in OSCPlayerControllerDLL.uc");
	
	foreach WorldInfo.AllActors(class 'OSCBot', C)
	{
		uid = C.getUID();
		
		if (uid==valID)
			C.teleport(valX, valY, valZ);
	}
}


/*
simulated exec function OSCMoveBots(int valID, int valX, int valY, int valZ)
{
	local OSCBot C;
	local int uid;
	
	`log("IN OSCMoveBots in OSCPlayerControllerDLL.uc");
	
		foreach WorldInfo.AllActors(class 'OSCBot', C)
		{
			uid = C.getUID();
			
			`log("____________________ UID = "$uid);
			
			if (uid==valID)
				C.testmoveto(valID, valX, valY, valZ);
		}
}
*/
simulated exec function OSCPawnMove()
{	
	local OSCPawnController C;
	
	`log("Calling OSCPawnMove in OSCPlayerControllerDLL.uc");
	
	foreach WorldInfo.AllActors(class 'OSCPawnController', C)
	{	
		C.GotoState('OSCPawnMove');
	}
}

simulated exec function OSCMove()
{
	
	if(oscmoving)
	{
		// Changed from Walking for Echo::Canyon
//		GotoState('PlayerWalking');
//		Pawn.GotoState('PlayerWalking');    /**/
		GotoState('PlayerFlying');
		Pawn.GotoState('PlayerFlying');
		oscmoving=false;
	}
	else
	{
		GotoState('OSCPlayerMoving');
		Pawn.GotoState('OSCPlayerMoving');
		oscmoving=true;	
	}
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

exec function setAllProjectileAccelRate(int val)
{
    local UTProjectile pUT;

  	ForEach AllActors(class'UTProjectile', pUT)
	{
		pUT.AccelRate = val;
	}
}

simulated exec function teleportPawn(float x, float y, float z)
{
	if( (Role==ROLE_Authority) || (RemoteRole<ROLE_SimulatedProxy) )
		teleportPawn_(x, y, z);
}

simulated reliable client function teleportPawn_(float x, float y, float z)
{

	local vector targetVector;
	
	bForceNetUpdate = TRUE; // Force replication
	
	targetVector.X = x;
	targetVector.Y = y;
	targetVector.Z = z;
	
	Pawn.SetLocation(targetVector);
}

simulated exec function moveAllProjectiles(float X, float Y, float Z) 
{
	if( (Role==ROLE_Authority) || (RemoteRole<ROLE_SimulatedProxy) )
		moveAllProjectiles_(X, Y, Z);
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
	}
}

state OSCPlayerMoving
{
	exec function oscplayermoveTEST()
	{	
		`log('IN OSCPLAYERMOVING');
	}

/*
	exec function oscRotate(float xval, float yval, float zval)
	{
		local vector locVect;
		locVect.X = xval;
		locVect.Y = yval;
		locVect.Z = zval;
	
		OSCRotation.Pitch=xval;
		OSCRotation.Roll=yval;
		OSCRotation.Yaw=zval;
	
	
		Pawn.UpdatePawnRotation(Rotator(locVect));
		`log("OSCROTATETEST *******************: "$xval);
	
	}
*/	
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
	
		if (Pawn == none)
		{
			return;
		}
		
		Pawn.Acceleration = NewAccel;
	}
	
	function PlayerMove( float DeltaTime )
	{
		local vector			X,Y,Z, NewAccel;
		local eDoubleClickDir	DoubleClickMove;
		local rotator			OldRotation;
		local rotator			OSCCameraRotation;
		local bool				bSaveJump;
		local bool				bOSCJump;
		local float				OSCJump;
		local int				OSCCurrentID;
		local float 				OSCPitch, OSCYaw, OSCRoll;
		//local float 			OSCTeleport;
		//ROB HACKING - adding test vector pulling from OSC
		local vector			OSCVector; //, OSCX, OSCY, OSCZ;
		local float 			OSCGroundSpeed;
		local vector			OSCCamera;
		local float				OSCStop;

/*		
		OSCVector.X = localOSCScriptPlayermoveStruct.x;
		OSCVector.Y = localOSCScriptPlayermoveStruct.y;
		OSCVector.Z = localOSCScriptPlayermoveStruct.z;
		OSCGroundSpeed = localOSCScriptPlayermoveStruct.speed;
		OSCJump = localOSCScriptPlayermoveStruct.jump;
		OSCStop = localOSCScriptPlayermoveStruct.stop;
		OSCCurrentID = localOSCScriptPlayermoveStruct.id;
*/

		if (localOSCPlayerTeleportStruct.teleport > 0)
		{		
	//			teleportPawn_(localOSCScriptPlayerTeleportStruct.teleportx, localOSCScriptPlayerTeleportStruct.teleporty, localOSCScriptPlayerTeleportStruct.teleportz);
			teleportPawn_(localOSCPlayerTeleportStruct.teleportx, localOSCPlayerTeleportStruct.teleporty, localOSCPlayerTeleportStruct.teleportz);

	//		OSCPawn(Pawn).teleport(localOSCPlayerTeleportStruct.teleportx, localOSCPlayerTeleportStruct.teleporty, localOSCPlayerTeleportStruct.teleportz);					
		}
		
		OSCVector.X = localOSCPlayerStateValuesStruct.x;
		OSCVector.Y = localOSCPlayerStateValuesStruct.y;
		OSCVector.Z = localOSCPlayerStateValuesStruct.z;
		OSCGroundSpeed = localOSCPlayerStateValuesStruct.speed;
		OSCJump = localOSCPlayerDiscreteValuesStruct.jump;
		OSCStop = localOSCPlayerDiscreteValuesStruct.stop;

		OSCPitch = localOSCPlayerStateValuesStruct.pitch;
		OSCYaw  = localOSCPlayerStateValuesStruct.yaw;
		OSCRoll = localOSCPlayerStateValuesStruct.roll;
		
		OSCCameraRotation.Pitch=localOSCScriptCameramoveStruct.pitch;
		OSCCameraRotation.Roll=localOSCScriptCameramoveStruct.roll;
		OSCCameraRotation.Yaw=localOSCScriptCameramoveStruct.yaw;
		
		//`log("Camera Coordinates: "$OSCCameraRotation.Pitch$", "$OSCCameraRotation.Yaw$", "$OSCCameraRotation.Roll);
		
		OSCCamera.X = localOSCScriptCameramoveStruct.x;
		OSCCamera.Y = localOSCScriptCameramoveStruct.y;
		OSCCamera.Z = localOSCScriptCameramoveStruct.z;

		OSCPawn(Pawn).setOSCCamera(OSCCamera);
		
		if (OSCJump > 0.0) 
		{
			bOSCJump = true;
			bPressedJump = true;
		}
		
	
		//`log("localOSCScriptPlayerTeleportStruct.teleport:  "$localOSCScriptPlayerTeleportStruct.teleport);
		//`log("localOSCScriptPlayerTeleportStruct.teleportx:  "$localOSCScriptPlayerTeleportStruct.teleportx);
		//`log("localOSCScriptPlayerTeleportStruct.teleporty:  "$localOSCScriptPlayerTeleportStruct.teleporty);
		//`log("localOSCScriptPlayerTeleportStruct.teleportz:  "$localOSCScriptPlayerTeleportStruct.teleportz);
	
//		if(localOSCScriptPlayerTeleportStruct.teleport > 0.0)
//		{
//			`log("localOSCScriptPlayerTeleportStruct.teleport:  "$localOSCScriptPlayerTeleportStruct.teleport);
//			callTeleport();
//		}		

		if( Pawn == None )
		{
			GotoState('Dead');
		}
		else
		{
			GetAxes(Pawn.Rotation,X,Y,Z);

			// Update acceleration.
			NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
			NewAccel.Z = 0;

			NewAccel = OSCVector.X*X + OSCVector.Y*Y;
			NewAccel = Pawn.AccelRate * Normal(NewAccel);

			//ROB HACKING
			//			NewAccel = OSCVector;

			if(OSCStop == 1)
			{
				NewAccel.X = 0;
				NewAccel.Y = 0;
				NewAccel.Z = 0;
			}
			
			if (IsLocalPlayerController())
			{
				AdjustPlayerWalkingMoveAccel(NewAccel);
			}

			// Add OSC speed control
			Pawn.GroundSpeed = OSCGroundSpeed;
			
			//DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );

			// Update rotation.
			OldRotation = Rotation;
			SetRotation(OSCCameraRotation);
			//UpdateRotation( DeltaTime );
			//Rotation = OSCCameraRotation;
			
			bDoubleJump = false;
	
			// Add OSC Rotation	
			//Pawn.FaceRotation(OSCCameraRotation, DeltaTime);
			//Pawn.FaceRotation(RInterpTo(OldRotation, OSCCameraRotation, DeltaTIme, 90000, true), DeltaTime);
			
			//`log("bOSCJump: "$bOSCJump);
			//`log("OSCJump: "$OSCJump);
			
			// CROUCH
			// Pawn.ShouldCrouch(bDuck != 0);
			
			//`log("localOSCScriptPlayermoveStruct.teleport:  "$localOSCScriptPlayermoveStruct.teleport);
			//`log("localOSCScriptPlayermoveStruct.teleportx:  "$localOSCScriptPlayermoveStruct.teleportx);
			//`log("localOSCScriptPlayermoveStruct.teleporty:  "$localOSCScriptPlayermoveStruct.teleporty);
			//`log("localOSCScriptPlayermoveStruct.teleportz:  "$localOSCScriptPlayermoveStruct.teleportz);

			
			//Add OSC Jump and JumpZ
			if(bOSCJump)
			{
				//bPressedJump = true;
				Pawn.JumpZ = OSCJump;
				Pawn.DoJump(bUpdating);//bUpdating);
				//bPressedJump = false;
				//localOSCScriptPlayermoveStruct.jump = 0.0;
				bOSCJump = false;
				//OSCJump = 0.0;
			}
			
			if( bPressedJump && Pawn.CannotJumpNow() )
			{
				bSaveJump = true;
				bPressedJump = false;
			}
			else
			{
				bSaveJump = false;
			}

			if( Role < ROLE_Authority ) // then save this move and replicate it
			{
				ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - OSCCameraRotation);
			}
			else
			{
				ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - OSCCameraRotation);
			}
			bPressedJump = bSaveJump;
			//bPressedJump = bOSCJump;
		}
	}
	
	/*
	function UpdateRotation( float DeltaTime )
	{
		local Rotator	DeltaRot, ViewRotation;
		
		ViewRotation = Rotation;
		If (Pawn !=none )
		{
			Pawn.SetDesiredRotation(ViewRotation);	
		}
		
		//Calculate Delta to be appled of VIewRotation
		DeltaRot.Yaw = 0;
		DeltaRot.Pitch = PlayerInput.aLookUp;
		ProcessViewRotation ( DeltaTime, ViewRotation, DeltaRot);
		SetRotation(ViewRotation);	
	}
*/	


	function UpdateRotation( float DeltaTime )
	{
		local Rotator DeltaRot, newRotation, ViewRotation;
		local float OSCPitch, OSCYaw, OSCRoll;
		
		OSCPitch = localOSCPlayerStateValuesStruct.pitch;
		OSCYaw  = localOSCPlayerStateValuesStruct.yaw;
		OSCRoll = localOSCPlayerStateValuesStruct.roll;
		
		ViewRotation = Rotation;
		if (Pawn!=none)
		{
			Pawn.SetDesiredRotation(ViewRotation);
		}

		// Calculate Delta to be applied on ViewRotation
		DeltaRot.Yaw = OSCYaw;
		DeltaRot.Pitch = OSCPitch;
		DeltaRot.Roll = OSCRoll;
		
		ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );

				// Testing follow functions
		if ( OSCPawnBot(Pawn).follow==true )
		{
			ViewRotation = OSCPawnBot(Pawn).targetRotation;
			`log("                *****************                       ******************* PawnController");
		}		

		SetRotation(ViewRotation);

		ViewShake( deltaTime );

		NewRotation = ViewRotation;
		NewRotation.Roll = Rotation.Roll;
		
		if ( Pawn != None )
		{
			Pawn.FaceRotation(NewRotation, deltatime);
		}
		
		
	}
}

/**
* Removes this controller from the existing pawn and possesses a new one. (exec)
* 
* @param ClassName The classname of the WMPawn to possess
*/
exec function ChangePawns(string ClassName)
{
	local Pawn P;
	local Vector PawnLocation;
	local Rotator PawnRotation;
	local class <actor> NewClass;

	P = Pawn;
	PawnLocation = Pawn.Location;
	PawnRotation = Pawn.Rotation; 
	NewClass = class<actor>(DynamicLoadObject(ClassName, class'Class'));

	// Detach the current pawn from this controller and destroy it.
	UnPossess();
	P.Destroy(); 

	//spawn a new pawn and attach this controller
	P = Pawn(Spawn(NewClass, , ,PawnLocation,PawnRotation));

	//use false if you spawned a character and true for a vehicle
	Possess(P, false);
}

/*
exec function ChangePawn()
{
//declare the variables
local OSCPawn p;
local vector l;
local rotator r; 

//set the variables 
p = Pawn;
l = Pawn.Location;
r = Pawn.Rotation; 

// get rid of the old pawn
UnPossess();
p.Destroy(); 

//spawn a new pawn and possess it
p = Spawn(class'OSCPawn', , ,l,r);

//use false if you spawned a character and true for a vehicle
Possess(p, false);
}
*/

/*
exec function RBGrav(float NewGravityScaling)
{
	WorldInfo.RBPhysicsGravityScaling = NewGravityScaling;
}
*/

/*
 Print information about the thing we are looking at
 */
function showTargetInfo()
{	
	Local vector loc, norm, end;
	Local TraceHitInfo hitInfo;
	Local Actor traceHit;
//	local MyPlayerStruct tempVals;
	
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
		super.StartFIre(FireModeNum);
	}
}

simulated function setOSCFingerTouches(OSCFingerController fstruct)
{
	currentFingerTouches[0]=fstruct.f1on;
	currentFingerTouches[1]=fstruct.f2on;
	currentFingerTouches[2]=fstruct.f3on;
	currentFingerTouches[3]=fstruct.f4on;
	currentFingerTouches[4]=fstruct.f5on;
	
	if(fstruct.f1on>0.0)
	{	
		fingerTouchArray[0].X=fstruct.f1X;	
		fingerTouchArray[0].Y=fstruct.f1Y;
		fingerTouchArray[0].Z=fstruct.f1Z;
	}

	if(fstruct.f2on>0.0)
	{
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
}

/*
simulated function __setOSCScriptPawnBotData()
{
	local OSCScriptPawnMoveXStruct xstruct;
	local OSCScriptPawnMoveYStruct ystruct;
	local OSCScriptPawnMoveZStruct zstruct;
	local OSCScriptPawnMoveJumpStruct jumpstruct;
	local OSCScriptPawnMoveStopStruct stopstruct;
	local OSCScriptPawnMoveSpeedStruct speedstruct;
	
	local OSCScriptPlayermoveStruct tempStruct;
	local OSCPawnController C;
	local int uid;
	
	xstruct = getOSCScriptPawnMoveX();
	ystruct = getOSCScriptPawnMoveY();
	zstruct = getOSCScriptPawnMoveZ();
	jumpstruct = getOSCScriptPawnMoveJump();
	speedstruct = getOSCScriptPawnMoveSpeed();
	stopstruct = getOSCScriptPawnMoveStop();

	
	foreach WorldInfo.AllControllers(class 'OSCPawnController', C)
	{
		uid = C.pawnUID;
		
		if (uid == xstruct.id)
		{
			C.localPawnMoveStruct.x = xstruct.x;
			C.OSCDirty = 1;
		}
		else
		{
			C.localPawnMoveStruct.x = 0;
		}
		
		if (uid == ystruct.id)
		{
			C.localPawnMoveStruct.y = ystruct.y;
			C.OSCDirty = 1;
		}
		else
		{
			C.localPawnMoveStruct.y = 0;
		}
		
		if (uid == zstruct.id)
		{
			C.localPawnMoveStruct.z = zstruct.z;
			C.OSCDirty = 1;
		}
		else
		{
			C.localPawnMoveStruct.z = 0;
		}		
		
		if (uid == jumpstruct.id)
		{
			C.localPawnMoveStruct.jump = jumpstruct.jump;
			C.OSCDirty = 1;
		}
		else
		{
			C.localPawnMoveStruct.jump = 0;
		}

		if (uid == speedstruct.id)
		{
			C.localPawnMoveStruct.speed = speedstruct.speed;
			C.OSCDirty = 1;
		}
		else
		{
			C.localPawnMoveStruct.speed = 0;
		}

		if (uid == stopstruct.id)
		{
			C.localPawnMoveStruct.stop = stopstruct.stop;
			C.OSCDirty = 1;
		}
		else
		{
			C.localPawnMoveStruct.stop = 0;
		}
		
	}

}

*/

/*
simulated function setOSCScriptPawnBotData(OSCScriptPlayermoveStruct playerstruct, OSCScriptPlayerTeleportStruct teleportstruct)
{
	local OSCPawnController C;
	local int uid;

	local OSCScriptPlayermoveStruct pStruct;
	local OSCScriptPlayerTeleportStruct tStruct; 	
	
	foreach WorldInfo.AllControllers(class 'OSCPawnController', C)
	{

		pStruct = playerstruct;
		tStruct = teleportstruct;

		uid = C.pawnUID;
		
		if (uid == pStruct.id)
		{

			`log("pStruct.id:  "$pStruct.id);
			`log("pStruct.x:  "$pStruct.x);
			`log("pStruct.speed:  "$pStruct.speed);		

			C.OSCDirty = 1;
			C.setOSCScriptPlayermoveStruct(pStruct);
		}
		
		if (uid == tStruct.id)
		{
			C.setOSCScriptTeleportStruct(tStruct);
		}
		
	}

}
*/

simulated function setOSCScriptPawnBotTeleportData(OSCScriptPlayerTeleportStruct teleportstruct)
{
	local OSCPawnBot P;
	//local int uid;
	local OSCScriptPlayerTeleportStruct tStruct; 	
	
	// Set Teleport struct directly
	tStruct = teleportstruct;

	P = OSCPawnBot(OSCPawnBots[tStruct.id]);
	//uid = P.uid;
	OSCPawnController(P.Controller).OSCDirty = 1;
	OSCPawnController(P.Controller).setOSCScriptTeleportStruct(tStruct);
	
}

/*
simulated function setOSCScriptPawnBotData()
{








	//OSCScriptPawnBotStructs[localOSCScriptPlayermoveStruct.id] = localOSCScriptPlayermoveStruct;

	local OSCPawnBot P;
	local int uid;

	P = OSCPawnBot(OSCPawns[localOSCScriptPlayermoveStruct.id]);
	uid = P.uid;
	OSCPawnController(P.Controller).setOSCScriptPlayermoveStruct(OSCScriptPawnBotStructs[localOSCScriptPlayermoveStruct.id]);
		
	
	
	local OSCPawnController C;
	local int uid;

	foreach WorldInfo.AllControllers(class 'OSCPawnController', C)
	{
		uid = C.pawnUID;		
//		C.OSCDirty = 1;
		C.setOSCScriptPlayermoveStruct(OSCScriptPawnBotStructs[uid]);
	}

}

	*/

	
// Need to set these controllers' data directly from an array
simulated function __x__setOSCScriptPawnBotData(OSCScriptPlayerTeleportStruct teleportstruct)
{
	local OSCPawnController C;
	local OSCPawnBot P;
	local int uid;
	local OSCScriptPlayerTeleportStruct tStruct; 	
	
	// Set Teleport struct directly
	tStruct = teleportstruct;

	P = OSCPawnBot(OSCPawns[tStruct.id]);
	uid = P.uid;
	OSCPawnController(P.Controller).setOSCScriptPlayermoveStruct(OSCScriptPawnBotStructs[uid]);
	OSCPawnController(P.Controller).OSCDirty = 1;
	OSCPawnController(P.Controller).setOSCScriptTeleportStruct(tStruct);

	foreach WorldInfo.AllControllers(class 'OSCPawnController', C)
	{

		//tStruct = teleportstruct;

		uid = C.pawnUID;
		
		C.OSCDirty = 1;
		//C.setOSCScriptPlayermoveStruct(OSCScriptPawnBotStructs[uid -1]);
		C.setOSCScriptPlayermoveStruct(OSCScriptPawnBotStructs[uid]);
/*		
		if (uid == tStruct.id)
		{
			C.setOSCScriptTeleportStruct(tStruct);
		}	
*/
	}

}

simulated function cleanLocalOSCPlayermoveStruct()
{

	localOSCScriptPlayermoveStruct.jump = 0;
	localOSCScriptPlayermoveStruct.id = 0;
	localOSCScriptPlayermoveStruct.x = 0;
	localOSCScriptPlayermoveStruct.y = 0;
	localOSCScriptPlayermoveStruct.z = 0;
	localOSCScriptPlayermoveStruct.speed = 0;
	localOSCScriptPlayermoveStruct.stop = 0;
	localOSCScriptPlayermoveStruct.pitch = 0;
	localOSCScriptPlayermoveStruct.yaw = 0;
	localOSCScriptPlayermoveStruct.roll = 0;
	localOSCScriptPlayermoveStruct.fly = 0;
	localOSCScriptPlayermoveStruct.airspeed = 0;				
}

	
simulated function setOSCScriptCameramoveData(OSCScriptCameramoveStruct fstruct)
{
	localOSCScriptCameramoveStruct = fstruct;
	//`log("fstruct: "$fstruct);
	//`log("localOSCScriptCameramoveStruct.x:  "$localOSCScriptCameramoveStruct.x);
	//`log("localOSCScriptCameramoveStruct.y:  "$localOSCScriptCameramoveStruct.y);
	//`log("localOSCScriptCameramoveStruct.z:  "$localOSCScriptCameramoveStruct.z);

}



simulated function setOSCScriptPlayermoveData(OSCScriptPlayermoveStruct fstruct)
{
	//`log("OSCPlayerControllerDLL::setOSCScriptPlayermoveData::fstruct.id "$fstruct.id$" - fstruct.jump "$fstruct.jump);
	
	localOSCScriptPlayermoveStruct = fstruct;
	
	// Set pawnbot commands to array
	OSCScriptPawnBotStructs[localOSCScriptPlayermoveStruct.id] = localOSCScriptPlayermoveStruct;
}

simulated function setOSCScriptPlayerTeleportData(OSCScriptPlayerTeleportStruct fstruct)
{
	localOSCScriptPlayerTeleportStruct = fstruct;
	OSCScriptPlayerTeleportStructs[localOSCScriptPlayerTeleportStruct.id] = localOSCScriptPlayerTeleportStruct;
}

simulated function callConsoleCommand(float val)//OSCConsoleCommandStruct fstruct)
{
	local int currentVal;
	currentVal = val;//.appTrunc();//appTrunc(val);
	
	//localOSCConsoleCommandStruct = fstruct;
	//`log("ConsoleCommand: "$currentVal);
	//`log("ConsoleCommand: "$localOSCConsoleCommandStruct.command);
	//`log("ConsoleCommand Value : "$localOSCConsoleCommandStruct.value);
	//ConsoleCommand($localOSCConsoleCommandStruct.command);
	if (currentVal == 1) 
	{
		`log("ConsoleCommand *********************************************************************************************************************************************** ");
	  ConsoleCommand("behindview");
	}
}

simulated function callTeleport()
{
	`log("IN TELEPORT **************************************************************");

	
	if(localOSCScriptPlayerTeleportStruct.teleport == 1.0)
	{
		`log("TELEPORT == 1.0");
		teleportPawn_(localOSCScriptPlayerTeleportStruct.teleportx, localOSCScriptPlayerTeleportStruct.teleporty, localOSCScriptPlayerTeleportStruct.teleportz);
	}
}


// TODO: hook this to generic OSC call, string title + params can be passed in via OSC
/*
function OSCCallExecCommand(string val)
{
	ConsoleCommand(val);
}
*/

simulated function setOSCPlayerData()
{
	localOSCPlayerStateValuesStruct = getOSCPlayerStateValues(OSCPawn(Pawn).getUID());
	localOSCPlayerDiscreteValuesStruct = getOSCPlayerDiscreteValues(OSCPawn(Pawn).getUID());
	localOSCPlayerTeleportStruct = getOSCPlayerTeleportValues(OSCPawn(Pawn).getUID());
		
	//`log("IN setOSCPlayerData for pawnid: "$pawnUID);
}
	
event PlayerTick( float DeltaTime )
{
	// Generic OSCConsoleCommand call
//	if(localOSCScriptPlayermoveStruct.teleport == 1.0)
//	{
//		`log("TELEPORT == 1.0");
//		//teleportPawn_(localOSCScriptPlayermoveStruct.teleportx, localOSCScriptPlayermoveStruct.teleporty, localOSCScriptPlayermoveStruct.teleportz);
//	}
	
	
	// OSCPlayerControllerDLL.uc will pass pawnbot data to all active pawnbots
	//setOSCScriptPawnBotData(getOSCScriptPlayermove(), getOSCScriptPlayerTeleport());
	//setOSCScriptPawnBotData();
	
	// Set pawnbot commands to array
	//setOSCScriptPlayermoveData(getOSCScriptPlayermove());	
	
	// WORKING HERE: Call OSCPawnBot... calls here to populate local structs
	//setOSCPawnBotData();
	setOSCPlayerData();
	
//	`log("Pawn 1 Speed: "$OSCScriptPawnBotStructs[1].speed);
//	`log("Pawn 2 Speed: "$OSCScriptPawnBotStructs[2].speed);
//	`log("Pawn 3 Speed: "$OSCScriptPawnBotStructs[3].speed);
	
	//setOSCScriptPawnBotData();
	//setOSCScriptPawnBotTeleportData(getOSCScriptPlayerTeleport());
	setOSCScriptCameramoveData(getOSCScriptCameramove());	
	
	if(oscmoving)
	{
	
		//getOSCConsoleCommand();
		callConsoleCommand(getOSCConsoleCommand());
		//`log("CONSOLE COMMAND: "$getOSCConsoleCommand());
	
		localOSCFingerControllerStruct = getOSCFingerController();
		setOSCFingerTouches(localOSCFingerControllerStruct);
		// OSC Script data for OSC control over pawns and camera
		//`log("Before setSCScriptPlayermoveData");
//		setOSCScriptPlayermoveData(getOSCScriptPlayermove());
//		setOSCScriptCameramoveData(getOSCScriptCameramove());
		setOSCScriptPlayerTeleportData(getOSCScriptPlayerTeleport());
		
		//`log("After setSCScriptPlayermoveData");		
		//callTeleport();
	}
	
	//testInputData(); // rkh testing input data
	
	// testing
//	if(testPawnStruct)	
//		getPawnStructCont();
		
//	`log("PlayerTick - OSCPlayerControllerDLL before...");
	Super.PlayerTick(DeltaTime);
//	`log("PlayerTick - OSCPlayerControllerDLL after...");	
}

simulated function setPawnBotState(bool val)
{
	// Set each PawnBot to be sending OSC
	
	local OSCPawnBot P;

//	P = OSCPawnBot(OSCPawnBots[tStruct.id]);

	foreach WorldInfo.AllActors(class 'OSCPawnBot', P)
	{
		P.sendingOSC = val;
	}

}


simulated function setOSCBotState(bool val)
{
	// Set each PawnBot to be sending OSC
	
	local OSCBot P;


	foreach WorldInfo.AllActors(class 'OSCBot', P)
	{
		P.sendingOSC = val;
	}

}


function AddOnlineDelegates(bool bRegisterVoice)
{
}

defaultproperties 
{
	OSCBotCount=0;
	OSCPawnBotCount=0;
	//CharacterClass=class'UT3OSC.OSCFamilyInfo_OSCPawnBot'
	BehindView=true;
}