class OSCProj_SeekingRocket extends UTProj_SeekingRocket
	config(UT3OSC)
	DLLBind(oscpack_1_0_2);

	
	
var int id;
	
var OSCParams OSCParameters;
var string OSCHostname;
var int OSCPort;

var float OSCNewSpeed;
var bool 	bOSCSetSpeed;
var OSCProj_ShockBall OSCSeekTarget;
var int tickcount;
var bool Incoming;
var float SeekRadius;
var float SeekRange;
var bool LockHomingTargets;
var bool bornWithLock;
var() float TurnRate;//in degrees
var int Bounce;
var int wasDestroyed;


//var OSCProj_ShockBall SeekTarget;

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

/*
function Init( Vector Direction )
{
	SetRotation(Rotator(Direction));
	Velocity = Speed * Direction;
}
*/

event PreBeginPlay()
{

	Super.PreBeginPlay();
	OSCParameters = spawn(class'OSCParams');	
	OSCHostname = OSCParameters.getOSCHostname();
	OSCPort = OSCParameters.getOSCPort();	
	tickcount=0;
	//InstigatorController.ShotTarget
}

function sendProjectileState()
{
	
	Local vector loc, norm, end;
	Local TraceHitInfo hitInfo;
	Local Actor traceHit;
	local ProjectileStateStruct psStruct;
	
	end = Location + normal(vector(Rotation))*32768; // trace to "infinity"
	traceHit = trace(loc, norm, end, Location, true,, hitInfo);

	// By default only 4 console messages are shown at the time
 	//ClientMessage("Hit: "$traceHit$"  class: "$traceHit.class.outer.name$"."$traceHit.class);
 	//ClientMessage("Location: "$Location.X$","$Location.Y$","$Location.Z);
 	//ClientMessage("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
	//ClientMessage("Component: "$hitInfo.HitComponent);

	psStruct.Hostname = OSCHostname;
	psStruct.Port = OSCPort;	
	psStruct.ProjName = ""$self.Name;
	psStruct.ProjType = "seekingrocket";
	psStruct.LocX = Location.X;
	psStruct.LocY = Location.Y;
	psStruct.LocZ = Location.Z;
	psStruct.Size = DrawScale;   
	psStruct.Bounce = Bounce;
	psStruct.Destroyed = wasDestroyed;
	//psStruct.SeekTarget=SeekTarget;
	
	sendOSCProjectileState(psStruct);
}

defaultproperties
{
	BaseTrackingStrength=10000000.0
	HomingTrackingStrength=10000000.0
	LifeSpan=1000.0
	speed=620.0
	MaxSpeed=620.0
	Damage=0.0
	bSuperSeekAirTargets=false
	bCollideActors=true
	bRotationFollowsVelocity=true
	SeekRadius=500.0
	SeekRange=2000.0
	TurnRate=5.000000
	
	OSCNewSpeed=1.000000
}

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

function setSpeed(float newspeed)
{
	OSCNewSpeed=newspeed;
	bOSCSetSpeed=true;
	maxspeed=OSCNewSpeed;
	speed=OSCNewSpeed;
	
	initialDir = vector(Rotation); 
    Velocity = speed*initialDir;	
}

function setLockHomingTargets(bool val)
{
	LockHomingTargets=val;
}


function setSeekTarget()
{
/** Currently tracked target - if set, projectile will seek it */

	local OSCProj_ShockBall P;
	local OSCProj_ShockBall closestP;
	local float closestDistance;
	local float currentDistance;
	
	closestDistance=-1.0;
	
	//`log("last SeekTarget: "$OSCSeekTarget);
	
    ForEach AllActors(class'OSCProj_ShockBall',P)
    {
        if(FastTrace(P.Location,Location))
         {
               //SeekTarget = P;	
			   //Seeking = P;
			//`log("closestDistance: "$closestDistance);
			//`log("currentDistance: "$currentDistance);
			
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
					//`log("ClosestP: "$closestP.Location);
				}
			}
 //             bHasTarget = true;
         }

	}
		 
	if( closestP!=none)
	{
		OSCSeekTarget=closestP;
		Incoming=True;
		//`log("SEEKED A TARGET:"$closestP.Name);
	}
	//SeekTarget=Instigator.Controller;
}

