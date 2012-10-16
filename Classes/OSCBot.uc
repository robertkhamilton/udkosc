class OSCBot extends UTBot;

var Actor Target;
var Vector targetLocation;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	Pawn.SetMovementPhysics();
}

auto state Idle
{

	event SeePlayer(Pawn Seen)
	{
		super.SeePlayer(Seen);
		Target = Seen;
		GotoState('Following');
	}
	
	Begin:
}

state OSCMove
{
	local Vector currentTarget;

	
	Begin:
	
	currentTarget = targetLocation;
	
	MoveTo(currentTarget);
	
	//MoveToward(Target, Target, 128);
	goto 'Begin';
}


