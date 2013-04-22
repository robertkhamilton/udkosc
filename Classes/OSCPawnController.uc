class OSCPawnController extends OSCPlayerController
 DLLBind(oscpack_1_0_2)
 dependson(OSCPlayerControllerDLL);

var class<UTFamilyInfo> CharacterClass;
 
var int pawnUID;

var float velRotation;
var int OSCDirty;

var OSCScriptPlayermoveStruct 				localOSCScriptPlayermoveStruct;
var OSCScriptPlayerTeleportStruct 			localOSCScriptTeleportStruct;

var OSCPawnBotStateValuesStruct 		localOSCPawnBotStateValuesStruct;
var OSCPawnBotDiscreteValuesStruct 	localOSCPawnBotDiscreteValuesStruct;
var OSCPawnBotTeleportStruct 				localOSCPawnBotTeleportStruct;

//dllimport final function OSCScriptPlayermoveStruct getOSCScriptPlayermove();
dllimport final function OSCPawnBotStateValuesStruct getOSCPawnBotStateValues(int id);
dllimport final function OSCPawnBotTeleportStruct getOSCPawnBotTeleportValues(int id);
dllimport final function OSCPawnBotDiscreteValuesStruct getOSCPawnBotDiscreteValues(int id);

simulated event PostBeginPlay()
{
  super.PostBeginPlay();
   
  SetupPlayerCharacter();
  
  Pawn.SetPhysics(PHYS_Flying);
  Pawn.SetMovementPhysics();	
}

/** Set player's character info class & perform any other initialization */
function SetupPlayerCharacter()
{
  //Set character to our custom character
  ServerSetCharacterClass(CharacterClass);
}


simulated function setOSCScriptPlayermoveStruct(OSCScriptPlayermoveStruct fstruct)
{
	localOSCScriptPlayermoveStruct = fstruct;
}

simulated function setOSCScriptTeleportStruct(OSCScriptPlayerTeleportStruct tstruct)
{
	localOSCScriptTeleportStruct = tstruct;
}	

