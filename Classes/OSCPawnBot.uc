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

dllimport final function OSCScriptPlayermoveStruct getOSCScriptPlayermove();
dllimport final function OSCScriptPlayerTeleportStruct getOSCScriptPlayerTeleport();
dllimport final function sendOSCPawnState(PawnStateStruct a);
dllimport final function testt(float thisx);
// ************************************************************************************************

DefaultProperties
{
	uid=-1;
	bRollToDesired=true;
	RemoteRole=ROLE_SimulatedProxy; // just for testing crashing bug
}

simulated event PreBeginPlay()
{
	Super.PreBeginPlay();
	OSCParameters = spawn(class'OSCParams');	
	OSCHostname = OSCParameters.getOSCHostname();
	OSCPort = OSCParameters.getOSCPort();	
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
	// Call this Pawn's Controller's playertick method
	OSCPawnController(Controller).PlayerTick(DeltaTime);

	Super.Tick(DeltaTIme);

	if(sendingOSC)
	{
		`log("Sending OSC from PawnBot #"$uid);
		sendPawnState();
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
