class OSCProj_SeekingShockBall extends UTProj_ShockBall
	config(UDKOSC)
	DLLBind(oscpack_1_0_2);

	
	
var int id;
	
var OSCParams OSCParameters;
var string OSCHostname;
var int OSCPort;

var float OSCNewSpeed;
var bool 	bOSCSetSpeed;
//var OSCProj_ShockBall OSCSeekTarget;
var Actor OSCSeekTarget;
var bool hasSeekTarget;
var vector seekLocation;
var int tickcount;
var bool Incoming;
var float SeekRadius;
var float SeekRange;
var bool LockHomingTargets;
var bool bornWithLock;
var() float TurnRate;//in degrees
var string className;
var int instanceCount;
var int wasDestroyed;
var int Bounce;
var string seekTargetClassName;
var string seekTargetVolumeType;

var ProjectileStateStruct lastProjectile;

struct ProjectileStateStruct
{
	var string Hostname;
	var int Port;
	var string ProjName;
	var string ProjType;
	var int ProjID;
	var float LocX;
	var float LocY;
	var float LocZ;
	var float Size;
	var int Bounce;
	var int Destroyed;
};

dllimport final function sendOSCProjectileState(ProjectileStateStruct a);


defaultproperties
{
	BaseTrackingStrength=10000000.0
	HomingTrackingStrength=10000000.0
	LifeSpan=10.0 //was 1000
	speed=0.0 //was 620.0
	MaxSpeed=620.0
	Damage=0.0
	bSuperSeekAirTargets=false
	bCollideActors=true
	bRotationFollowsVelocity=true
	SeekRadius=500.0
	SeekRange=2000.0
	TurnRate=5.000000
	OSCNewSpeed=1.000000
	DrawScale=.6
	ProjectileLightClass=class'UDKOSC.OSCSeekingShockBallLight'
	seekTargetClassName="OSCProj_ShockBall"
	seekTargetVolumeType="none"
	bCollideComplex=true;
	bNetTemporary = false;
	bUpdateSimulatedPosition=true;	//this did it for the replication
}

simulated event PreBeginPlay()
{

	Super.PreBeginPlay();
	OSCParameters = spawn(class'OSCParams');	
	OSCHostname = OSCParameters.getOSCHostname();
	OSCPort = OSCParameters.getOSCPort();	
	//tickcount=0;
	className="OSCProj_SeekingShockBall";
	instanceCount=getID();
	`log("instanceCount="$instanceCount);
	
	TurnRate=OSCPawn(Instigator).getSeekingTurnRate();
	`log("TurnRate = "$TurnRate);
	

}


simulated event PostBeginPlay()
{
`log("projectile fired: "$self.Name$", bornWithLock: "$bornWithLock);
	Super.PostBeginPlay();
	hasSeekTarget=False;
	SeekLocation=Vect(0,0,0);
	if(LockHomingTargets && !bornWithLock)
	  
	  setSeekTarget();

}


simulated function sendProjectileState()
{
	
	Local vector loc, norm, end;
	Local TraceHitInfo hitInfo;
	Local Actor traceHit;
	local ProjectileStateStruct psStruct;
	
	end = Location + normal(vector(Rotation))*32768; // trace to "infinity"
	traceHit = trace(loc, norm, end, Location, true,, hitInfo);

	psStruct.Hostname = OSCHostname;
	psStruct.Port = OSCPort;	
	psStruct.ProjName = ""$self.Name;
	psStruct.ProjType = "seekingShockBall";
	psStruct.ProjID = instanceCount;
	psStruct.LocX = Location.X;
	psStruct.LocY = Location.Y;
	psStruct.LocZ = Location.Z;
	psStruct.Size = DrawScale;
	psStruct.Bounce =Bounce;
	psStruct.Destroyed = wasDestroyed;
	
	if(lastProjectile.LocX!=psStruct.LocX || lastProjectile.LocY!=psStruct.LocY || lastProjectile.LocZ!=psStruct.LocZ || lastProjectile.Size!=psStruct.Size || lastProjectile.Bounce!=psStruct.Bounce || lastProjectile.Destroyed!=psStruct.Destroyed)
	{
		sendOSCProjectileState(psStruct);

		lastProjectile.LocX=psStruct.LocX;
		lastProjectile.LocY=psStruct.LocY;
		lastProjectile.LocZ=psStruct.LocZ;
		lastProjectile.Size=psStruct.Size;
		lastProjectile.Bounce=psStruct.Bounce;
		lastProjectile.Destroyed=psStruct.Destroyed;
	}
	
}


function int getID()
{
	local string myID;
	myID=""$self$"";
	`log("myID: "$myID);
	myID -= className;
	myID -= "_";
	`log("className: "$className);
	`log("post myID: "$myID);
	return int(myID);
}