// From Projectile.uc
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	//`log("ProcessTouch: "$Other);
	
	// Add SeekTarget to the list of actors that won't trigger explode
	//if ( Other != Instigator )
	//	Explode( HitLocation, HitNormal );
	
	if(Other==OSCSeekTarget) {
	 
		//`log("Other==SeekTarget");
		//TA = Instigator.Controller.PickTarget(class'Pawn', BestAim, BestDist, Location, 1000.0);
		//SeekTarget=None;
		
		//setSeekTarget();
		//setBase(SeekTarget);
		//AdjustLockTarget(SeekTarget);
		//CheckTargetLock();
		//GotoState('Homing');
		
	}
		
}
/*



			// We didn't hit a valid target, have the controller attempt to pick a good target
			BestAim = ((UDKPlayerController(Instigator.Controller) != None) && UDKPlayerController(Instigator.Controller).bConsolePlayer) ? ConsoleLockAim : LockAim;
			BestDist = 0.0;
			TA = Instigator.Controller.PickTarget(class'Pawn', BestAim, BestDist, Aim, StartTrace, LockRange);
			if ( TA != None && CanLockOnTo(TA) )
			{
				BestTarget = TA;
			}
			
			
			*/
/*
var vector ColorLevel;
var vector ExplosionColor;

simulated function ProcessTouch (Actor Other, vector HitLocation, vector HitNormal)
{
	if ( Other != Instigator )
	{
		if ( !Other.IsA('Projectile') || Other.bProjTarget )
		{
			MomentumTransfer = (UTPawn(Other) != None) ? 0.0 : 1.0;
			Other.TakeDamage(Damage, InstigatorController, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType,, self);
			Explode(HitLocation, HitNormal);
		}
	}
}
*/

function calcPursuit(float DeltaTime)
{
	RotateVector( Velocity, OSCSeekTarget.Location - Location, TurnRate, OSCNewSpeed);
	//self.Speed = OSCNewSpeed;
	SetRotation( rotator( Velocity) );
}


function calcPursuitxxx(float DeltaTime)
{
local float angle, lambda, originalAngle, calculatedAngle;
local float MaxAngleDelta;

local vector OSCSeekTargetLocation;
local vector SeekerLocation;

local float angle_degrees;

// http://wiki.beyondunreal.com/Legacy:UnrealScript_Vector_Maths

	`log("OSCSeekTarget, Location: "$OSCSeekTarget$", "$OSCSeekTarget.Location);
	`log("SeekProj.Location: "$Location);
	
	`log("VSize dir value: "$VSize(OSCSeekTarget.Location - Location));

//	Velocity = VSize(Velocity) * Normal(SeekTarget.Location - Location);
//	setRotation(rotator(Velocity));

	// Dot product of 2 vectors is the cosine of the angle between them. Compare angle between projectiles and limit to MaxAngle value
	originalAngle = acos(Normal(OSCSeekTarget.Location) dot Normal(Location)) + 0.00001; 
	
	//SetRotation(Rotator(Direction));
	//Velocity = Speed * Direction;
	
	// Do Angle calcs for maxangle stuff	
	SeekerLocation = Location;
	OSCSeekTargetLocation = OSCSeekTarget.Location;
	//SetRotation(rotator(OSCSeekTargetLocation - SeekerLocation));
	
	calculatedAngle = acos(Normal(OSCSeekTarget.Location) dot Normal(Location)) + 0.00001;
	angle_degrees = acos(Normal(SeekerLocation) dot Normal(OSCSeekTargetLocation)) * 180/pi;
	
	
	MaxAngleDelta = 0.0005;	// 65536 is the total UDK Game units that make up 360 degrees
	
	`log("angle_degrees: "$angle_degrees$", calculatedAngle: "$calculatedAngle);
	
	//if (angle <= MaxAngleDelta || VSize(OSCSeekTargej hnnnnn t.Location - Location) <= 50.0)
//	if(VSize(OSCSeekTarget.Location - Location) <= 100.0)
//	{
//	`log("In A");

	RotateVector( Velocity, OSCSeekTarget.Location - Location, TurnRate, OSCNewSpeed);
	SetRotation( rotator( Velocity) );
			
	If(Incoming) 
	{
		if(VSize(OSCSeekTarget.Location - Location) < SeekRadius )
		{
			`log("We're too close");
			//Velocity.X = 100.0;
			//Velocity.Y = 1000.0;
			//Velocity.Z = 10000.0;
		
			Incoming=False;
		
		} else {
			`log("***********************************************************");
			`log("***********************************************************");
			`log(acos(Normal(SeekerLocation) dot Normal(OSCSeekTargetLocation)) * 180/pi);
			`log("***********************************************************");
			`log("***********************************************************");

			
			//Velocity = Speed * Normal(0.1*(OSCSeekTarget.Location - Location));
			//Velocity = Speed * (Normal(SeekerLocation) dot Normal(OSCSeekTargetLocation));
			//MoveTowards(OSCSeekTarget);
		}
		`log("Velocity Size: "$VSize(Velocity));
 
	
		
		
	//		Velocity = VSize(Velocity)* Normal(OSCSeekTarget.Location - Location);

		//	}
//    else
//    {
//	`log("In B");
//       lambda = MaxAngleDelta / (angle - MaxAngleDelta);
//       Velocity = Normal(((Normal(Vector(Rotation)) * VSize(OSCSeekTarget.Location - Location) + Location) + lambda * OSCSeekTarget.Location) * (1.0 / (1.0 + lambda)) - Location) * VSize(Velocity);
//    }
    //Speed = VSize(Velocity);
    //SetRotation (rotator(Velocity));
	} else {
		if( VSize(OSCSeekTarget.Location - Location) > SeekRange )
		{
			Incoming=True;
		}
	}
}


 /*
simulated function Timer()
{
	if( OSCSeekTarget != None)
	{
		RotateVector( Velocity, OSCSeekTarget.Location - Location, TurnRate * TimerRate );
		SetRotation( rotator( Velocity) );
	}
}
*/
//Rotate vector A towards vector B, an amount of degrees.
static final function RotateVector( out vector A, vector B, float Degree, float lOSCNewSpeed )
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