auto state OSCPawnMove
{
	
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, Rotator DeltaRot)
	{
	
		if (Pawn == none)
		{
			return;
		}
		
		Pawn.Acceleration = NewAccel;
	}
	
	function PlayerMove( float DeltaTime )
	{
		local vector			X,Y,Z, NewAccel;
		local bool				bOSCJump;
		local bool				bSaveJump;
		local vector			OSCVector;
		local float				OSCJump, OSCGroundSpeed, OSCStop, OSCPitch, OSCYaw, OSCRoll;
		local eDoubleClickDir	DoubleClickMove;
		local rotator			OldRotation;
		local Vector Direction;
		local Rotator NewRotation, DesiredRotation;

		if (localOSCPawnBotTeleportStruct.teleport > 0)
		{		
			OSCPawnBot(Pawn).teleport(localOSCPawnBotTeleportStruct.teleportx, localOSCPawnBotTeleportStruct.teleporty, localOSCPawnBotTeleportStruct.teleportz);					
		}
		
		OSCJump = localOSCPawnBotDiscreteValuesStruct.jump;
		OSCVector.X = localOSCPawnBotStateValuesStruct.x;
		OSCVector.Y = localOSCPawnBotStateValuesStruct.y;
		OSCVector.Z = localOSCPawnBotStateValuesStruct.z;
		OSCGroundSpeed = localOSCPawnBotStateValuesStruct.speed;
		OSCStop = localOSCPawnBotDiscreteValuesStruct.stop;
		
		OSCPitch = localOSCPawnBotStateValuesStruct.pitch;
		OSCYaw  = localOSCPawnBotStateValuesStruct.yaw;
		OSCRoll = localOSCPawnBotStateValuesStruct.roll;
		
				// Testing follow functions
		if ( OSCPawnBot(Pawn).follow==true )
		{
			OSCVector.X = OSCPawnBot(Pawn).targetAccel.X;
			OSCVector.Y = OSCPawnBot(Pawn).targetAccel.Y;
			OSCVector.Z = OSCPawnBot(Pawn).targetAccel.Z;
			
			`log("                *****************                       ******************* XYZ in PawnController");
		}	
		
		if (OSCJump > 0.0) 
		{
			bOSCJump = true;
			bPressedJump = true;
		}

		if( Pawn == None )
		{
			GotoState('Dead'); //"
		}
		else
		{

			GetAxes(Pawn.Rotation,X,Y,Z);
/*			
		if(pawnUID == 1)
		{
			`log("OSCVector.X: "$OSCVector.X$", OSCVector.Y: "$OSCVector.Y$", OSCVector.Z: "$OSCVector.Z$", OSCGroundSpeed: "$OSCGroundSpeed$", OSCStop: "$OSCStop);
			`log("OSCPitch: "$OSCPitch$", OSCYaw: "$OSCYaw$", OSCRoll: "$OSCRoll);
			`log("OSCJump: "$OSCJump$" - id: "$pawnUID$", X: "$OSCVector.X$", Y: "$OSCVector.Y);
			`log("X: "$X$", Y: "$Y);
		}
*/			
			NewAccel = OSCVector.X*X + OSCVector.Y*Y;
			NewAccel = Pawn.AccelRate * Normal(NewAccel);
/*			
			if(OSCStop > 0.0)
			{
	//			`log("OSCStop: "$OSCStop$" - id: "$pawnUID);
				NewAccel.X = 0;
				NewAccel.Y = 0;
				NewAccel.Z = 0;
			}		
*/		
			//DesiredRotation = Rotator(NewAccel);
			OldRotation = Rotation;
			UpdateRotation(DeltaTime);
			//Pawn.SetDesiredRotation(Rotator(OSCPitch, OSCYaw, OSCRoll));
			
			//`log("PROCESSING MOVE.........NewAccel: "$NewAccel.X$", "$NewAccel.Y$", "$NewAccel.Z);
			
			Pawn.GroundSpeed = OSCGroundSpeed;   	// Add OSC speed control
			Pawn.AirSpeed = OSCGroundSpeed;  // for now share speed
			
			//DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );
			
			//OldRotation = Rotation;
			
//			Direction = OSCVector;
//			NewRotation = Rotator(Direction);
//			SetRotation(NewRotation);
			
			//Add OSC Jump and JumpZ
			if(bOSCJump)
			{
				Pawn.JumpZ = OSCJump;
				Pawn.DoJump(bUpdating);
				bOSCJump = false;
			}
			
			if( bPressedJump && Pawn.CannotJumpNow() )
			{
				bSaveJump = true;
				bPressedJump = false;
			}
			else
			{
				bSaveJump = false;
			}
			
			bPressedJump = bSaveJump;			
		}		
		
		if(OSCStop > 0.0)
		{
		//	`log("OSCStop: "$OSCStop$" - id: "$pawnUID);
			NewAccel.X = 0;
			NewAccel.Y = 0;
			NewAccel.Z = 0;
		}
		
		if( Role < ROLE_Authority ) // then save this move and replicate it
		{
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);//OldRotation - OSCCameraRotation);
		}
		else
		{
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			//ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - OSCCameraRotation);
		}
