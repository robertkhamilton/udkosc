class OSCBot_Pawn extends OSCPawn
 notplaceable
 DLLBind(oscpack_1_0_2);

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


event PostBeginPlay()
{
    super.PostBeginPlay();
	`log("I'M ALIVE***********************************************");
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	Pawn.SetMovementPhysics();
	`log("******************DONE POSSESSING BOT_PAWN");
}


function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, Rotator DeltaRot)
{
	//Super.ProcessMove(DeltaTime, NewAccel, DoubleClickMove, DeltaRot);
	
	if (Pawn == none)
	{
		return;
	}
}

function PlayerMove( float DeltaTime )
{
	//Super.PlayerMove(Deltatime);
}	

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTIme);
}		
		
DefaultProperties
{
	ControllerClass=class'UT3OSC.OSCAIController'
	uid = -1;
}