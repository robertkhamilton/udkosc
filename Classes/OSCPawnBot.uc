class OSCPawnBot extends UTPawn
 notplaceable
 DLLBind(oscpack_1_0_2);

var int uid;			// unique pawn ID tracked in OSCPlayerControllerDLL.uc
var bool sendingOSC;	// toggle to send OSC for this pawn
var bool receivingOSC; 	// receiving OSC flag to prevent multiple calls to oscpack to instantiate listener threads
var bool sendDeltaOSC; // whether OSC messages are sent continuously or only on vector deltas


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


var OSCScriptPlayermoveStruct localOSCScriptPlayermoveStruct;
var OSCScriptPlayerTeleportStruct localOSCScriptPlayerTeleportStruct;

dllimport final function OSCScriptPlayermoveStruct getOSCScriptPlayermove();
dllimport final function OSCScriptPlayerTeleportStruct getOSCScriptPlayerTeleport();
dllimport final function sendOSCPlayerState(PlayerStateStruct a);

// ************************************************************************************************

DefaultProperties
{
	uid=-1;
	bRollToDesired=true
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
