class OSCAIController extends AIController//GameAIController
 DLLBind(oscpack_1_0_2);

var Actor target;
var() Vector TempDest;

 /*
 
 event Possess(Pawn inPawn, bool bVehicleTransition)
{

`log("IN POSSESS **********************************************************************************************");

	if (inPawn.Controller != None)
	{
		inPawn.Controller.UnPossess();
	}

	inPawn.PossessedBy(self, bVehicleTransition);
	Pawn = inPawn;

	// preserve Pawn's rotation initially for placed Pawns
	SetFocalPoint( Pawn.Location + 512*vector(Pawn.Rotation), TRUE );
	Restart(bVehicleTransition);

	if( Pawn.Weapon == None )
	{
		ClientSwitchToBestWeapon();
	}
}

//That's in our AI Controller
auto state Follow
{
Begin:
    Target = GetALocalPlayerController().Pawn;
    //Target is an Actor variable defined in my custom AI Controller.
    //Of course, you would normally verify that the Pawn is not None before proceeding.
 
    MoveToward(Target, Target, 128);
 
    goto 'Begin';
}

*/




event Possess(Pawn inPawn, bool bVehicleTransition)
{
	`log("IN POSSESS **********************************************************************************************");

    super.Possess(inPawn, bVehicleTransition); 
	inPawn.SetPhysics(PHYS_Flying);
	inPawn.SetMovementPhysics();	
} 


//I'm adding an default idle state so the Pawn doesn't try to follow a player that doesn' exist yet.

auto state Follow
{
	local int leaders[5];

	event Tick(float deltaTime)
	{
		local Rotator DeltaRot;
		local Vector selfToPlayer;
		local float DistanceToPlayer; //, ChaseDistance;
		//local Vector currentVelocity;
		//local float minRot;
		local Vector triVector;
//		local int flightOffset;
		
//		local Vector currentTarget;
    	
//		local int OffsetX;
//		local int OffsetY;
//		local int OffsetZ;
//		local int offset;
		
//		offset=300;
		
			//make a random offset, some distance away
//			OffsetX = Rand(offset)-Rand(offset);
//			OffsetY = Rand(offset)-Rand(offset);
//			OffsetY = Rand(offset)-Rand(offset);

			//some distance left or right and some distance in front or behind
//			currentTarget = Target.Location;
//			currentTarget.X = Target.Location.X + OffsetX;
//			currentTarget.Y = Target.Location.Y + OffsetY;
//			currentTarget.Z = Target.Location.Z + OffsetZ;

			//ChaseDistance = 10000;
		
//		flightOffset = 300;
		
		if(Target!=None)
		{
		/*
			`log("SETTING TARGET *************************************");
			`log("0 % 5 = "$(0%5));
			`log("1 % 5 = "$(1%5));
			`log("2 % 5 = "$(2%5));
			`log("3 % 5 = "$(3%5));
			`log("4 % 5 = "$(4%5));
			`log("5 % 5 = "$(5%5));
			`log("6 % 5 = "$(6%5));
			`log("7 % 5 = "$(7%5));
			*/
			if(OSCBot(Pawn).uid % 5 == 0)
			{
				triVector = vect(-300,0,0);
			} else if(OSCBot(Pawn).uid % 5 == 1) {
				triVector = vect(-300,300,0);			
			} else if(OSCBot(Pawn).uid % 5 == 2) {
				triVector = vect(-300,-300,0);	
			} else if(OSCBot(Pawn).uid % 5 == 3) {
				triVector = vect(-300,0,150);	
			} else if(OSCBot(Pawn).uid % 5 == 4) {
				triVector = vect(-300,0,-150);
			}			
			
			// Make Targets offset from PawnBot target
			selfToPlayer =  Target.Location + (triVector >> Target.Rotation) - self.Pawn.Location;
//			selfToPlayer =  Target.Location + (vect(-300,0,0) >> Target.Rotation)- self.Pawn.Location;

//			selfToPlayer =  Target.Location - self.Pawn.Location;
//			selfToPlayer =  currentTarget - self.Pawn.Location;

			DistanceToPlayer = VSize(selfToPlayer);
			DeltaRot = rotator(selfToPlayer);
	/*		
			if(abs(DeltaRot.Pitch) > minRot)
			{
				if(DeltaRot.Pitch < 0)
				{
					DeltaRot.Pitch=-minRot * -1.0;
				} else {
					DeltaRot.Pitch=minRot;
				}
			}
			
			if(abs(DeltaRot.Yaw) > minRot)
			{
				if(DeltaRot.Yaw < 0)
				{
					DeltaRot.Yaw= minRot * -1.0;
				} else {
					DeltaRot.Yaw=minRot;
				}
			}

			if(abs(DeltaRot.Roll) > minRot)
			{
				if(DeltaRot.Roll < 0)
				{
					DeltaRot.Roll=minRot * -1.0;
				} else {
					DeltaRot.Roll=minRot;
				}
			};
			
			`log("DeltaRot.Pitch: "$DeltaRot.Pitch);
			`log("DeltaRot.Yaw: "$DeltaRot.Yaw);
			`log("DeltaRot.Roll: "$DeltaRot.Roll);
		*/	
//			DeltaRot.Pitch = 0; //Don't allow the bot to run up into the air

//			if (DistanceToPlayer < ChaseDistance )
//			{
				self.Pawn.Velocity = Normal(selfToPlayer) * 20;// * 45;

				self.Pawn.FaceRotation(RInterpTo(DeltaRot, rotator(selfToPlayer), deltaTime, 90000, true), deltaTime);
				
				self.Pawn.AirSpeed = Pawn(Target).AirSpeed;
				self.Pawn.GroundSpeed = Pawn(Target).GroundSpeed;
				
				self.Pawn.Move(self.Pawn.Velocity * 0.6);		

				if(DistanceToPlayer < 400)
				{
					self.Pawn.AirSpeed = Pawn(Target).AirSpeed *  0.6;
					self.Pawn.GroundSpeed = Pawn(Target).GroundSpeed *  0.6;			
				//	Pawn.SetPhysics(PHYS_Walking);					
				} else {
				//	Pawn.SetPhysics(PHYS_Flying);
				}
				// constantly move forward?
//				self.Pawn.Acceleration.X=1.0;

/*				
				if(DistanceToPlayer < 500)
				{
					// forwards moving constantly?
					self.Pawn.Velocity = (self.Pawn.AirSpeed)*Normal(Vector(self.Pawn.Rotation));
					
					self.Pawn.AirSpeed=(Pawn(Target).AirSpeed)*(0.5);
					self.Pawn.GroundSpeed=(Pawn(Target).GroundSpeed)*(0.5);
					/**/
					// Keep the flying forwards (don't stop)
//					currentVelocity=self.Pawn.Velocity;
//					`log("LOGGING CURRENT VELOCITY: "$currentVelocity.X);
//					currentVelocity.X=1.0;
//					self.Pawn.Move(currentVelocity * 0.6);
					//self.Pawn.Move(self.Pawn.Velocity * 0.1);		

				} else {
				//self.Pawn.Move(self.Pawn.Velocity * 0.6);		
				}