//		}		
				
		cleanLocalOSCTeleportStruct();
	}

	
	function UpdateRotation( float DeltaTime )
	{
		local Rotator DeltaRot, newRotation, ViewRotation;
		local float OSCPitch, OSCYaw, OSCRoll;
		
		OSCPitch = localOSCPawnBotStateValuesStruct.pitch;
		OSCYaw  = localOSCPawnBotStateValuesStruct.yaw;
		OSCRoll = localOSCPawnBotStateValuesStruct.roll;
		
		ViewRotation = Rotation;
		if (Pawn!=none)
		{
			Pawn.SetDesiredRotation(ViewRotation);
		}
	
		// Calculate Delta to be applied on ViewRotation
		DeltaRot.Yaw = OSCYaw;
		DeltaRot.Pitch = OSCPitch;
		DeltaRot.Roll = OSCRoll;
		
		ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );

				// Testing follow functions
		if ( OSCPawnBot(Pawn).follow==true )
		{
			ViewRotation = OSCPawnBot(Pawn).targetRotation;
			`log("                *****************                       ******************* PawnController");
		}		

		SetRotation(ViewRotation);

		ViewShake( deltaTime );

		NewRotation = ViewRotation;
		NewRotation.Roll = Rotation.Roll;
		
		if ( Pawn != None )
		{
			Pawn.FaceRotation(NewRotation, deltatime);
		}
		
		
	}
	
	
	simulated function cleanLocalOSCPlayermoveStruct()
	{
		OSCDirty = 0;	
	}
	
	simulated function cleanLocalOSCTeleportStruct()
	{
		localOSCScriptTeleportStruct.id = -1;
		localOSCScriptTeleportStruct.teleport = -1;
		localOSCScriptTeleportStruct.teleportx = -1;
		localOSCScriptTeleportStruct.teleporty = -1;
		localOSCScriptTeleportStruct.teleportz = -1;
	}
	
	simulated function setOSCPawnBotData()
	{
		localOSCPawnBotStateValuesStruct = getOSCPawnBotStateValues(pawnUID);
		localOSCPawnBotDiscreteValuesStruct = getOSCPawnBotDiscreteValues(pawnUID);
		localOSCPawnBotTeleportStruct = getOSCPawnBotTeleportValues(pawnUID);
		
		//`log("IN setOSCPawnBotData for pawnid: "$pawnUID);
	}
	
	simulated function setOSCScriptPlayermoveData()		//(OSCScriptPlayermoveStruct fstruct)
	{
		// Pull Pawn's move data from OSCPlayerController PawnBot Array
		
		local OSCPlayerControllerDLL C;
		
		foreach WorldInfo.AllControllers(class 'OSCPlayerControllerDLL', C)
		{
			localOSCScriptPlayermoveStruct = C.OSCScriptPawnBotStructs[pawnUID];
		}
		
/*		
		`log("OSCPawnController:: pawnUID "$pawnUID$" ::setOSCScriptPlayermoveData::fstruct.id "$fstruct.id$" - fstruct.jump "$fstruct.jump);
		//`log("OSCPawnController::setOSCScriptPlayermoveData::fstruct.jump "$fstruct.jump);
			
		// only process osc moves for this pawn
		if(int(fstruct.id) == pawnUID)
		{
			localOSCScriptPlayermoveStruct = fstruct;
			`log("***********MADE IT: JUMP = "$localOSCScriptPlayermoveStruct.jump);
			`log("PlayerMove::fstruct.id "$int(fstruct.id)$" - Pawn.Uid "$pawnUID);
		}
		else
		{
		
		}
*/
	}	
	
	event PlayerTick( float DeltaTime )
	{
		//setOSCScriptPlayermoveData();
		
		//`log("TESTING: In PlayerTick, OSCPawnController");
		
		// Make state, discrete and teleport calls...
		setOSCPawnBotData();
	
	//`log("PlayerTick - OSCPawnController before...");
	Super.PlayerTick(DeltaTime);
	//`log("PlayerTick - OSCPawnController after...");	
	
//		Super.PlayerTick(DeltaTime);
		//setOSCScriptPlayermoveData(getOSCScriptPlayermove());
	}
	
	Begin:
		pawnUID = OSCPawnBot(Pawn).getUID();
		
		`log("IN OSCPawnController state OSCPawnMove::Pawn.uid = "$OSCPawnBot(Pawn).getUID());
		
}

state Idle
{	
	Begin:
		`log("IN OSCPawnController state IDLE");
}

event InitInputSystem()
{
	//Super.InitInputSystem();
	//AddOnlineDelegates(false);
}

function AddOnlineDelegates(bool bRegisterVoice)
{
}

event PlayerTick(float DeltaTime)
{
	Super.PlayerTick(DeltaTime);
}

DefaultProperties
{
	velRotation = 5000;
	InputClass=class'UT3OSC.OSCPawnInput';
	
	//Points to the UTFamilyInfo class for your custom character
	//CharacterClass=class'UT3OSC.OSCFamilyInfo_OSCPawnBot'
}
