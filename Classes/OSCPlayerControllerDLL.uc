/*******************************************************************************
	OSCPlayerController

	Creation date: 13/06/2010 00:58
	Copyright (c) 2010, beast
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class OSCPlayerControllerDLL extends OSCPlayerController
 DLLBind(oscpack_1_0_2);
 
var class<UTFamilyInfo> CharacterClass;

var array< float > averagedTurn; // Array for averaging mouse move values for smoothing
var array< float > averagedLookup; // Array for averaging mouse move values for smoothing
var array< float > averagedMouseX;
var array< float > averagedMouseY;
var float totalMouseX, totalMouseY;
var float totalTurn, totalLookup; // Total values aggregating turn and lookup input for smoothing
var int smootherCount;
var float interpUpAmount;
var float interpUpTime;
var float interpUpCurrent;
var float interpUpTarget;
var float interpRollAmount;
var float interpRollTime;
var float interpRollCurrent;
var float interpRollTarget;
var float interpYawAmount;
var float interpYawTime;
var float interpYawCurrent;
var float interpYawTarget; 

var float interpMouseXAmount;
var float interpMouseXTime;
var float interpMouseXCurrent;
var float interpMouseXTarget;
var float interpMouseYAmount;
var float interpMouseYTime;
var float interpMouseYCurrent;
var float interpMouseYTarget;

var float gSmoothMouseX;
var float gSmoothMouseY;

var float keyTurnScaler;
var float pawnTurnThreshold;

var array< float > distanceHistory;			// Array for tracking position history for speed tracking
var vector LastPosition;
var float currentSpeed;
var float maxAirSpeed;
var float minAirSpeed;
var array < float > airSpeedHistory;
var int speedArraySizeMax;
var float airSpeedIncrement;
var float currentAirSpeedIncrement;
var bool bChangingPlayerSpeed;

var bool testPawnStruct;

var repnotify bool flying;
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

// OSC Mode value for toggling pawn and controller modes
var int gOSCMode;

var bool bUseMouseTurn;
var bool bUseMouseDive;
var bool bUseMouseFreeLook;
var bool bToggleMouseLook;
var bool bFreezeCameraLocation;
var int CameraMode;

var rotator gMouseRotation;
var float gDeltaMouseYaw;
var float gDeltaMousePitch;
var float gTotalMouseYaw;
var float gTotalMousePitch;

var int gCameraMode;
var float gCameraDistance;
var float gCameraOffsetX;

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
	var float setx;
	var float sety;
	var float setz;
	var float setpitch;
	var float setyaw;
	var float setroll;
	var float fly;
	var float airspeed;
	var float crouch;	
	var int mode;
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

// OSC Script structs /**/
var OSCScriptPlayermoveStruct localOSCScriptPlayermoveStruct;
var OSCScriptCameramoveStruct localOSCScriptCameramoveStruct;
var OSCConsoleCommandStruct localOSCConsoleCommandStruct;
var OSCScriptPlayerTeleportStruct localOSCScriptPlayerTeleportStruct;

// Referenced in OSCPawnController
var array<OSCScriptPlayermoveStruct> OSCScriptPawnBotStructs;
var array<OSCScriptPlayerTeleportStruct> OSCScriptPlayerTeleportStructs;

var OSCPlayerStateValuesStruct 		localOSCPlayerStateValuesStruct;
var OSCPlayerDiscreteValuesStruct 	localOSCPlayerDiscreteValuesStruct;
var OSCPlayerTeleportStruct 				localOSCPlayerTeleportStruct;

// Control over whether gravity affects flying pawns
var bool bIgnoreGravity;

//"Bool to make pawns float with inertia or not (stop immediately) 
var bool bFlightInertia;

// Player's "Call"
var bool gCall;
var float gSendCall;

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
	
//	`log("Setting UDKOSC Key Binds (in PlayerController.PreBeginPlay...)");
	
//	PlayerInput.SetBind("K" "decreasePlayerSpeed");
//	PlayerInput.SetBind("L", "increasePlayerSpeed");

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

//simulated event PostBeginPlay()
simulated event PostBeginPlay()
{
  super.PostBeginPlay();
   
	SetupPlayerCharacter();
	
	smootherCount = 20; // default array size
	
	// Interpolation defaults for Look Up pawn angling
	interpUpAmount = 90 * DegToUnrRot;
	interpUpTime = 20000;
	interpUpTarget = 25;   // go higher for loops 
	interpRollAmount = 90 * DegToUnrRot;
	interpRollTime = 20000;
	interpRollTarget = 25;    
	interpYawAmount = 90 * DegToUnrRot;
	interpYawTime = 20000;
	interpYawTarget = 18;  
	keyTurnScaler = 100.0;//0.06;
	
	interpMouseXAmount = 90 * DegToUnrRot;
	interpMouseXTime = 20000;
	interpMouseXTarget = 25;  

	interpMouseYAmount = 90 * DegToUnrRot;
	interpMouseYTime = 20000;
	interpMouseYTarget = 25;  
	
	bUseMouseTurn = TRUE;
	bUseMouseFreeLook = FALSE;
	bUseMouseDive = FALSE;
	bFreezeCameraLocation = FALSE;
	
	gCameraMode = 0;
	gCameraDistance = 0;
	gCameraOffsetX = 0;
	
	bFlightInertia = TRUE;
	
//	gCall = FALSE;
//	gSendCall = 0.0;
	
	// Hide weapon, came up again
//	SkeletalMeshComponent(Pawn.Weapon.Mesh).SetOwnerNoSee(True);
	
	// REMOVE ALL WEAPONS
//	Pawn.InvManager.DiscardInventory();
	
//	Pawn.Weapon.SetHidden(True);

//	OSCPawn(Pawn).Weapon.SetHidden(True);
	
}

simulated exec function hideWeapon()
{
	// REMOVE ALL WEAPONS
	Pawn.InvManager.DiscardInventory();

		// Hide weapon, came up again
	SkeletalMeshComponent(Pawn.Weapon.Mesh).SetOwnerNoSee(True);
}
/* */
simulated exec function testing(int val)
{
	if(val==0) {
		self.ConsoleCommand("ToggleHUD");	
		self.ConsoleCommand("HideWeapon");		
		self.ConsoleCommand("ChangePlayerMesh 2");
		self.ConsoleCommand("BehindViewSet 28 0 -40");
		self.ConsoleCommand("FlyWalk");
//		self.ConsoleCommand("TeleportPawn -1900 1200 10000");
//		self.ConsoleCommand("OSCMove");
		self.ConsoleCommand("setOSCFreeCamera 0");
		self.ConsoleCommand("setOSCAttachedCamera 0");
		self.ConsoleCommand("OSCStartInput");			
		self.ConsoleCommand("OSCStartOutput");					
		self.ConsoleCommand("SideTrace 2500");
//		self.ConsoleCommand("testtrace 1");
		self.ConsoleCommand("PawnTrace 1200");
	}
}