*/				
//			}
		}
	}
 
Begin:

//    Target = GetALocalPlayerController().Pawn;


// HERE IS WHERE WE SET UP OUR FLOCK GROUPS (HACKY BUT WILL WORK FOR NOW)
//
// SET UID % 6 or something like that to be leaders, set their isLeader boolean and for the others, set their leader int
//
/*
	leaders[0] = 0;
	leaders[1] = 1;
	leaders[2] = 2;
	leaders[3] = 3;
	leaders[4] = 4;
	
	switch( OSCBot(self.Pawn).uid)
	{
		case 0:
		case 6:
		case 12:
			//`log("OSCBot uid is 0 - fallthroughs also for others, set leader status here too");
			GotoState('OSCMove');
			break;
		default:
			//`log("OSCBot uid > 0");
			break;
		
	}
*/	
//	if(OSCBot(self.Pawn).uid==0) {
//		GotoState('OSCMove');
//	} else {
		//Target = OSCPlayerControllerDLL(GetALocalPlayerController()).OSCBots[0];
//	}

    //Target is an Actor variable defined in my custom AI Controller.
    //Of course, you would normally verify that the Pawn is not None before proceeding.
	if(target!=none)
	{	
		MoveToward(Target, Target, 1000);
		goto 'Begin';
	}	

}

state OSCMove
{

	Begin:

		`log("******************I'M IN OSCMOVE - Bot: "$OSCBot(self.Pawn).uid);
}
/*
auto state Idle
{
    event SeePlayer (Pawn Seen)
    {
        super.SeePlayer(Seen);
        target = Seen;
		`log("IDLE STATE: SEE PLAYER ****************************************");
        GotoState('Follow');
    }
Begin:
}

state Follow
{
    ignores SeePlayer;
    function bool FindNavMeshPath()
    {
        // Clear cache and constraints (ignore recycling for the moment)
        NavigationHandle.PathConstraintList = none;
        NavigationHandle.PathGoalList = none;
 
        // Create constraints
        class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle,target );
        class'NavMeshGoal_At'.static.AtActor( NavigationHandle, target,32 );
 
        // Find path
        return NavigationHandle.FindPath();
    }
Begin:

	`log("FOLLOW STATE ****************************************");
 
	//Target = GetALocalPlayerController().Pawn;
    
	if( NavigationHandle.ActorReachable( target) )
    {
        FlushPersistentDebugLines();
 
        //Direct move
        MoveToward( target,target, 60 );
    }
    else if( FindNavMeshPath() )
    {
        NavigationHandle.SetFinalDestination(target.Location);
        FlushPersistentDebugLines();
        NavigationHandle.DrawPathCache(,TRUE);
 
        // move to the first node on the path
        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
        {
            DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
            DrawDebugSphere(TempDest,16,20,255,0,0,true);
 
            MoveTo( TempDest, target );
        }
    }
    else
    {
        //We can't follow, so get the hell out of this state, otherwise we'll enter an infinite loop.
        GotoState('Idle');
    }
 
    goto 'Begin';
} 
*/



















simulated Function PostBeginPlay()
{
//	local PlayerController PC;
	
	super.PostBeginPlay();
	
  Pawn.SetPhysics(PHYS_Flying);
  Pawn.SetMovementPhysics();	
  
//	PC = GetALocalPlayerController();
//	PC = /*GetWorldInfo().*/GetALocalPlayerController();
//	FollowTargetPawn = OSCPawn(PC.Pawn);
//	GotoState('Following');
}

 /*

simulated Function PostBeginPlay()
{
	Super.PostBeginPlay();
	Pawn.SetMovementPhysics();	
	Pawn.SetPhysics(PHYS_Falling);

  
  SetupPlayerCharacter();
}

// Set player's character info class & perform any other initialization
function SetupPlayerCharacter()
{
  //Set character to our custom character
  ServerSetCharacterClass(CharacterClass);
}

function EnterStartState()
{
    GotoState('PlayerFalling');
}

state PlayerFlying
{

	event BeginState(Name PreviousStateName)
	{
		Pawn.SetPhysics(PHYS_Flying);
	}
}

DefaultProperties
{
	InputClass=class'UDKOSC.OSCPawnInput';
}

*/