/*
defaultproperties
{
	ProjFlightTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball'
	ProjExplosionTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball_Impact'
	Speed=1150
	MaxSpeed=1150
	MaxEffectDistance=7000.0
	bCheckProjectileLight=true
	ProjectileLightClass=class'UTGame.UTShockBallLight'

	Damage=55
	DamageRadius=120
	MomentumTransfer=70000

	MyDamageType=class'UTDmgType_ShockBall'
	LifeSpan=8.0

	bCollideWorld=true
	bProjTarget=True

	ComboDamageType=class'UTDmgType_ShockCombo'
	ComboTriggerType=class'UTDmgType_ShockPrimary'

	ComboDamage=215
	ComboRadius=275
	ComboMomentumTransfer=150000
	ComboTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Explo'
	ComboAmmoCost=3
	CheckRadius=40.0
	bCollideComplex=false

	Begin Object Name=CollisionCylinder
		CollisionRadius=16
		CollisionHeight=16
		AlwaysLoadOnClient=True
		AlwaysLoadOnServer=True
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End Object

	bNetTemporary=false
	AmbientSound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireTravelCue'
	ExplosionSound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireImpactCue'
	ComboExplosionSound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_ComboExplosionCue'
	ComboExplosionEffect=class'UTEmit_ShockCombo'
}

*/
public function setBornWithLock(bool val)
{
	bornWithLock = val;
}

function setSeekRadius(float radius)
{
	SeekRadius=radius;
}
function setSeekRange(float range)
{
	SeekRange=range;
}

simulated function setSpeed(float newspeed)
{
	OSCNewSpeed=newspeed;
	bOSCSetSpeed=true;
	maxspeed=OSCNewSpeed;
	speed=newspeed;
	
	initialDir = vector(Rotation); 
    Velocity = speed*initialDir;	
}

function setLockHomingTargets(bool val)
{
	LockHomingTargets=val;
}

// Trigger Volume no longer stores LocationName which was the basis for setting volume targets for seeking projectiles. This is all commented out
// Rob - 4/29/2012

simulated function setSeekTarget()
{
	local string triggerType;

	if(seekTargetClassName=="OSCProj_ShockBall")
	{
	//`log("setSeekTarget: "$seekTargetClassName);
	//	setSeekTargetOSCSB();
	}
	else if(seekTargetClassName=="TriggerVolume")
	{
	//`log("setSeekTarget: "$seekTargetClassName);
	//	setSeekTargetTriggerVol();
	}
	
}

/*
simulated function setSeekTargetTriggerVol()
{
// Currently tracked target - if set, projectile will seek it 
// 		`log("TriggerVolume:LocationName = "$TriggerVolume(OSCSeekTarget).LocationName);

	local TriggerVolume P;
	local TriggerVolume closestP;
	local float closestDistance;
	local float currentDistance;
	local object seekingTarget;
	local actor localActor;
	
	bForceNetUpdate = TRUE; // Force replication
	
	closestDistance=-1.0;

	ForEach AllActors(class'TriggerVolume',P)   
    {
        if(FastTrace(P.Location,Location))
        {
			currentDistance = VSize(Location - P.Location);

			if(InStr(P.LocationName, seekTargetVolumeType)>=0)
			{

				if(closestDistance<0)
				{
					closestDistance = currentDistance;
					closestP = P;
				} else {
				
					if(currentDistance<closestDistance)
					{			
						closestDistance=currentDistance;
						closestP=P;
					}	
				}
			}
        }
	}
	if( closestP!=none)
	{
		OSCSeekTarget=closestP;
		Incoming=True;
	}
	
}
*/
/*
simulated function setSeekTargetOSCSB()
{
/// Currently tracked target - if set, projectile will seek it 
	local OSCProj_ShockBall P;
	local OSCProj_ShockBall closestP;
	local float closestDistance;
	local float currentDistance;
	local object seekingTarget;
	
	bForceNetUpdate = TRUE; // Force replication
	closestDistance=-1.0;

   ForEach AllActors(class'OSCProj_ShockBall',P)   
    {
        if(FastTrace(P.Location,Location))
        {
			currentDistance = VSize(Location - P.Location);
			
			if(closestDistance<0)
			{
				closestDistance = currentDistance;
				closestP = P;
			} else {
				if(currentDistance<closestDistance)
				{
					closestDistance=currentDistance;
					closestP=P;
				}
			}
        }
	}
	if( closestP!=none)
	{
		OSCSeekTarget=closestP;
		Incoming=True;
	}
}
*/

