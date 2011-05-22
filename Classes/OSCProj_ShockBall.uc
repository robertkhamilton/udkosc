class OSCProj_ShockBall extends UTProj_ShockBall
	config(UT3OSC)
	DLLBind(oscpack_1_0_2);
	
var int id;
	
var OSCParams OSCParameters;
var string OSCHostname;
var int OSCPort;

var float OSCNewSpeed;
var bool 	bOSCSetSpeed;
var float lastSpeed;
var float fingerTouchSpeed;		// speed sb will move when finger is pressed on controller
var float TurnRate;	//in degrees

var int currentFingerTouch;
var int Bounce;
var int wasDestroyed;

var bool frozen;

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


defaultproperties
{
bBounce=true

	Speed=100.000000
	MaxSpeed=2000.000000
	AccelRate=0.0
	Damage=0

    LifeSpan=0.000000
    bRotationFollowsVelocity=true
	CheckRadius=1000.0
	BaseTrackingStrength=1.0
	HomingTrackingStrength=1600.0
	
	bCollideWorld=true
	DrawScale=3.2
	Physics=PHYS_Falling
	CustomGravityScaling=0.0	
	TickFrequency=0	/** float: Actor: How often to tick this actor. If 0, tick every frame */
	
	bCollideActors=true
	TurnRate=5.000000
	visible=false;
	currentFingerTouch=-1
	
	bUpdateSimulatedPosition=true;	//this did it for the replication
}

dllimport final function sendOSCProjectileState(ProjectileStateStruct a);


event PreBeginPlay()
{
	Super.PreBeginPlay();
	OSCParameters = spawn(class'OSCParams');	
	OSCHostname = OSCParameters.getOSCHostname();
	OSCPort = OSCParameters.getOSCPort();	
}

simulated exec function freeze()
{
	if(frozen)
	{
		setSpeed(lastSpeed);	
		frozen=false;
	} 
	else
	{
		lastSpeed=speed;
		setSpeed(0);
		frozen=true;
	}
}

function setFingerTouchSpeed(float newspeed)
{
	fingerTouchSpeed = newspeed;
}