simulated exec function initPiece()
{/* */

	`log("Starting OSC Output...");
	self.ConsoleCommand("OSCStartInput");	
	self.ConsoleCommand("OSCStartOutput");
	self.ConsoleCommand("OSCStartPawnBotOutput");
	self.ConsoleCommand("OSCStartBotOutput");
	
	`log("Initializing 'Echo::Canyon' environment...");
	//self.ConsoleCommand("ToggleHUD");	
	self.ConsoleCommand("HideWeapon");
	self.ConsoleCommand("ChangePlayerMesh 2");
	//self.ConsoleCommand("BehindView"); 
	//self.ConsoleCommand("BehindViewSet 28 0 -40"); 
	self.ConsoleCommand("FlyWalk");
	self.ConsoleCommand("OSCMove");	

			//	self.ConsoleCommand("TeleportPawn -3500 1200 9000");

	`log("Spawning leader OSCPawnBots...");
//	self.ConsoleCommand("spawnPawnBotAt 0 0 2000");
//	self.ConsoleCommand("spawnPawnBotAt 100 100 2000");
	self.ConsoleCommand("spawnPawnBotAt 3000 2500 6200");
	self.ConsoleCommand("spawnPawnBotAt 3000 2400 6000");

	//SetTimer(1);	
	self.ConsoleCommand("OSCCheckPawnBots");
	self.ConsoleCommand("OSCPawnMove");
	
	`log("Enabling tracers...");		
	self.ConsoleCommand("SideTrace 2500");
	self.ConsoleCommand("PawnTrace 2500");	
	`log("Spawning follower OSCBots...");
	SetTimer(1,true,'SpawnOSCBots');	
}

// From UTPlayerController
exec function BehindView()
{
	//if ( WorldInfo.NetMode == NM_Standalone )
		SetBehindView(!bBehindView);
}

// This bool will enable floating pawns to have a bit of inertia. Setting it to TRUE will cause cheat flying to not be used, which allows for inertia. Setting FALSE will cause pawn to stop immediately.
exec function setPawnInertia(bool val)
{
//	bFlightInertia = val;
	bCheatFlying=!val;
}

function SpawnOSCBots()
{	
	// GROUPING CURRENTLY IS SET IN OSCAICONTROLLER Follow state
	`log("OSCBots length: "$OSCBots.length);
	
	if(OSCBots.length>=12)
		ClearTimer('SpawnOSCBots');

	// Spawn lead and 5 followers
	self.ConsoleCommand("SpawnOSCBotAt "$3000+(OSCBots.length * 100)$" 2500 6700"); 
	self.ConsoleCommand("followOSCBots");
}