function calcPursuitx(float DeltaTime)
{

	local Rotator rNewRotation;
	local Vector vNewLocation, vCenter; 
	local float fMaxRange, fDistanceToTarget; 
    local Vector vProjHitLoc; //added this for readbility
	local float MaxAngle;
	
	fMaxRange = 100.0;  //GetTheMaxRange(); 
	fDistanceToTarget = VSize(OSCSeekTarget.Location - Location);

//	if (fDistanceToTarget <= fMaxRange )
//	{
		vProjHitLoc = self.Location;		

		rNewRotation = Rotation; 

		rNewRotation.Yaw = 0;
		rNewRotation.Pitch = 0; 
		rNewRotation.Roll += 9000 * DeltaTime; 



//		vNewLocation = OSCSeekTarget.Location + Normal(Vector(rNewRotation)) * fDistanceToTarget;
		vNewLocation = OSCSeekTarget.Location + Normal(Vector(rNewRotation)) * fDistanceToTarget;

		SetLocation(vNewLocation); 
		SetRotation(rNewRotation);

//	}
}


function calcPursuitsss(float DeltaTime)
{
	local float fDistanceToTarget;
	local Vector newVelocity;
	local float newAngle;
	
	// Distance between fired projectile and its Seeking Target
	fDistanceToTarget = VSize(Location - OSCSeekTarget.Location);
	
	`log("NewDistanceToTarget: "$fDistanceToTarget);
	
	newVelocity = OSCSeekTarget.Velocity + Velocity;
	
	`log("NewVelocity: "$newVelocity);
	
	newAngle = acos(Normal(OSCSeekTarget.Velocity) dot Normal(Velocity));
	
	if(newAngle==0)
	  newAngle += 0.00001;
	  
	`log("NewAngle: "$newAngle);
	`log("Normald Dot Product: "$Normal(OSCSeekTarget.Location) dot Normal(Location));
}


simulated function Tick(float DeltaTime)
{

//    local float angle, distance, lambda;
//	local actor Target;
	
	//SeekTarget=None;
	if(!LockHomingTargets)
   	  setSeekTarget();
	
	
	Super.Tick(DeltaTIme);
	
	if(bOSCSetSpeed)
	{
	  speed=OSCNewSpeed;
	  maxspeed=OSCNewSpeed;
	  bOSCSetSpeed=false;
	}
//	if(!LockHomingTargets)
	  calcPursuit(DeltaTime);

	//Move(Normal(Location - SeekTarget.Location));
	//Move(vect(2,0,0));
	//Acceleration = 16.0 * AccelRate * Normal(SeekTarget.Location - Location);
	//Say("ProjLocation: "$Location.X$","$Location.Y$","$Location.Z);
	//showTargetInfo();
	
/*
	Target = Instigator.Controller.PickTarget(class'OSCProj_ShockBall', DeltaTime, distance, angle);
	
    if (angle <= MaxAngleDelta)
       Velocity = VSize(Velocity) * Normal(SeekTarget.Location - Location);
    else
    {
       lambda = MaxAngleDelta / (angle - MaxAngleDelta);
       Velocity = Normal(((Normal(Vector(Rotation)) * distance + Location) +
                lambda * Target.Location) * (1.0 / (1.0 + lambda)) - Location) * VSize(Velocity);
    }
    Speed = VSize(Velocity);
    SetRotation (rotator(Velocity));
*/


	//`log("SeekTarget: "$SeekTarget);
	sendProjectileState();
	Bounce=0;
}