function setSpeed(float newspeed)
{
//	`log("InsetSpeed: "$newspeed);
	
	
	OSCNewSpeed=newspeed;
	bOSCSetSpeed=true;
	maxspeed=OSCNewSpeed;
	lastSpeed=speed;
	speed=newspeed;
	
	initialDir = vector(Rotation); 
    Velocity = speed*initialDir;
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
	psStruct.ProjType = "shockball";
	psStruct.LocX = Location.X;
	psStruct.LocY = Location.Y;
	psStruct.LocZ = Location.Z;
	psStruct.Size = DrawScale;
	psStruct.Bounce = Bounce;
	psStruct.Destroyed = wasDestroyed;
	
	sendOSCProjectileState(psStruct);
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

function moveShockBall()
{
	local vector vectorb;
	local int fingerCount;
	local string sbID;
	local int useFinger;
	local int i;
	local int j;
	local int activeFingers[5];
	
	`log("Ball"$self$": currentFingerTouch: "$currentFingerTouch);
	
	// Check which finger sends are still active
	for( i=0; i<5; i++ )
	{
	  if(OSCPawn(Instigator).currentFingerTouches[i]>0)
	  {
	    fingerCount++;
	    activeFingers[i]=1;
	  }
	}
	
	`log("fingerCount: "$fingerCount);
	
	// if no fingers are currently pressed, don't move ball
	if(fingerCount>0)
	{
	  
	  setSpeed(fingerTouchSpeed);
	  
	  // If this ball already has a finger touch, and that finger is still depressed, then don't reassign
	  if(currentFingerTouch<0 || activeFingers[currentFingerTouch]==0)
 	  {
	    sbID=""$self$"";
	    sbID -= "OSCProj_ShockBall_";
	
	   // `log("TESTING MOVE SB ID: "$sbID);

	    useFinger= int(sbID)%5;
	
	   // `log("useFinger: "$useFinger);

	    // Now step through activeFingers array and get the useFinger-ith active finger there
	    i=0;
	    j=-1;
        do
	    {
		  if(activeFingers[i]==1)
		  {
		    j++;
		  }
		
		  // increment and mod i to keep looping through active Finger Array
		  i++;
		  i=(i%5);
		  `log("i="$i);
	    } Until(j==useFinger); 
	  
	    currentFingerTouch = i-1;
		//`log("currentFinger Assinged to this ball: "$currentFingerTouch);
		//`log("target "$currentFingerTouch$": "$OSCPawn(Instigator).fingerTouchArray[currentFingerTouch]);
	  
	  }	
	
	 // `log("Instigator fingerTouchArray: "$OSCPawn(Instigator).fingerTouchArray[currentFingerTouch]);
//	if(OSCPawn(Instigator).fingerTouchArray[0]!=0)
//	{
	`log("FingerTouchArray["$currentFingerTouch$"]: "$OSCPawn(Instigator).fingerTouchArray[currentFingerTouch]);
	//scale fingerTouchArray values by scale and min/max values set in OSCPawn
		vectorb = (OSCPawn(Instigator).getScaledFingerTouch(currentFingerTouch))-Location;
		targetSeekLocation(vectorb);
		`log("TargetTouchLocation: "$vectorb);
		
      //vectorb = OSCPawn(Instigator).fingerTouchArray[currentFingerTouch]-Location;
		//vectorb = OSCPawn(Instigator).fingerTouchArray[0]-Location;
	  //RotateVector( Velocity, vectorb, 5.0);
	  //SetRotation( rotator( Velocity) );
//	}
	}
}

simulated function targetSeekLocation( vector newSeekTarget)
{
	local vector vectorb;
    vectorb = newSeekTarget-Location;
		//vectorb = OSCPawn(Instigator).fingerTouchArray[0]-Location;
	RotateVector( Velocity, vectorb, 5.0);
	SetRotation( rotator( Velocity) );

}

	
//Rotate vector A towards vector B, an amount of degrees.
static final function RotateVector( out vector A, vector B, float Degree )
{
	local float Magnitude;
	local vector C;
 
	Degree = Degree * Pi / 180.0;//Convert to radians.
	Magnitude = VSize(A);;
	A = Normal(A);
	B = Normal(B);
 
	if( A Dot B == -1.0 )//Vectors are pointing in opposite directions.
		B.x += 0.0001;//fudge it a little
 
	C = Normal(B - (A Dot B) * A);//This forms a right angle with A
 
	A = Normal( A * Cos(Degree) + C * Sin(Degree) ) * Magnitude;
	
}

simulated function Tick(float DeltaTime)
{
	if(bOSCSetSpeed)
	{
	//`log("In SB Tick OSCSetSpeed: "$OSCNewSpeed);
	  MaxSpeed=OSCNewSpeed;
	  Speed=OSCNewSpeed;
	  bOSCSetSpeed=false;
	}
	
	Super.Tick(DeltaTIme);
	//Say("ProjLocation: "$Location.X$","$Location.Y$","$Location.Z);
	//showTargetInfo();

	// Enable OSC Control over ShockBall
	if(OSCPawn(Instigator).OSCUseFingerTouches)
	{
	  moveShockBall();
	} else {
		setSpeed(lastSpeed);
	}
	
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
	`log("projectile fired: "$self.Name);
	lastSpeed=speed;
	Super.PostBeginPlay();
}

simulated function ProcessTouch(Actor Other, vector HitLocation, vector HitNormal)
{
	local UTProj_ShockBall ShockProj;
	local UTProjectile seekerProj;
	
	//Super.ProcessTouch(Other, HitLocation, HitNormal);

	//`log("SB WAs Touched: "$Other);
		
	// when shock projectiles collide, make sure they both blow up
	ShockProj = UTProj_ShockBall(Other);
	if (ShockProj != None)
	{
		//ShockProj.Explode(HitLocation, -HitNormal);
	}
	
	seekerProj = OSCProj_SeekingRocket(Other);
	if(seekerProj != None)
	{
	//	`log("OSCProj_ShockBall... ProcessTouch by: "$Other);
	}
	
	
}

simulated function Destroyed()
{
	wasDestroyed=1;
	sendProjectileState();
	Super.Destroyed();
	`log("Destroyed");
}