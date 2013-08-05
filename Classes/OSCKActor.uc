class OSCKActor extends KActor
	placeable
	config(UDKOSC)
	DLLBind(oscpack_1_0_2); 
	
var float lastX;
var float lastY;
var float lastZ;

var OSCParams OSCParameters;
var string OSCHostname;
var int OSCPort;

struct MeshStateStruct
{
	var string Hostname;
	var int Port;
	var string MeshName;
	var string MeshType;
	var string MeshEvent;
	var float LocX;
	var float LocY;
	var float LocZ;
};

dllimport final function sendOSCMeshState(MeshStateStruct a);

event PreBeginPlay()
{
	Super.PreBeginPlay();
	OSCParameters = spawn(class'OSCParams');	
	OSCHostname = OSCParameters.getOSCHostname();
	OSCPort = OSCParameters.getOSCPort();	
}

function sendMeshState(string val)

{
	//Local vector loc, norm, end;
	//Local TraceHitInfo hitInfo;
	//Local Actor traceHit;
	local MeshStateStruct mStruct;
	
	//end = Location + normal(vector(Rotation))*32768; // trace to "infinity"
	//traceHit = trace(loc, norm, end, Location, true,, hitInfo);
	
	mStruct.Hostname = OSCHostname;
	mStruct.Port = OSCPort;	
	mStruct.MeshName = ""$self.Name;
	mStruct.MeshType = "mesh";
	mStruct.MeshEvent = val;
	mStruct.LocX = Location.X;
	mStruct.LocY = Location.Y;
	mStruct.LocZ = Location.Z;
	
	sendOSCMeshState(mStruct);
}

event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
{
	`log("Bump: "$Location.X$", "$Location.Y$", "$Location.Z);
	sendMeshState("bump");
	Super.Bump(Other, OtherComp, HitNormal);
}

/** Called when shot. */
simulated function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	`log("TakeDamage: "$Location.X$", "$Location.Y$", "$Location.Z);
	sendMeshState("takedamage");
	Super(Actor).TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

/** Called when overlapped by car/player */
simulated function Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	`log("Touch: "$Location.X$", "$Location.Y$", "$Location.Z);
	sendMeshState("touch");
	Super(Actor).Touch(Other, OtherComp, HitLocation, HitNormal);
}

event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex )
{
	`log("RigidBodyCollision: "$Location.X$", "$Location.Y$", "$Location.Z);
	Super(Actor).RigidBodyCollision(HitComponent, OtherComponent, RIgidCollisionData, ContactIndex);

}


event ApplyImpulse( Vector ImpulseDir, float ImpulseMag, Vector HitLocation, optional TraceHitInfo HitInfo, optional class<DamageType> DamageType )
{

	`log("OSCKActor::ApplyImpulse: "$Location.X$", "$Location.Y$", "$Location.Z);
	Super.ApplyImpulse(ImpulseDir, ImpulseMag, HitLocation, HitInfo);
	
}

simulated function Tick(float DeltaTime)
{
	if( Location.X != lastX ) 
	{
		`log("Tick: "$Location.X$", "$Location.Y$", "$Location.Z);
		sendMeshState("move");
	}
	
	lastX = Location.X;
	lastY = Location.Y;
	lastZ = Location.Z;
	
	Super.Tick(DeltaTIme);
	//showTargetInfo();

}