/*
state Homing
{
	simulated function Timer()
	{
		// do normal guidance to target.
		Acceleration = 16.0 * AccelRate * Normal(SeekTarget.Location - Location);
		
		`log("In homing timer");
		
		if ( ((Acceleration dot Velocity) < 0.f) && (VSizeSq(SeekTarget.Location - Location) < Square(0.5 * 200.0)) )
		{
			//Explode(Location, vect(0,0,1));
		}
	}

	simulated function BeginState(name PreviousStateName)
	{
		Timer();
		SetTimer(0.1, true);
	}
}
*/

simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	MomentumTransfer = 0.0;

	
	// check to make sure we didn't hit a pawn

	if ( Pawn(Wall) == none )
	{
		Velocity = 1.0*(( Velocity dot HitNormal ) * HitNormal * -2.0 + Velocity);   // Reflect off Wall w/damping
		Speed = VSize(Velocity);
		Bounce=1;
/*
		if (Velocity.Z > 400)
		{
			Velocity.Z = 0.5 * (400 + Velocity.Z);
		}
*/
		// If we hit a pawn or we are moving too slowly, explod
/*
		if ( Speed < 20 || Pawn(Wall) != none )
		{
			ImpactedActor = Wall;
			SetPhysics(PHYS_None);
		}
*/		
	}
	

	
	//Super(UTProjectile).HitWall(HitNormal, Wall, WallComp);
}

simulated event PostBeginPlay()
{
//`log("This is a test"$self.Tag$"");


//	id = WorldInfo.ProjectileList;

/*	
	local int temp;
	local Projectile P;
	
	foreach WorldInfo.ProjectileList( class 'Projectile', P )
    {
		temp = temp + 1;
	}
	self.id = temp;
*/	
`log("projectile fired: "$self.Name$", bornWithLock: "$bornWithLock);
	Super.PostBeginPlay();
	
	
	if(LockHomingTargets && !bornWithLock)
	  setSeekTarget();
	//GotoState('Homing');
	
	// Add self to the list of world projectiles, saving previous list head as our next pointer
//	NextProjectile = WorldInfo.ProjectileList;
//	WorldInfo.ProjectileList = self;
}

function Destroyed()
{
	wasDestroyed=1;
	sendProjectileState();
	Super.Destroyed();
	`log("Destroyed");
}
/*
simulated function SpawnFlightEffects()
{
	Super.SpawnFlightEffects();
	if (ProjEffects != None)
	{
		ProjEffects.SetVectorParameter('LinkProjectileColor', ColorLevel);
	}
}


simulated function SetExplosionEffectParameters(ParticleSystemComponent ProjExplosion)
{
	Super.SetExplosionEffectParameters(ProjExplosion);
	ProjExplosion.SetVectorParameter('LinkImpactColor', ExplosionColor);
}

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Projectile'
	ProjExplosionTemplate=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Impact'
	MaxEffectDistance=7000.0

	Speed=1400
	MaxSpeed=5000
	AccelRate=3000.0

	Damage=26
	DamageRadius=0
	MomentumTransfer=0
	CheckRadius=26.0

	MyDamageType=class'UTDmgType_LinkPlasma'
	LifeSpan=3.0
	NetCullDistanceSquared=+144000000.0

	bCollideWorld=true
	DrawScale=1.2

	ExplosionSound=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_ImpactCue'
	ColorLevel=(X=1,Y=1.3,Z=1)
	ExplosionColor=(X=1,Y=1,Z=1);
}
*/

/*

class OSCHomingProj_ShockBall extends OSCProj_ShockBall;
	config(UT3OSC)
	DLLBind(oscpack_1_0_2);
	
	
simulated function Tick(float DeltaTime)
{
    local Pawn Target;
    local float angle, distance, lambda;
	
	Super.Tick(DeltaTIme);

    Target = PickTarget(DeltaTime, distance, angle);
    if ((Target == None) || (angle == 0.0))
       return;
 
    if (angle <= MaxAngleDelta)
       Velocity = VSize(Velocity) * Normal(Target.Location - Location);
    else
    {
       lambda = MaxAngleDelta / (angle - MaxAngleDelta);
       Velocity = Normal(((Normal(Vector(Rotation)) * distance + Location) +
                lambda * Target.Location) * (1.0 / (1.0 + lambda)) - Location) * VSize(Velocity);
    }
    Speed = VSize(Velocity);
    SetRotation (rotator(Velocity));
}


   local OSCProj_ShockBall oscSB;
   local float angle, distance, lambda;

   angle = 
   if ((SeekTarget == None) || (angle == 0.0))
     return;

  // get angle between 2 vectors
  
	


*/