function callConsoleCommand(int cmd)
{
	local string command;
	
	if(cmd > 0)
	{
			
		// Setup Case statement here to toggle exec commands
		switch( cmd )
		{
			case 1:
				command = "OSCStartOutput";			
				break;
			case 2:
				command = "OSCMove";			
				break;
			case 3:					
				command = "BehindView	";
				break;
			case 4:
				command = "setOSCFreeCamera 1";
				break;
			case 5:
				command = "setOSCFreeCamera 0";
				break;
			case 6:
				command = "setOSCAttachedCamera 1";
				break;
			case 7:
				command = "setOSCAttachedCamera 0";
				break;
			case 8:
				command = "OSCSetFly 0";
				break;				
			case 9:
				command = "OSCSetFly 1";
				break;				
			case 10:
				command = "OSCSetBehindCamera 1";
				break;
			case 11:
				command = "OSCSetBehindCamera 2";
				break;
			default:
				`log("***> INVALID Console Command: "$cmd);
				break;
		}
	
//			`log("ConsoleCommand: "$cmd$"::"$command);
		Self.ConsoleCommand(command);
	}	
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
	spawnOSCBotAt(0, 0, 1000);
}

//simulated exec function spawnOSCBotAt(int x, int y, int z, int mesh=2)
exec function spawnOSCBotAt(int x, int y, int z, int mesh=2)
{

	local OSCBot bot;
	local string PClassName;
	local string CClassName;
	local OSCBot P;
	local OSCAIController C;
	local Vector PawnLocation;
	local Rotator PawnRotation;
	local class <actor> PNewClass; 
	local class <actor> CNewClass;
	
	PClassName = "UDKOSC.OSCBot";
	CClassName = "UDKOSC.OSCAIController";	

	PawnLocation.X = x;		
	PawnLocation.Y = y;
	PawnLocation.Z = z;
	
	//PawnRotation = Pawn.Rotation; 
	PNewClass = class<actor>(DynamicLoadObject(PClassName, class'Class'));
	CNewClass = class<Controller>(DynamicLoadObject(CClassName, class'Class'));

	//spawn a new pawn and attach this controller
	C = OSCAIController(Spawn(CNewClass));
	P = OSCBot(Spawn(PNewClass, C, ,PawnLocation,PawnRotation));	
	
	P.setUID(OSCBotCount);	
	OSCBotCount++;

	P.SetOwner(C);
	P.SetHidden(false);

	P.setPhysics(PHYS_Falling);
	P.SetMovementPhysics();
	
	P.selectedPlayerMesh = mesh;
	P.setPawnMesh(mesh);	
	
	if(P!=None)
	{
		C.Possess(P, false);
		OSCBots.addItem(P);
		`log("Added OSCBot with uid: "$P.getUID());
	}
	else
	{
		`log("P WAS NONE***********");
	}	
}

//simulated exec function spawnPawnBot()
exec function spawnPawnBot()
{
	spawnOSCBotAt(0, 0, 2000);
}

simulated exec function _spawnPawnBotAt(int x, int y, int z)
{
	local string PClassName;
	local string CClassName;
	local OSCPawnBot P;
	local OSCPawnController C;
	
	local Vector PawnLocation;
	local Rotator PawnRotation;
	local class <actor> PNewClass;
	local class <actor> CNewClass;
	
	PClassName = "UDKOSC.OSCPawnBot";
	CClassName = "UDKOSC.OSCPawnController";	
	
	PawnLocation.X = x;		
	PawnLocation.Y = y;
	PawnLocation.Z = z;
	
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
		`log("Added OSCPawnBot with uid: "$P.getUID());
//				C.Pawn.setPawnMesh(mesh);	// set pawn mesh
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


// Exec function to spawn a new OSCPawnBot at a given location. An optional parameter to assign a specific Mesh to that OSCPawnBot defaults to "2" (Valkordia) for now
//simulated exec function spawnPawnBotAt(int x, int y, int z, int mesh=2)
exec function spawnPawnBotAt(int x, int y, int z, int mesh=2)
{
	local string PClassName;
	local string CClassName;
	local OSCPawnBot P;
	local OSCPawnController C;
	
	local Vector PawnLocation;
	local Rotator PawnRotation;
	local class <actor> PNewClass;
	local class <actor> CNewClass;
	
	PClassName = "UDKOSC.OSCPawnBot";
	CClassName = "UDKOSC.OSCPawnController";	
	
	PawnLocation.X = x;		
	PawnLocation.Y = y;
	PawnLocation.Z = z;
	
	//PawnRotation = Pawn.Rotation; 
	PNewClass = class<actor>(DynamicLoadObject(PClassName, class'Class'));
	CNewClass = class<actor>(DynamicLoadObject(CClassName, class'Class'));

	//spawn a new pawn and attach this controller
	P = OSCPawnBot(Spawn(PNewClass, , ,PawnLocation,PawnRotation));	
	

	
	P.setUID(OSCPawnBotCount);	
	OSCPawnBotCount++;
	P.SetOwner(C);
	P.SetHidden(false);
	
	P.selectedPlayerMesh = mesh;
	P.setPawnMesh(mesh);		
	
	C = OSCPawnController(Spawn(CNewClass));

	if(P!=None)
	{
		C.Possess(P, false);
		C.PostControllerIdChange(); //TEST Trying to fix OSC Output bug
		OSCPawnBots.addItem(P);
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

/*
simulated exec function spawnPawnBotMesh(int mesh)
{
	local string PClassName;
	local string CClassName;
	local OSCPawnBot P;
	local OSCPawnController C;
	
	local Vector PawnLocation;
	local Rotator PawnRotation;
	local class <actor> PNewClass;
	local class <actor> CNewClass;
	
	PClassName = "UDKOSC.OSCPawnBot";
	CClassName = "UDKOSC.OSCPawnController";	
	
	PawnLocation.X = x;		
	PawnLocation.Y = y;
	PawnLocation.Z = z;
	
	//PawnRotation = Pawn.Rotation; 
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
		`log("Added OSCPawnBot with uid: "$P.getUID());
		
		C.Pawn.setPawnMesh(mesh);	// set pawn mesh
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
*/

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

simulated exec function followMe()
{
	local OSCBot P;
	local int targetPawnUID;
	/**/
	foreach WorldInfo.AllActors(class 'OSCBot', P)
	{
		
		OSCAIController(P.Controller).target=OSCPawn(Pawn);
		OSCAIController(P.Controller).gotoState('Follow');
		P.SetPhysics(PHYS_Flying);
	}

}

simulated exec function followOSCBots()
{
	local OSCBot P;
	local int targetPawnUID;
	/**/
	foreach WorldInfo.AllActors(class 'OSCBot', P)
	{
		if(P.uid < 5)
		{
			targetPawnUID = 0;
		} else if ((P.uid >=5) && (P.uid < 10))
		{
			targetPawnUID = 1;
		}
		
		OSCAIController(P.Controller).target=OSCPawnBot(OSCPawnBots[targetPawnUID]);
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
		if(flying) {
			GotoState('PlayerFlying');					//		GotoState('PlayerWalking');
		} else {
			GotoState('PlayerWalking');
		}
		//Pawn.GotoState('PlayerFlying');						//		Pawn.GotoState('PlayerWalking');
		oscmoving=false;
	}
	else
	{
		GotoState('OSCPlayerMoving');
		Pawn.GotoState('OSCPlayerMoving');
		oscmoving=true;	
	}
}
simulated exec function OSCSetFly(int val)
{
	if(val==0) {
		GotoState('PlayerWalking');
		//bCheatFlying=false;
		flying=false;	
	} else {
	  GotoState('PlayerFlying');
	  //bCheatFlying=true;
	  flying=true;	
	}

		if(oscmoving) {
			GotoState('OSCPlayerMoving');
			Pawn.GotoState('OSCPlayerMoving');
		}	
}

exec function FlyWalk()
{

	toggleFlying();
	/*
	if(flying)
	{
		GotoState('PlayerWalking');
		//bCheatFlying=false;
		flying=false;
	}
	else
	{
	  GotoState('PlayerFlying');
	 // bCheatFlying=true;
	  flying=true;
	}
	*/
}

reliable server function toggleFlying()
{	
	if(flying)
	{
		GotoState('PlayerWalking');
		if(!bFlightInertia)
		    bCheatFlying=false;
		flying=false;
	}
	else
	{
	  GotoState('PlayerFlying');
	  if(!bFlightInertia)
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

simulated  function setMode(int modeValue)
{
		if(modeValue != -1)
		{
			`log("**************************** MODE VALUE ="$modeValue);
			
			// Setup Case statement here to toggle exec commands based on mode
			switch( modeValue )
			{
				case 1:
					`log("CASE = "$modeValue);
				case 2:
				case 3:					
				default:
					`log("DEFAULT CASE = "$modeValue);
					break;
				}

			
		}

}


function calculateSpeed()
{
		local vector currentPosition;
		local float currentDistance;
		local int arrayLength;
		local int i;
		local float totalDistance;
		
		
	bForceNetUpdate = TRUE; // Force replication
	
		currentPosition = Pawn.Location;
		
//		`log("currentPosition: "$currentPosition);
		
		arrayLength = distanceHistory.Length;
		
		if(arrayLength >= 10)
		{
			// remove val
			distanceHistory.Remove(0, 1);
		} 

		// debug
//		`log("VSIZE: "$VSize(LastPosition - Location));
//		LastPosition = Location;

		
		// Calculate distance moved and add to array
		currentDistance = VSize(LastPosition - currentPosition);
//		currentDistance = LastPosition dot Location;
		distanceHistory.additem(currentDistance);
		
		LastPosition = currentPosition;
		
		totalDistance = 0.0;
		
		for(i=0;i<distanceHistory.Length; i++)
		{
			totalDistance += distanceHistory[i];			
		}
		
		currentSpeed = totalDistance / 10.0;
		
//		`log("CurrentDistance: "$currentDistance);
//		`log("CurrentSpeed = "$currentSpeed);

}
	
/*
DeltaRot.Yaw	= PlayerInput.aTurn;
		DeltaRot.Pitch	= PlayerInput.aLookUp;
*/
//"

// Look in PlayerInput for params
/* 
var input			float		aBaseX;
var input			float		aBaseY;
var input			float		aBaseZ;
var input			float		aMouseX;
var input			float		aMouseY;
var input			float		aForward;
var input			float		aTurn;
var input			float		aStrafe;
var input			float		aUp;
var input			float		aLookUp;
*/

exec function increasePlayerSpeed()
{
//	`log("In increasePlayerSpeed exec function...");
	changePlayerSpeed(1.0);
	Server_changePlayerSpeed(1.0);
}
	
exec function decreasePlayerSpeed()
{
	changePlayerSpeed(-1.0);
}

simulated function changePlayerSpeed(float value) {
	// Stub for PlayerFlying state function
}

reliable server function Server_changePlayerSpeed(float value) {
	// Stub for PlayerFlying state function
}

simulated function setPlayerSpeed() {
	// Stub for PlayerFlying state function
}

// EXEC FUNCTIONS FOR CHANGING MOUSE LOOK/TURN BEHAVIORS
exec function UseMouseFreeLook(bool value) {
	bUseMouseFreeLook = value;
}

exec function setUDKOSCCameraMode(int value)
{
	gCameraMode = value;
	
	// 0:  reset to standard camera
	// 1:  Static follow camera: no Location change, Rotation follows Player
	// 2:  Static follow camera: mouse-controlled Z/height, no X,Y location change, Rotation follows Player
	// 3:  Static camera: no Location or Rotation change	
	
}

exec function FreezeCameraLocation(bool value) {
	bFreezeCameraLocation = value;
}

exec function UseMouseTurn(bool value) {
	bUseMouseTurn = value;
}

exec function UseMouseDive(bool value) {
	bUseMouseDive = value;
	bUseMouseTurn = value;
}

exec function ToggleMouseLook() {
	if(bToggleMouseLook)
	{
		bToggleMouseLook = FALSE;
		bUseMouseFreeLook = FALSE;
		bUseMouseTurn = TRUE;
	} else {
		bToggleMouseLook = TRUE;
		bUseMouseFreeLook = TRUE;
		bUseMouseTurn = FALSE;
	}
}

exec function MouseLookOn() {
//	bUseMouseFreeLook = TRUE;
//	bUseMouseTurn = FALSE;
	bToggleMouseLook = TRUE;
}

exec function MouseLookOff() {
//	bUseMouseFreeLook = FALSE;
//	bUseMouseTurn = TRUE;
	bToggleMouseLook = FALSE;
}

/*
// Trigger player's "Call"
exec function Call(bool val) {

	gCall = val;
	
	sendCall();
	ClientMessage("gCall: "$gCall);
}
*/
/*
function sendCall() {

	ClientMessage("gCall2: "$gCall);

	if(gCall) {
		gSendCall = 1;
		gCall = False;
	} else {
		gSendCall = 0;
	}
	
	
	ClientMessage("gCall3: "$gCall);
	ClientMessage("gsendCall: "$gSendCall);
	
}
*/

exec function setCameraDistance(float value) {
	gCameraDistance = value; 
}

exec function IncrementCameraMode() {
	
	gCameraMode = gCameraMode + 1;
	if(gCameraMode > 3)
		gCameraMode = 0;
	
	// 0:  Dynamic player-facing camera; mouse controlled camera around player
	// 1:  Static camera: no Location or Rotation change	
	// 2:  Static follow camera: mouse-controlled Z/height, no X,Y location change, Rotation follows Player
	// 3:  Static follow camera: no Location change, Rotation follows Player
		
	//ClientMessage("Inc gCameraMode:"$gCameraMode);
}

exec function DecrementCameraMode() {

	gCameraMode = gCameraMode - 1;
	if(gCameraMode < 0)
		gCameraMode = 3;

	// 0:  Dynamic player-facing camera; mouse controlled camera around player
	// 1:  Static camera: no Location or Rotation change	
	// 2:  Static follow camera: mouse-controlled Z/height, no X,Y location change, Rotation follows Player
	// 3:  Static follow camera: no Location change, Rotation follows Player
	
	//ClientMessage("Dec gCameraMode:"$gCameraMode);
}

exec function IncrementCameraDistance() {
	if( bToggleMouseLook ) {
		gCameraDistance += 20.0f;
	} else {
		gCameraOffsetX += 20.0f;	
	}
}

exec function DecrementCameraDistance() {
	if( bToggleMouseLook ) {
		gCameraDistance -= 20.0f;
	} else {
		gCameraOffsetX -= 20.0f;	
	}
}


state PlayerFlying
{
  /**/
	// Called by Tick; data is populated by key presses
	simulated function setPlayerSpeed()
	{

		local int i;
		local int arrayLength;
		local float totalValue;
		
		totalValue = 0;

		arrayLength = 0;
		arrayLength = airSpeedHistory.Length;
	
//		`log("arrayLength: "$arrayLength);
//		`log("speedArraySizeMax: "$speedArraySizeMax);
		
		// bChangingPlayerSpeed
		
		if(arrayLength > speedArraySizeMax)
		{
//			`log("Removing...");
			airSpeedHistory.Remove(0, 1);
		}
		
		if(bChangingPlayerSpeed)
		{
			airSpeedHistory.addItem(currentAirSpeedIncrement);
		} else {
			airSpeedHistory.addItem(0);			
		}

//		`log("Just Added: airSpeedHistory.Length: "$airSpeedHistory.Length);
				
		// Flush last key-bind -added value
//		if(Pawn!=None)
//			currentAirSpeedIncrement = 0;
		
		for(i=0; i< arrayLength; i++)
		{
				//`log("airSpeedHistory["$i$"]: "$airSpeedHistory[i]);

				totalValue += airSpeedHistory[i];
		}
		
//		`log("arrayLength: "$arrayLength);
		if(arrayLength > 0)
			totalValue = totalValue / arrayLength; //speedArraySizeMax;
		
		if( totalValue + OSCPawn(Pawn).baseAirSpeed > maxAirSpeed)  {
			totalValue = maxAirSpeed;
		} else if(totalValue + OSCPawn(Pawn).baseAirSpeed < minAirSpeed) {
			totalValue = minAirSpeed;
		} 
		
		// average out 
		OSCPawn(Pawn).AirSpeed = OSCPawn(Pawn).baseAirSpeed + totalValue; // / speedArraySizeMax;
		
//		`log("totalValue: "$totalValue);
//		`log("Changing AirSpeed: "$OSCPawn(Pawn).AirSpeed);
		
	}

	reliable server  function Server_changePlayerSpeed(float value)
	{
		currentAirSpeedIncrement =  airSpeedIncrement * value;	
		bChangingPlayerSpeed = TRUE;
	}
	
	simulated function changePlayerSpeed(float value)
	{
		currentAirSpeedIncrement =  airSpeedIncrement * value;	
		bChangingPlayerSpeed = TRUE;
	}
	
	exec function playerSpeedOff()
	{
		bChangingPlayerSpeed = FALSE;
	}
	exec function setSmootherCount(int val)
	{
		if(val<1)
		    val=1;
		
		smootherCount = val;
	}

	exec function setInterpMouseXAmount(int val)
	{
		interpMouseXAmount = val  * DegToUnrRot;
	}
	
	exec function setInterpMouseXTime(int val)
	{
		interpMouseXTime = val;
	}

	exec function setInterpMouseXTarget(int val)
	{
		interpMouseXTarget = val;
	}

	exec function setInterpMouseYAmount(int val)
	{
		interpMouseYAmount = val  * DegToUnrRot;
	}
	
	exec function setInterpMouseYTime(int val)
	{
		interpMouseYTime = val;
	}

	exec function setInterpMouseYTarget(int val)
	{
		interpMouseYTarget = val;
	}
	
	
	exec function setInterpUpAmount(int val)
	{
		interpUpAmount = val  * DegToUnrRot;
	}
	
	exec function setInterpUpTime(int val)
	{
		interpUpTime = val;
	}

	exec function setInterpUpTarget(int val)
	{
		interpUpTarget = val;
	}
	
	exec function setKeyTurnScaler(float val)
	{
		keyTurnScaler= val;
	}
	
	exec function ignoreGravity()
	{
		if(bIgnoreGravity) {
			bIgnoreGravity = FALSE;
		} else {
			bIgnoreGravity = TRUE;
		}
	}
	
	// From PlayerController.uc
	function PlayerMove(float DeltaTime)
	{
	
		local vector X,Y,Z;
		local float flyingGravity;
	

	bForceNetUpdate = TRUE; // Force replication
		
		GetAxes(Rotation,X,Y,Z);
		
		Pawn.Acceleration = PlayerInput.aForward*X + PlayerInput.aStrafe*Y + PlayerInput.aUp*vect(0,0,1); 

		if(!bIgnoreGravity) {
		
			// add some gravity back in?
			flyingGravity = getGravityZ();// vect(0,0,-1);
			Pawn.Acceleration.Z = (Pawn.Acceleration.Z + flyingGravity) * 1.1;//1.00001;
		}
		
		Pawn.Acceleration = Pawn.AccelRate * Normal(Pawn.Acceleration);


		if ( bCheatFlying && (Pawn.Acceleration == vect(0,0,0)) )
			Pawn.Velocity = vect(0,0,0);
			
		// Update rotation.
		UpdateRotation( DeltaTime );

		if ( Role < ROLE_Authority ) // then save this move and replicate it
		{
			OSCPawn(Pawn).baseAirSpeed = 2500;
			ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
		}
		else 
			ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
	}
	
	function SmootherTurn(float value, float strafe, out float averagedValue)
	{
	
		local int arrayLength;
		local int i;

		// turn off mouse turning
		if(!bUseMouseTurn)
			value = 0.f;
		
		arrayLength = averagedTurn.Length;
		
		if(arrayLength > smootherCount) { 	// If we changed smootherCount in exec function, truncate last n array vals

			// remove vals from total
			for( i=smootherCount+1; i < arrayLength; i++ )
			{
				totalTurn -= averagedTurn[i];
			}
			
			averagedTurn.Remove(smootherCount, arrayLength-smootherCount);
		}
		else if(arrayLength == smootherCount) {
			totalTurn -= averagedTurn[0];
			averagedTurn.Remove(0, 1); // remove 1st item in array
		}

		// Add strafe value into turning sequence
		totalTurn+=value + (strafe * keyTurnScaler);
		averagedTurn.addItem(value + (strafe * keyTurnScaler));
		
		if(arrayLength > 0)
			averagedValue = totalTurn / arrayLength;
	}
	
	function SmootherMouseX(float value, out float averagedValue)
	{
	
//	var array< float > averagedMouseX;
		local int arrayLength;
		local int i;
		
		if(bUseMouseTurn)
			value = 0.f;
		arrayLength = averagedMouseX.Length;
	
		totalMouseX -= averagedMouseX[0];
		averagedMouseX.Remove(0, 1); // remove 1st item in array	

		totalMouseX+=value;
		averagedMouseX.addItem(value);

		averagedValue = totalMouseX / arrayLength;
		
	}
	
	function SmootherLookUp(float value, out float averagedValue)
	{
	
		local int arrayLength;
		local int i;
		
		// turn off mouse turning
		if(!bUseMouseTurn)
			value = 0.f;
			
		arrayLength = averagedLookUp.Length;
		
		if(arrayLength > smootherCount) { 	// If we changed smootherCount in exec function, truncate last n array vals
		
			// remove vals from total
			for( i=smootherCount+1; i < arrayLength; i++ )
			{
				totalLookUp -= averagedLookUp[i];
			}
			
			averagedLookUp.Remove(smootherCount, arrayLength-smootherCount);
		}
		else if(arrayLength == smootherCount) {
			totalLookUp -= averagedLookUp[0];
			averagedLookUp.Remove(0, 1); // remove 1st item in array
		} 

		totalLookUp+=value;
		averagedLookUp.addItem(value);

		if(arrayLength > 0)
			averagedValue = totalLookUp / arrayLength;
	}

	function float SmoothPawnUp()
	{
	
		local float pitchVal;
	
		pitchVal = 1;
		
		if(PlayerInput.aUp < 0)
		{
			pitchVal = -1;
		}
		
		//`log("interpUpCurrent * UnrRotToDeg)%360: "$(interpUpCurrent * UnrRotToDeg)%360);
		
		if(PlayerInput.aUp != 0)
		{
		
			if( (pitchVal > 0) && (interpUpCurrent * UnrRotToDeg)%360 <= interpUpTarget) 
			{
				interpUpCurrent = interpUpCurrent + (((interpUpAmount * DegToUnrRot  * pitchVal) -interpUpCurrent) / interpUpTime);
			} else if ((pitchVal < 0) && (interpUpCurrent * UnrRotToDeg)%360 >= interpUpTarget * pitchVal) {
				interpUpCurrent = interpUpCurrent - (((interpUpAmount * DegToUnrRot ) -interpUpCurrent) / interpUpTime);		
			}
			
		} else {
			if((InterpUpCurrent * UnrRotToDeg )%360 != 90)
			{
				interpUpCurrent = interpUpCurrent + ((0 -interpUpCurrent) / 10.0);
			}
		}
		
		return interpUpCurrent;
		
	}
	
	
	function float SmoothPawnRoll()
	{
	
		local float rollVal, localTurn;
	
		localTurn = PlayerInput.aTurn;
		
		if(!bUseMouseTurn)
			localTurn = 0.f;
			
		rollVal = 1;
		
		//if(PlayerInput.aStrafe < 0)
		if((localTurn + (getDirection(PlayerInput.aStrafe) * keyTurnScaler)) < 0)			
		{
			rollVal = -1;
		}
		
		rollVal = getDirection(localTurn + (getDirection(PlayerInput.aStrafe) * keyTurnScaler));
		
		//`log("interpUpCurrent * UnrRotToDeg)%360: "$(interpUpCurrent * UnrRotToDeg)%360);
		//if((PlayerInput.aTurn + (getDirection(PlayerInput.aStrafe) * keyTurnScaler)) < 0)	
		if(PlayerInput.aStrafe != 0 || localTurn != 0)
		{
		
			if( (rollVal > 0) && (interpRollCurrent * UnrRotToDeg)%360 <= interpRollTarget) 
			{
				interpRollCurrent = interpRollCurrent + (((interpRollAmount * DegToUnrRot  * rollVal) -interpRollCurrent) / interpRollTime);
			} else if ((rollVal < 0) && (interpRollCurrent * UnrRotToDeg)%360 >= interpRollTarget * rollVal) {
				interpRollCurrent = interpRollCurrent - (((interpRollAmount * DegToUnrRot ) -interpRollCurrent) / interpRollTime);		
			}
			
		} else {
			if((interpRollCurrent * UnrRotToDeg )%360 != 90)
			{
				interpRollCurrent = interpRollCurrent + ((0 -interpRollCurrent) / 10.0);
			}
		}
		
		return interpRollCurrent;
		
	}



	function int getDirection(int val)
	{
		local int returnVal;
		
		returnVal = 0;
		
		if(val > 0) 
		{
			returnVal = 1;
		} else if (val < 0) 
		{
			returnVal = -1;
		}
		
		return returnVal;
	}
	
	exec function setPawnTurnThreshold(float val)
	{
		pawnTurnThreshold = val;
	}
	
	function float scaledTurnX()
	{

		local float maxTurnX, retValue, turnXValue, localTurn;
		
		maxTurnX = 800.0;
		
		localTurn = PlayerInput.aTurn;
		
		if(!bUseMouseTurn)
			localTurn = 0.f;
			
		if(pawnTurnThreshold > 0)
			maxTurnX = pawnTurnThreshold;
		
		if(abs(localTurn + PlayerInput.aStrafe) > maxTurnX)
		{
			turnXValue = maxTurnX * getDirection(localTurn + PlayerInput.aStrafe);
		} else {			
			turnXValue = localTurn + PlayerInput.aStrafe;
		}
		
		// PlayerInput.aTurn and aStrafe are inputs
		//    - want to scale amout of turning, e.g. interpYawTarget by % of mouse value (of max mouse value)
		retValue = turnXValue / maxTurnX;
		
		return retValue;
	}
	
	function float SmoothPawnYaw()
	{
	
		local float yawVal, localTurn;
		local float localInterpYawTarget;
		
		localTurn = PlayerInput.aTurn;
		
		if(!bUseMouseTurn)
			localTurn = 0.f;
			
		// Scale yaw amount by amount of mouse/strafe movement
		localInterpYawTarget = interpYawTarget * scaledTurnX();
		
		yawVal = 1;
		

//		if(PlayerInput.aStrafe < 0)		
//		if((getDirection(PlayerInput.aStrafe + PlayerInput.aTurn) * keyTurnScaler) < 0)				
//		{
//			yawVal = -1;
//		}
				
		if( ((PlayerInput.aStrafe != 0) && (PlayerInput.aForward > 0)) || (localTurn != 0) && (PlayerInput.aForward > 0))
		{		
			if( (interpYawCurrent * UnrRotToDeg)%360 <= localInterpYawTarget) 
			{
				interpYawCurrent = interpYawCurrent + (((interpYawAmount * DegToUnrRot  * yawVal) -interpYawCurrent) / interpYawTime);
			} else if ( (interpYawCurrent * UnrRotToDeg)%360 >= localInterpYawTarget ) {
				interpYawCurrent = interpYawCurrent - (((interpRollAmount * DegToUnrRot ) -interpYawCurrent) / interpYawTime);		
			}
			
		} else {
			if((interpYawCurrent * UnrRotToDeg )%360 != 90)
			{
				interpYawCurrent = interpYawCurrent + ((0 -interpYawCurrent) / 10.0);
			}
		}
		
//		`log("interpYawCurrent: "$interpYawCurrent);
		
		return interpYawCurrent;
		
	}
	
/*
	function float SmoothPawnYaw()
	{
		local float yawVal;
		
		yawVal = 1;
		

//		if(PlayerInput.aStrafe < 0)		
		if((PlayerInput.aTurn + (getDirection(PlayerInput.aStrafe) * keyTurnScaler)) < 0)				
		{
			yawVal = -1;
		}
				
		if(((PlayerInput.aStrafe != 0) && (PlayerInput.aForward > 0)) || (PlayerInput.aTurn != 0) && (PlayerInput.aForward > 0))
		{
		
			if( (yawVal > 0) && (interpYawCurrent * UnrRotToDeg)%360 <= interpYawTarget) 
			{
				interpYawCurrent = interpYawCurrent + (((interpYawAmount * DegToUnrRot  * yawVal) -interpYawCurrent) / interpYawTime);
			} else if ((yawVal < 0) && (interpYawCurrent * UnrRotToDeg)%360 >= interpYawTarget * yawVal) {
				interpYawCurrent = interpYawCurrent - (((interpRollAmount * DegToUnrRot ) -interpYawCurrent) / interpYawTime);		
			}
			
		} else {
			if((interpYawCurrent * UnrRotToDeg )%360 != 90)
			{
				interpYawCurrent = interpYawCurrent + ((0 -interpYawCurrent) / 10.0);
			}
		}
		
		return interpYawCurrent;
		
	}
	*/	
	
	// From PlayerController.uc
	function UpdateRotation( float DeltaTime )
	{
	
		local Rotator	DeltaRot, newRotation, ViewRotation;
		local float smoothTurn, smoothLookUp, strafedRoll;		
		local float strafe;

	bForceNetUpdate = TRUE; // Force replication
		
		ViewRotation = Rotation;
		if (Pawn!=none)
		{
//			Pawn.SetDesiredRotation(ViewRotation, FALSE, FALSE, 100.f);
		}
		
		// Smooth aTurn and aLookup Values
		SmootherLookUp(PlayerInput.aLookUp, smoothLookUp);

		if(PlayerInput.aStrafe > 0) {
			strafe = 1;
		}  else if(PlayerInput.aStrafe < 0) {
			strafe = -1;
		} else {
			strafe = 0;
		}
		
//		`log("PlayerInput.aTurn: "$PlayerInput.aTurn);
//		`log("PlayerInput.aMouseX: "$PlayerInput.aMouseX);
		
		SmootherTurn(PlayerInput.aTurn, strafe, smoothTurn);

		// Override mouse yaw if forward and strafe pressed; bBehindView from UTPlayerController, so only do this in "BehindView" modes
//		if(PlayerInput.aTurn !=0 && PlayerInput.aStrafe !=0 && bBehindView)
//		{
			// do nothing
//		} else {
			DeltaRot.Yaw	= smoothTurn;
//		}
		
		DeltaRot.Pitch = smoothLookUp;

		// Calculate Delta to be applied on ViewRotation
//		DeltaRot.Yaw	= PlayerInput.aTurn;
//		DeltaRot.Pitch	= PlayerInput.aLookUp;

		ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
		SetRotation(ViewRotation);
		
		ViewShake( deltaTime );

		NewRotation = ViewRotation;
		//NewRotation.Roll = Rotation.Roll;
		
		// Add Strafe as an input towards Pawn roll
		NewRotation = pawnRotate(NewRotation, DeltaTime);
		
		if ( Pawn != None )
			OSCPawn(Pawn).FaceRotation(NewRotation, deltatime);

		// Calculate rotation based on mouse input for camera rotation
		if(!bUseMouseTurn)
		{
			DeltaRot.Yaw = PlayerInput.aTurn;
			DeltaRot.Pitch = PlayerInput.aLookUp;
			
//			ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
			

			gMouseRotation += DeltaRot;
			gDeltaMouseYaw = PlayerInput.aTurn;
			gDeltaMousePitch = PlayerInput.aLookUp;

			gTotalMouseYaw += PlayerInput.aTurn;
			gTotalMousePitch += PlayerInput.aLookUp;
	/*		
			if(gTotalMouseYaw > DegToUnrRot * 90.f) {
				gTotalMouseYaw = DegToUnrRot * 90.f;
			} else if(gTotalMouseYaw < DegToUnrRot * -90.f) {
				gTotalMouseYaw = DegToUnrRot * -90.f;		
			}
*/
			if(gTotalMousePitch > DegToUnrRot * 90.f) {
				gTotalMousePitch = DegToUnrRot * 90.f;
			} else if(gTotalMousePitch < DegToUnrRot * -90.f) {
				gTotalMousePitch = DegToUnrRot * -90.f;		
			}			

		} else {
			// Smooth mouse x value for independent camera
			//SmootherMouseX(PlayerInput.aMouseX, gSmoothMouseX);
		}
	
	}

	/**   FROM PLAYERCONTROLLER.UC
	*
	* Processes the player's ViewRotation
	* adds delta rot (player input), applies any limits and post-processing
	* returns the final ViewRotation set on PlayerController
	*
	* @param	DeltaTime, time since last frame
	* @param	ViewRotation, current player ViewRotation
	* @param	DeltaRot, player input added to ViewRotation
	*/
	function ProcessViewRotation( float DeltaTime, out Rotator out_ViewRotation, Rotator DeltaRot )
	{
		if( PlayerCamera != None )
		{
			PlayerCamera.ProcessViewRotation( DeltaTime, out_ViewRotation, DeltaRot );
		}

		if ( Pawn != None )
		{	// Give the Pawn a chance to modify DeltaRot (limit view for ex.)
			Pawn.ProcessViewRotation( DeltaTime, out_ViewRotation, DeltaRot );
		}
		else
		{
			// If Pawn doesn't exist, limit view

			// Add Delta Rotation
			out_ViewRotation	+= DeltaRot;
			out_ViewRotation	 = LimitViewRotation(out_ViewRotation, -16384, 16383 );
		}
	}


	
	function rotator pawnRotate(rotator currentRotation, float DeltaTime)
	{	
		
		local rotator targetRotation, viewRotation;

	bForceNetUpdate = TRUE; // Force replication
		
		targetRotation = currentRotation; 

		targetRotation.Yaw = targetRotation.Yaw + SmoothPawnYaw();	
		targetRotation.Roll = targetRotation.Roll + SmoothPawnRoll();
		targetRotation.Pitch = targetRotation.Pitch + SmoothPawnUp();
		
		return targetRotation;
	}
	
/*
	function PlayerMove( float DeltaTime )
	{
	local rotator targetRotation;
	local rotator cameraRotation;
	local rotator currentRotation;
	local rotator interpRotation;
	local float forwardDirection;
	
	
		Super.PlayerMove( DeltaTime);

		// Add in pawn roll with strafe
        currentRotation = Pawn.Rotation;

		`log("CurrentRoll = "$currentRotation.Roll);
		
		If(PlayerInput.aForward > 0)
		{
			forwardDirection = 1.0;
		} else {
			forwardDirection = 0.0;
		}
		
		targetRotation = currentRotation; 
		//targetRotation.Yaw = targetRotation.Yaw +( 1.1 * 0.01 * PlayerInput.aStrafe) * forwardDirection;
		cameraRotation = currentRotation;
		cameraRotation.Yaw = targetRotation.Yaw +( 1.1 * 0.01 * PlayerInput.aStrafe) * forwardDirection;
		 
		// Rotate Camera with Yaw from Strafe value
		SetRotation(RInterpTo(Rotation, cameraRotation, DeltaTime, 90000));
	
		targetRotation.Yaw = targetRotation.Yaw +( 1.1 * PlayerInput.aStrafe) * forwardDirection;	
		targetRotation.Roll = targetRotation.Roll + 2.0 * PlayerInput.aStrafe;

		// Set Pawn's visible rotation with roll and yaw based on Strafe values
        currentRotation = RInterpTo(currentRotation, targetRotation, DeltaTime, 90000);
	    
		
		`log("Tweaked Roll= "$currentRotation.Roll);
		
		//SetRotation(currentRotation);			
		//UpdateRotation( DeltaTime );
			
		// Add OSC Rotation	
		//OSCPawn(Pawn).FaceRotation(currentRotation, DeltaTime);		
		//Pawn.SetRotation(currentRotation);
		OSCPawn(Pawn).UpdatePawnRotation(currentRotation);
		
		
		`log("aForward: "$PlayerInput.aForward);
		`log("aStrafe: "$PlayerInput.aStrafe);
		//`log("aMouseY: "$PlayerInput.aMouseY);
		//`log("aMouseX: "$PlayerInput.aMouseX);
		//`log("aLookUp:  "$PlayerInput.aLookUp);
		
		
	}
*/	
}

state OSCPlayerMoving
{

/* **************************************************************************		*/
// COMMENTED OUT FOR FIXING	
// 4/30/13
/* ************************************************************************** */

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
	/**/
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
		//local rotator			OSCCameraRotation;
		local rotator           OSCPlayerRotation;
		local bool				bSaveJump;
		local bool				bOSCJump;
		local float				OSCJump;
		//local int				OSCCurrentID;
		local float 			OSCPitch, OSCYaw, OSCRoll, OSCSetPitch, OSCSetYaw, OSCSetRoll;
		local vector			OSCVector; 
		local float 			OSCGroundSpeed, OSCAirSpeed;
		local vector			OSCCamera;
		local float				OSCStop;

		
		SetMode(localOSCPlayerStateValuesStruct.mode);
				
		if (localOSCPlayerTeleportStruct.teleport > 0)
		{		
			teleportPawn_(localOSCPlayerTeleportStruct.teleportx, localOSCPlayerTeleportStruct.teleporty, localOSCPlayerTeleportStruct.teleportz);
		}	
		
		OSCVector.X = localOSCPlayerStateValuesStruct.x;		
		OSCVector.Y = localOSCPlayerStateValuesStruct.y;
		OSCVector.Z = localOSCPlayerStateValuesStruct.z;
		OSCGroundSpeed = localOSCPlayerStateValuesStruct.speed;
		OSCAirSpeed = localOSCPlayerStateValuesStruct.airspeed;
		OSCJump = localOSCPlayerDiscreteValuesStruct.jump;
		OSCStop = localOSCPlayerDiscreteValuesStruct.stop;
			
		//OSCPitch = localOSCPlayerStateValuesStruct.pitch;
		//OSCYaw  = localOSCPlayerStateValuesStruct.yaw;
		//OSCRoll = localOSCPlayerStateValuesStruct.roll;
			
		OSCSetPitch = localOSCPlayerStateValuesStruct.setpitch;
		OSCSetYaw  = localOSCPlayerStateValuesStruct.setyaw;
		OSCSetRoll = localOSCPlayerStateValuesStruct.setroll;
		
		if( (OSCSetPitch > 0) || (OSCSetYaw > 0) || (OSCSetRoll > 0) )
		{
			// Pitch, Yaw and Roll values are to be treated as world absolute rotations
			OSCPlayerRotation.Pitch = localOSCPlayerStateValuesStruct.pitch;
			OSCPlayerRotation.Yaw = localOSCPlayerStateValuesStruct.yaw;
			OSCPlayerRotation.Roll = localOSCPlayerStateValuesStruct.roll;
			
		} else {
		
			OSCPlayerRotation = Rotation;
			OSCPlayerRotation.Pitch += localOSCPlayerStateValuesStruct.pitch;
			OSCPlayerRotation.Yaw  += localOSCPlayerStateValuesStruct.yaw;
			OSCPlayerRotation.Roll += localOSCPlayerStateValuesStruct.roll;
		}
		
//		OSCVector.X = localOSCPlayerStateValuesStruct.x;		
//		OSCVector.Y = localOSCPlayerStateValuesStruct.y;
//		OSCVector.Z = localOSCPlayerStateValuesStruct.z;
//		OSCGroundSpeed = localOSCPlayerStateValuesStruct.speed;
//		OSCAirSpeed = localOSCPlayerStateValuesStruct.airspeed;
//		OSCJump = localOSCPlayerDiscreteValuesStruct.jump;
//		OSCStop = localOSCPlayerDiscreteValuesStruct.stop;
		
		// Add OSC speed control
		Pawn.GroundSpeed = OSCGroundSpeed;		
		Pawn.AirSpeed = OSCGroundSpeed;				// for now, reusing ground speed


		
	//	OSCCameraRotation.Pitch=localOSCScriptCameramoveStruct.pitch;
	//	OSCCameraRotation.Roll=localOSCScriptCameramoveStruct.roll;
	//	OSCCameraRotation.Yaw=localOSCScriptCameramoveStruct.yaw;
		
//		OSCCamera.X = localOSCScriptCameramoveStruct.x;
//		OSCCamera.Y = localOSCScriptCameramoveStruct.y;
//		OSCCamera.Z = localOSCScriptCameramoveStruct.z;
	
//		OSCPawn(Pawn).setOSCCamera(OSCCamera);
		//OSCPawn(Pawn).OSCRotation = OSCPlayerRotation;
		
		
//		`log("Camera Rotation: "$OSCCameraRotation.Pitch$", "$OSCCameraRotation.Yaw$", "$OSCCameraRotation.Roll);
//		`log("Player Rotation: "$localOSCPlayerStateValuesStruct.Pitch$", "$localOSCPlayerStateValuesStruct.Yaw$", "$localOSCPlayerStateValuesStruct.Roll);
//		`log("OSC Player Rotation: "$OSCPlayerRotation.Pitch$", "$OSCPlayerRotation.Yaw$", "$OSCPlayerRotation.Roll);
		
		
		if (OSCJump > 0.0) {
			bOSCJump = true;
			bPressedJump = true;
		}

		if( Pawn == None ) {
			GotoState('Dead');
		}
		else {
			GetAxes(Pawn.Rotation,X,Y,Z);

			// Update acceleration.
//			NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
//			NewAccel.Z = 0;

			NewAccel = OSCVector.X*X + OSCVector.Y*Y + OSCVector.Z*Z;
			NewAccel = Pawn.AccelRate * Normal(NewAccel);

			if(OSCStop == 1) {
				NewAccel.X = 0;
				NewAccel.Y = 0;
				NewAccel.Z = 0;
			}
			
			if (IsLocalPlayerController())
			{
				AdjustPlayerWalkingMoveAccel(NewAccel);
			}
			
			// Update rotation.
			OldRotation = Rotation;			
			SetRotation(OSCPlayerRotation);			
			//UpdateRotation( DeltaTime );
			
			bDoubleJump = false;
	
			// Add OSC Rotation	
			OSCPawn(Pawn).FaceRotation(OSCPlayerRotation, DeltaTime);
			//Pawn.FaceRotation(RInterpTo(OldRotation, OSCCameraRotation, DeltaTIme, 90000, true), DeltaTime);
			
			if(bOSCJump) {
				Pawn.JumpZ = OSCJump;
				Pawn.DoJump(bUpdating);
				bOSCJump = false;
			}
			
			if( bPressedJump && Pawn.CannotJumpNow() ) {
				bSaveJump = true;
				bPressedJump = false;
			}
			else {
				bSaveJump = false;
			}

//			if( Role < ROLE_Authority ) {
//				ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - OSCCameraRotation);
//				ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - OSCPlayerRotation);
//			}
//			else
//			{
//				ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - OSCCameraRotation);
				ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - OSCPlayerRotation);
//			}
			bPressedJump = bSaveJump;
			//bPressedJump = bOSCJump;
		}
	}
	
/*
//	function UpdateRotation( float DeltaTime )
//	{
//		local Rotator	DeltaRot, ViewRotation;
//		
//		ViewRotation = Rotation;
//		If (Pawn !=none )
//		{
//			Pawn.SetDesiredRotation(ViewRotation);	
//		}
//		
//		//Calculate Delta to be appled of VIewRotation
//		DeltaRot.Yaw = 0;
//		DeltaRot.Pitch = PlayerInput.aLookUp;
//		ProcessViewRotation ( DeltaTime, ViewRotation, DeltaRot);
//		SetRotation(ViewRotation);	
//	}
	


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
*/
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
	//`log("AutoState: PlayerWaiting:: OSCPlayerControllerDLL");
	
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
	
simulated function setOSCScriptCameramoveData(OSCScriptCameramoveStruct fstruct)
{
	localOSCScriptCameramoveStruct = fstruct;
	
	// Set data for OSCPawn to use:
	if(Pawn!=None) {
		OSCPawn(Pawn).localOSCScriptCameramoveStruct.X = localOSCScriptCameramoveStruct.X;
		OSCPawn(Pawn).localOSCScriptCameramoveStruct.Y = localOSCScriptCameramoveStruct.Y;
		OSCPawn(Pawn).localOSCScriptCameramoveStruct.Z = localOSCScriptCameramoveStruct.Z;
		OSCPawn(Pawn).localOSCScriptCameramoveStruct.Pitch = localOSCScriptCameramoveStruct.Pitch;
		OSCPawn(Pawn).localOSCScriptCameramoveStruct.Yaw = localOSCScriptCameramoveStruct.Yaw;
		OSCPawn(Pawn).localOSCScriptCameramoveStruct.Roll = localOSCScriptCameramoveStruct.Roll;
		OSCPawn(Pawn).localOSCScriptCameramoveStruct.Speed = localOSCScriptCameramoveStruct.Speed;
	}

/*	
	`log("localOSCScriptCameramoveStruct.x:  "$localOSCScriptCameramoveStruct.x);
	`log("localOSCScriptCameramoveStruct.y:  "$localOSCScriptCameramoveStruct.y);
	`log("localOSCScriptCameramoveStruct.z:  "$localOSCScriptCameramoveStruct.z);
	`log("localOSCScriptCameramoveStruct.pitch:  "$localOSCScriptCameramoveStruct.pitch);
	`log("localOSCScriptCameramoveStruct.yaw:  "$localOSCScriptCameramoveStruct.yaw);
	`log("localOSCScriptCameramoveStruct.roll:  "$localOSCScriptCameramoveStruct.roll);
	`log("localOSCScriptCameramoveStruct.speed:  "$localOSCScriptCameramoveStruct.speed);
*/
}

simulated function setOSCScriptPlayerTeleportData(OSCScriptPlayerTeleportStruct fstruct)
{
	localOSCScriptPlayerTeleportStruct = fstruct;
	OSCScriptPlayerTeleportStructs[localOSCScriptPlayerTeleportStruct.id] = localOSCScriptPlayerTeleportStruct;
}


simulated function callTeleport()
{
//	`log("IN TELEPORT **************************************************************");

	
	if(localOSCScriptPlayerTeleportStruct.teleport == 1.0)
	{
//		`log("TELEPORT == 1.0");
		teleportPawn_(localOSCScriptPlayerTeleportStruct.teleportx, localOSCScriptPlayerTeleportStruct.teleporty, localOSCScriptPlayerTeleportStruct.teleportz);
	}
}

simulated function setOSCPlayerData()
{
	if(Pawn !=None) {
  	  localOSCPlayerStateValuesStruct = getOSCPlayerStateValues(OSCPawn(Pawn).getUID());
	  localOSCPlayerDiscreteValuesStruct = getOSCPlayerDiscreteValues(OSCPawn(Pawn).getUID());
	  localOSCPlayerTeleportStruct = getOSCPlayerTeleportValues(OSCPawn(Pawn).getUID());
	}
	//localOSCConsoleCommandStruct.command = getOSCConsoleCommand();
	
	/*
	`log("setOSCPlayerData::localOSCPlayerStateValuesStruct.X = "$localOSCPlayerStateValuesStruct.X);
	`log("setOSCPlayerData::localOSCPlayerStateValuesStruct.Y = "$localOSCPlayerStateValuesStruct.Y);
	`log("setOSCPlayerData::localOSCPlayerStateValuesStruct.Z = "$localOSCPlayerStateValuesStruct.Z);
	`log("setOSCPlayerData::localOSCPlayerStateValuesStruct.Pitch = "$localOSCPlayerStateValuesStruct.Pitch);
	`log("setOSCPlayerData::localOSCPlayerStateValuesStruct.Yaw = "$localOSCPlayerStateValuesStruct.Yaw);
	`log("setOSCPlayerData::localOSCPlayerStateValuesStruct.Roll = "$localOSCPlayerStateValuesStruct.Roll);
	`log("setOSCPlayerData::localOSCPlayerStateValuesStruct.Speed = "$localOSCPlayerStateValuesStruct.Speed);
	*/
}
	
event PlayerTick( float DeltaTime )
{

	setOSCPlayerData();
	callConsoleCommand(getOSCConsoleCommand());

	//debug
calculateSpeed();

// update speed with + or - key modifiers
setPlayerSpeed();
	
//	`log("Pawn 1 Speed: "$OSCScriptPawnBotStructs[1].speed);
//	`log("Pawn 2 Speed: "$OSCScriptPawnBotStructs[2].speed);
//	`log("Pawn 3 Speed: "$OSCScriptPawnBotStructs[3].speed);

	setOSCScriptCameramoveData(getOSCScriptCameramove());	
	
	if(oscmoving) {
		//localOSCFingerControllerStruct = getOSCFingerController();
		//setOSCFingerTouches(localOSCFingerControllerStruct);
		setOSCScriptPlayerTeleportData(getOSCScriptPlayerTeleport());
	}

	Super.PlayerTick(DeltaTime);
}

simulated function setPawnBotState(bool val)
{
	// Set each PawnBot to be sending OSC
	local OSCPawnBot P;

	foreach WorldInfo.AllActors(class 'OSCPawnBot', P) {
		P.sendingOSC = val;
	}

}

simulated function setOSCBotState(bool val) {
	// Set each PawnBot to be sending OSC
	local OSCBot P;

	foreach WorldInfo.AllActors(class 'OSCBot', P) {
		P.sendingOSC = val;
	}
}

function AddOnlineDelegates(bool bRegisterVoice) {
}


replication
{
//	if (bNetDirty && Role==ROLE_Authority) {
	//	flying;
//	}
}

/*
	// Things the server should send to the client.
   if ( bNetDirty && (Role == Role_Authority) )
      Score, Deaths, bHasFlag, PlayerLocationHint,
      PlayerName, Team, TeamID, bIsFemale, bAdmin,
      bIsSpectator, bOnlySpectator, bWaitingPlayer, bReadyToPlay,
      StartTime, bOutOfLives, UniqueId;
   if ( bNetDirty && (Role == Role_Authority) && !bNetOwner )
      PacketLoss, Ping;
   if ( bNetInitial && (Role == Role_Authority) )
      PlayerID, bBot;
	  
}
*/
defaultproperties 
{
	OSCBotCount=0;
	OSCPawnBotCount=0;
	//CharacterClass=class'UDKOSC.OSCFamilyInfo_OSCPawnBot'
	BehindView=true;
	pawnTurnThreshold = 800.0		;
	
	maxAirSpeed = 4000.0;					// total speed (increment +- base air speed)
	minAirSpeed = 0.0;							
	speedArraySizeMax = 40;				// size of averaging array for AirSpeed
	airSpeedIncrement = 2000.0;
	
//	transformedMesh=SkeletalMesh'CH_IronGuard_Male.Mes h.SK_CH_IronGuard_MaleA'
//	transformedAnimTree=AnimTree'CH_AnimHuman_Tree.AT_ CH_Human'
//	transformedAnimSet(0)=AnimSet'CH_AnimHuman.Anims.K _AnimHuman_BaseMale'
//	transformedPhysicsAsset=PhysicsAsset'CH_AnimCorrup t.Mesh.SK_CH_Corrupt_Male_Physics'

	// CUSTOM CAMERA TESTING
//	CameraClass=class'OSCCamera'
}