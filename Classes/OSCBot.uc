class OSCBot extends UTBot;

var Actor Target;
var Vector targetLocation;
var bool bOSCMove;

var float botGroundSpeed;

var int uid;

Function Spawned()
{
	`log("I was spawned");
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

simulated function testmoveto(int id, float x, float y, float z)
{
	if(uid==id)
	{
		targetLocation.X = x;
		targetLocation.Y = y;
		targetLocation.z = z;
	}
}

simulated function testTeleport(int id, float x, float y, float z)
{
	local vector newLocation;
	
	if(uid==id)
	{
		newLocation.X = x;
		newLocation.Y = y;
		newLocation.z = z;
		SetLocation(newLocation);

		`log("******************CALLED testTeleport");
	}
}


simulated function testControl(int id, float valx, float valy, float valz)
{
	local vector	X, Y, Z, NewAccel, testVector;
	
	//Pawn.Acceleration = vect(x,y,z);
	
	testVector.X = valx;
	testVector.Y = valy;
	testVector.Z = valz;
	
	GetAxes(Rotation,X,Y,Z);
	
	if(uid==id)
	{
		NewAccel = testVector.X*X + testVector.Y*Y;
		NewAccel = Pawn.AccelRate * Normal(NewAccel);
		
		`log("******************CALLED testControl");
	}

	Pawn.Acceleration = NewAccel;
}


event WhatToDoNext()
{
	super.WhatToDoNext();
	`log("STATE:   "$GetStateName());
	
}

function botOSCMove()
{
	`log("******************CALLING botOSCMove");

	if (bOSCMove)
		bOSCMove = false;
	else
		bOSCMove = true;
		
	if (bOSCMove)
		GotoState('OSCMove');
	else
		GotoState('Idle');
}

event PostBeginPlay()
{
    super.PostBeginPlay();
	`log("I'M ALIVE***********************************************");
	targetLocation.X = 0.0;
	targetLocation.Y = 0.0;
	targetLocation.z = 0.0;

	//`log("MY ID IS: "$PlayerReplicationInfo.PlayerID);
	/*
	// Set the player's ID.
	NewPlayer.PlayerReplicationInfo.PlayerID = GetNextPlayerID();
	NewPlayer.PlayerReplicationInfo.SetUniqueId(UniqueId);
	*/
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	Pawn.SetMovementPhysics();
	`log("******************DONE POSSESSING BOT");
	GotoState('OSCMove');
	`log("******************CALLED GotoState OSCMove");

}

state Idle
{

	event SeePlayer(Pawn Seen)
	{
		//super.SeePlayer(Seen);
		//Target = Seen;
		`log("******************I'M IN SEEPLAYER");
		
		//		GotoState('Following');
	}
	
	Begin:
	
		`log("******************I'M IN State IDLE");
}


auto state OSCMove
{
	local Vector currentTarget;
	local bool inOSCMove;
	
	Begin:
		//if(!inOSCMove)
		//	`log("******************I'M IN OSCMOVE - Bot: "$uid);
		
		inOSCMove = true;
		
		currentTarget = targetLocation;
	
		MoveTo(currentTarget);
	
		//MoveToward(Target, Target, 128);
		goto 'Begin';
}

state Defending{
	Begin:
		GotoState('OSCMove');
}

state Startled{Begin: GotoState('OSCMove');}

state MoveToGoal{Begin: GotoState('OSCMove');}

state Roaming{Begin: GotoState('OSCMove');}

state Fallback{Begin: GotoState('OSCMove');}

state Retreating{Begin: GotoState('OSCMove');}

state Charging{Begin: GotoState('OSCMove');}

state Hunting{Begin: GotoState('OSCMove');}

state StakeOut{Begin: GotoState('OSCMove');}

state RangedAttack{	
	Begin:
		GotoState('OSCMove');	
}

state TacticalMove{	
	Begin:
		GotoState('OSCMove');	
}
state FindAir{Begin: GotoState('OSCMove');}

state FrozenMovement{Begin: GotoState('OSCMove');}

event SeePlayer(Pawn Seen)
{
	/*
    fLastSeenTime = WorldInfo.TimeSeconds;
    LastSeenPawn = Seen;
    
    // Only chase humans for now
    if ((Enemy == None) && Seen.IsHumanControlled())
    {
        Enemy = Seen;
        `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetFuncName() @ "Enemy:" @ Enemy);
        WhatToDoNext();
    }
    
    if (Enemy == Seen)
    {
        VisibleEnemy = Enemy;
        EnemyVisibilityTime = WorldInfo.TimeSeconds;
        bEnemyIsVisible = true;
    }
	*/
}
	

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTIme);

//	if(sendingOSC)
//		sendPlayerState();
}		
		
DefaultProperties
{
	ControllerClass=class'UT3OSC.OSCAIController'
	uid = -1;
}