simulated function setSeekLocation(vector targetLocation)
{

	local Actor temp;
	
	bForceNetUpdate = TRUE; // Force replication
	OSCSeekTarget=temp;
	hasSeekTarget=False;
	seekLocation = targetLocation;
}

simulated function targetSeekLocation()
{
	local vector vectorb;
	
	bForceNetUpdate = TRUE; // Force replication
    vectorb = SeekLocation-Location;
		//vectorb = OSCPawn(Instigator).fingerTouchArray[0]-Location;
	RotateVector( Velocity, vectorb, 5.0);
	SetRotation( rotator( Velocity) );

}


// From Projectile.uc
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	
	if(Other==OSCSeekTarget) 
	{
	}
}


simulated function calcPursuit(float DeltaTime)
{
	//RotateVector( Velocity, OSCSeekTarget.Location - Location, TurnRate);
	if ( OSCSeekTarget != None ) 
	{
		RotateVector( Velocity, OSCSeekTarget.Location - Location, OSCPawn(Instigator).getSeekingTurnRate());
		SetRotation( rotator( Velocity) );
	}
}

//Rotate vector A towards vector B, an amount of degrees.
simulated static final function RotateVector( out vector A, vector B, float Degree )
{
	local float Magnitude;
	local vector C;
 
	Degree = Degree * Pi / 180.0;//Convert to radians.
	Magnitude = VSize(A);// * lOSCNewSpeed;
	A = Normal(A);
	B = Normal(B);
 
	if( A Dot B == -1.0 )//Vectors are pointing in opposite directions.
		B.x += 0.0001;//fudge it a little
 
	C = Normal(B - (A Dot B) * A);//This forms a right angle with A
 
	A = Normal( A * Cos(Degree) + C * Sin(Degree) ) * Magnitude;
	
}

simulated function Tick(float DeltaTime)
{

bForceNetUpdate = TRUE; // Force replication

	if(!LockHomingTargets)
	{
	
	  if(	hasSeekTarget)
	 // if(OSCSeekTarget!=Null)
	  {
   	    setSeekTarget();
	  } else {
	    targetSeekLocation();
	  }
	}
	
	Super.Tick(DeltaTIme);
	
	if(bOSCSetSpeed)
	{
	  speed=OSCNewSpeed;
	  maxspeed=OSCNewSpeed;
	  bOSCSetSpeed=false;
	}
	
	if(hasSeekTarget)
	  calcPursuit(DeltaTime);

	if(OSCPawn(Instigator).sendingOSC)
		sendProjectileState();
	
	Bounce=0;
}

simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	MomentumTransfer = 0.0;

	
	// check to make sure we didn't hit a pawn
	if ( Pawn(Wall) == none )
	{
		Velocity = 1.0*(( Velocity dot HitNormal ) * HitNormal * -2.0 + Velocity);   // Reflect off Wall w/damping
		Speed = VSize(Velocity);
		Bounce=1;
	}
}


simulated function Destroyed()
{
bForceNetUpdate = TRUE; // Force replication
	wasDestroyed=1;
	sendProjectileState();
	Super.Destroyed();
	`log("Destroyed");

}