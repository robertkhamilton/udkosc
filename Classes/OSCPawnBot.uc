class OSCPawnBot extends UTPawn
 notplaceable
 DLLBind(oscpack_1_0_2);

var int uid;			// unique pawn ID tracked in OSCPlayerControllerDLL.uc
var bool sendingOSC;	// toggle to send OSC for this pawn
var bool receivingOSC; 	// receiving OSC flag to prevent multiple calls to oscpack to instantiate listener threads
var bool sendDeltaOSC; // whether OSC messages are sent continuously or only on vector deltas
var OSCParams OSCParameters;
var string OSCHostname;
var int OSCPort;
var float lastX;
var float lastY;
var float lastZ;
var bool lastCrouch;

// ************************************************************************************************
// Structs to hold OSC parameter data
// ************************************************************************************************

struct OSCScriptPlayerTeleportStruct
{
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

struct OSCScriptPlayerRotationStruct
{
	var float pitch;
	var float yaw;
	var float roll;
};

struct PawnStateStruct
{
	var string Hostname;
	var int Port;
	var int id;
	var float LocX;
	var float LocY;
	var float LocZ;
	var bool crouch;
};

var OSCScriptPlayermoveStruct localOSCScriptPlayermoveStruct;
var OSCScriptPlayerTeleportStruct localOSCScriptPlayerTeleportStruct;

// vars for pawnbot follow behaviors
var Pawn followTargetPawn;
var OSCPawnBot followTargetPawnBot;
var rotator targetRotation;
var int targetX, targetY, targetZ;
var vector targetAccel;
var bool follow;

dllimport final function OSCScriptPlayermoveStruct getOSCScriptPlayermove();
dllimport final function OSCScriptPlayerTeleportStruct getOSCScriptPlayerTeleport();
dllimport final function sendOSCPawnState(PawnStateStruct a);
dllimport final function testt(float thisx);
// ************************************************************************************************


simulated event PreBeginPlay()
{
	Super.PreBeginPlay();
	OSCParameters = spawn(class'OSCParams');	
	OSCHostname = OSCParameters.getOSCHostname();
	OSCPort = OSCParameters.getOSCPort();	
}

//override to do nothing
simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
}


