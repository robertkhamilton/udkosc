class OSCKActorFromStatic extends KActorFromStatic
	placeable
	config(UDKOSC)
	DLLBind(oscpack_1_0_2); 
	
var float lastX;
var float lastY;
var float lastZ;

struct PlayerStateStruct
{
	var string Hostname;
	var int Port;
	var string PlayerName;
	var float LocX;
	var float LocY;
	var float LocZ;
	var bool crouch;
};

dllimport final function sendOSCPlayerState(PlayerStateStruct a);

function sendPlayerState()
{
	
	//Local vector loc, norm, end;
	//Local TraceHitInfo hitInfo;
	//Local Actor traceHit;
	local PlayerStateStruct psStruct;
	
	//end = Location + normal(vector(Rotation))*32768; // trace to "infinity"
	//traceHit = trace(loc, norm, end, Location, true,, hitInfo);

	// By default only 4 console messages are shown at the time
 	//ClientMessage("Hit: "$traceHit$"  class: "$traceHit.class.outer.name$"."$traceHit.class);
 	//ClientMessage("Location: "$Location.X$","$Location.Y$","$Location.Z);
 	//ClientMessage("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
	//ClientMessage("Component: "$hitInfo.HitComponent);
	
	// Populate pcStruct with tracehit info using rkh String format hack
	psStruct.PlayerName ="OBJECT";
	psStruct.LocX = Location.X;
	psStruct.LocY = Location.Y;
	psStruct.LocZ = Location.Z;
	
	sendOSCPlayerState(psStruct);
}
event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
{
	`log("Bump: "$Location.X$", "$Location.Y$", "$Location.Z);
	Super.Bump(Other, OtherComp, HitNormal);

}

event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex )
{
	`log("RigidBodyCollision: "$Location.X$", "$Location.Y$", "$Location.Z);
	Super(Actor).RigidBodyCollision(HitComponent, OtherComponent, RIgidCollisionData, ContactIndex);

}

/** Called when shot. */
simulated function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	`log("TakeDamage: "$Location.X$", "$Location.Y$", "$Location.Z);
	Super(Actor).TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

/** Called when overlapped by car/player */
simulated function Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	`log("Touch: "$Location.X$", "$Location.Y$", "$Location.Z);
	Super(Actor).Touch(Other, OtherComp, HitLocation, HitNormal);
}

event ApplyImpulse( Vector ImpulseDir, float ImpulseMag, Vector HitLocation, optional TraceHitInfo HitInfo, optional class<DamageType> DamageType )
{

	`log("OSCKActorFromStatic::ApplyImpulse: "$Location.X$", "$Location.Y$", "$Location.Z);
	Super.ApplyImpulse(ImpulseDir, ImpulseMag, HitLocation, HitInfo);
	
}

simulated function Tick(float DeltaTime)
{
	if(Location.X != lastX) 
	{
		`log("Tick: "$Location.X$", "$Location.Y$", "$Location.Z);
	}
	lastX = Location.X;
	lastY = Location.Y;
	lastZ = Location.Z;
	
	Super.Tick(DeltaTIme);
	//showTargetInfo();
	//sendPlayerState();
}