/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class OSCProj_LinkPlasma extends UTProj_LinkPlasma
	config(UT3OSC)
	DLLBind(oscpack_1_0_2); // extends UTProjectile;
	
var int id;
	
var OSCParams OSCParameters;
var string OSCHostname;
var int OSCPort;


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
};

dllimport final function sendOSCProjectileState(ProjectileStateStruct a);

event PreBeginPlay()
{

	Super.PreBeginPlay();
	OSCParameters = spawn(class'OSCParams');	
	OSCHostname = OSCParameters.getOSCHostname();
	OSCPort = OSCParameters.getOSCPort();	
	
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
	psStruct.ProjType = "plasma";
	psStruct.LocX = Location.X;
	psStruct.LocY = Location.Y;
	psStruct.LocZ = Location.Z;
	
	sendOSCProjectileState(psStruct);
}

defaultproperties
{
bBounce=true

Speed=10
MaxSpeed=50
AccelRate=30.0

    LifeSpan=118.000000
    bRotationFollowsVelocity=true
	CheckRadius=0.0
	BaseTrackingStrength=1.0
	HomingTrackingStrength=16.0
	
	bCollideWorld=true
	DrawScale=3.2
	Physics=PHYS_Falling
	CustomGravityScaling=0.0	
	TickFrequency=0	/** float: Actor: How often to tick this actor. If 0, tick every frame */
}

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

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTIme);
	//Say("ProjLocation: "$Location.X$","$Location.Y$","$Location.Z);
	//showTargetInfo();
	sendProjectileState();
}

simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	MomentumTransfer = 0.0;

	
	// check to make sure we didn't hit a pawn

	if ( Pawn(Wall) == none )
	{
		Velocity = 1.0*(( Velocity dot HitNormal ) * HitNormal * -2.0 + Velocity);   // Reflect off Wall w/damping
		Speed = VSize(Velocity);
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
`log("projectile fired: "$self.Name);

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
	Super.PostBeginPlay();

	// Add self to the list of world projectiles, saving previous list head as our next pointer
//	NextProjectile = WorldInfo.ProjectileList;
//	WorldInfo.ProjectileList = self;
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