simulated function followPawnBot()
{
	// Set each PawnBot to be sending OSC	
	local OSCPawnBot P;
	local OSCPawn Pwn;
	local float targetGroundSpeed;
	local float targetAirSpeed;
	
	`log("IN FOLLOWPAWNBOT ********************************************** MY UID = "$uid);
	
	foreach WorldInfo.AllActors(class 'OSCPawnBot', P)
	{
		if(uid > 0) {

	`log("IN FOLLOWPAWNBOT ******************************** UID > 0 *******************");
			if(P.uid==uid-1) //followTargetPawnBot)
			{
	`log("IN FOLLOWPAWNBOT ******************************** P.UID = uid-1 *******************");

			// set this pawn's rotation and speed to match target
				GroundSpeed = P.GroundSpeed;
				targetRotation = rotator( P.Location - Self.Location); //P.Rotation
				
				AirSpeed = P.AirSpeed;		
				targetAccel = P.Acceleration;
				//Self.SetRotation(targetRotation);
				}
		} else {

			`log("IN FOLLOWPAWNBOT ******************************** UID = 0 *******************");

		foreach WorldInfo.AllActors(class 'OSCPawn', Pwn)
			{
				if(Pwn.uid==0)
				{
			`log("IN FOLLOWPAWNBOT ******************************** Pwn.uid ==0 *******************");

					GroundSpeed = Pwn.GroundSpeed;
//					targetRotation = Pwn.Rotation;
				targetRotation = rotator( Pwn.Location - Self.Location); //P.Rotation
					//Self.SetRotation(targetRotation);
					AirSpeed = Pwn.AirSpeed;
					targetAccel = Pwn.Acceleration;
				}
			}
		}
	}
}



simulated reliable client function teleport(float x, float y, float z)
{
	local vector targetVector;
	
	bForceNetUpdate = TRUE; // Force replication
	
	targetVector.X = x;
	targetVector.Y = y;
	targetVector.Z = z;
	
	SetLocation(targetVector);
}


// Prevent pawnbots from taking any damage by overriding TakeDamage
event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
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

auto state OSCMove
{

}


simulated function Tick(float DeltaTime)
{
	// ONLY CALL IF Controller is OSCPawnController
//	if(Self.Controller
	
	//`log("OSCPawnBot Controller Outername: "$Controller.class.outer.name);
	//`log("OSCPawnBot Controller Outername: "$Controller.class);
	/* */
	if(string(Controller.class)== "OSCPawnController") 
	{
	// Call this Pawn's Controller's playertick method
	OSCPawnController(Controller).PlayerTick(DeltaTime);
	}
	
	Super.Tick(DeltaTIme);

	if(sendingOSC)
	{
		//`log("Sending OSC from PawnBot #"$uid);
		sendPawnState();
	}	
	
	// Chained follow call
	if(follow)
	{
		followPawnBot();
	}
}

simulated function sendPawnState()
{
	
	Local vector loc, norm, end;
	Local TraceHitInfo hitInfo;
	Local Actor traceHit;
	local MyPlayerStruct tempVals;
	local PawnStateStruct pStruct;
	local PawnStateStruct testStruct;
	//local OSCParams OSCParameters;
	//local string OSCHostname;
	//local int OSCPort;
	local bool sendOSC;
	
	//end = Location + normal(vector(Rotation))*32768; // trace to "infinity"
	//traceHit = trace(loc, norm, end, Location, true,, hitInfo);

	// Populate pcStruct with tracehit info using rkh String format hack
	pStruct.id = uid;
	pStruct.LocX = Location.X;
	pStruct.LocY = Location.Y;
	pStruct.LocZ = Location.Z;
	//pStruct.Crouch = isCrouching;
	
	OSCHostname = OSCParameters.getOSCHostname();
	OSCPort = OSCParameters.getOSCPort();
	
	//ClientMessage("OSCParameters.getOSCHostname="$OSCHostname$"");
	
	pStruct.Hostname = OSCParameters.getOSCHostname();
	pStruct.Port = OSCParameters.getOSCPort();


	sendOSC=true;

	// only send OSC if nothing has changed (XYZ or crouch)
	if(sendDeltaOSC) {
		if( (Location.X == lastX) && (Location.Y == lastY) && (Location.Z == lastZ))// && (isCrouching==lastCrouch))
			sendOSC=false;
	}

	if(sendOSC)
	{
		`log("Vals - id: "$pStruct.id$", x: "$pStruct.LocX$", y: "$pStruct.LocY$", z: "$pStruct.LocZ$", hostname: "$pStruct.Hostname$", port: "$pStruct.Port);
		testStruct.id = 0;
		testStruct.LocX = 10.0;
		testStruct.LocY = 10.0;
		testStruct.LocZ = 10.0;
		testStruct.Hostname = "10.0.1.100";
		testStruct.Port = 1000;
		//testt(9999.99);
		//sendOSCPawnState(testStruct);
		sendOSCPawnState(pStruct);
	}
	
	// update last xyz coordinates
	lastX = Location.X;
	lastY = Location.Y;
	lastZ = Location.Z;
	//lastCrouch = isCrouching;
}

defaultproperties
{
  uid=-1;
  bRollToDesired=true;
  RemoteRole=ROLE_SimulatedProxy; // just for testing crashing bug

  Begin Object Class=SkeletalMeshComponent Name=OSCMesh_valkordia
//    SkeletalMesh=SkeletalMesh'thesis_characters.trumbruticus.CHA_trumbruticus_skel_01'
 //   PhysicsAsset=PhysicsAsset'thesis_characters.trumbruticus.CHA_trumbruticus_skel_01_Physics'
  //  AnimSets(0)=AnimSet'thesis_characters.trumbruticus.CHA_trumbruticus_skel_01_Anims'
  //  AnimTreeTemplate=AnimTree'thesis_characters.trumbruticus.CHA_trumbruticus_AnimTree_spawntest'
		SkeletalMesh=SkeletalMesh'thesis_characters.valkordia.CHA_valkordia_skel_01'
		PhysicsAsset=PhysicsAsset'thesis_characters.valkordia.CHA_valkordia_skel_01_Physics'
		AnimSets(0)=AnimSet'thesis_characters.valkordia.CHA_valkordia_skel_01_Anims'
		AnimTreeTemplate=AnimTree'thesis_characters.valkordia.CHA_valkordia_AnimTree_01'	
			
//AnimTree'thesis_characters.trumbruticus.CHA_trumbruticus_AnimTree'
  End Object
  Mesh=OSCMesh_valkordia
  Components.Add(OSCMesh_valkordia)	
  
  Begin Object Name=CollisionCylinder
      CollisionRadius=+0021.000000
      CollisionHeight=+0044.000000
	  bDrawBoundingBox=True
  End Object
  
  CylinderComponent=CollisionCylinder
  CylinderComponent.bDrawBoundingBox = True
  
}
