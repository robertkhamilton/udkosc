class OSCWeap_RocketLauncher_Content extends UTWeap_RocketLauncher_Content;

function class<Projectile> GetProjectileClass()
{
	return class'OSCProj_SeekingRocket';
}

function ConsumeAmmo( byte FireModeNum )
{
	// dont consume ammo
}

defaultproperties
{
WeaponProjectiles(0)=class'OSCProj_SeekingRocket'
   
Name="Default__OSCWeap_RocketLauncher_Content"
ObjectArchetype=UTWeapon'UTGame.Default__UTWeapon'
   
   	FireInterval(0)=+0.3	

	SeekingRocketClass=class'OSCProj_SeekingRocket'
	/** If true, weapon will try to lock onto targets */
	bTargetLockingActive=true;
	
	LockRange=8000
	LockAim=0.997
	LockChecktime=0.1
	LockAcquireTime=.1
	LockTolerance=1.0
	/** What "target" is this weapon locked on to */
//var Actor 				LockedTarget;
}




 //  This function is used to adjust the LockTarget.
 
function AdjustLockTarget(actor NewLockTarget)
{
	if ( LockedTarget == NewLockTarget )
	{
		// no need to update
		return;
	}

	if (NewLockTarget == None)
	{
		// Clear the lock
		if (bLockedOnTarget)
		{
			LockedTarget = None;

			bLockedOnTarget = false;

			if (LockLostSound != None && Instigator != None && Instigator.IsHumanControlled() )
			{
				PlayerController(Instigator.Controller).ClientPlaySound(LockLostSound);
			}
		}
	}
	else
	{
		// Set the lcok
		bLockedOnTarget = true;
		LockedTarget = NewLockTarget;
		LockedTargetPRI = (Pawn(NewLockTarget) != None) ? Pawn(NewLockTarget).PlayerReplicationInfo : None;
		if ( LockAcquiredSound != None && Instigator != None  && Instigator.IsHumanControlled() )
		{
			PlayerController(Instigator.Controller).ClientPlaySound(LockAcquiredSound);
		}
		
		`log("TEST: lok should have been set with: "$NewLockTarget);
	}
}



simulated function Projectile ProjectileFire()
{
	local Projectile		oscSpawnedProjectile;
	local OSCProj_SeekingRocket localRocket;
	
	//Super.ProjectileFIre();
	
	oscSpawnedProjectile=Super(UTWeapon).ProjectileFire();
	localRocket = OSCProj_SeekingRocket(oscSpawnedProjectile);
	localRocket.bornWithLock=True;
	localRocket.setBornWithLock(true);
	`log("IN PROJECTILEFIRE: bornWithLock: "$localRocket.bornWithLock);
	localRocket.OSCSeekTarget = OSCProj_ShockBall(LockedTarget);
	`log("IN PROJECTILEFIRE: LockedTarget: "$localRocket.OSCSeekTarget);
	return localRocket;
}
	
/**
* This function checks to see if we are locked on a target
*/
function CheckTargetLock()
{
	local Pawn P, LockedPawn;
	local Actor BestTarget, HitActor, TA;
	local UDKBot BotController;
	local vector StartTrace, EndTrace, Aim, HitLocation, HitNormal;
	local rotator AimRot;
	local float BestAim, BestDist;

//	`log("In CheckTargetLock");
	
	if ( (Instigator == None) || (Instigator.Controller == None) || (self != Instigator.Weapon) )
	{
		return;
	}

	if ( Instigator.bNoWeaponFiring || (LoadedFireMode == RFM_Grenades) )
	{
		AdjustLockTarget(None);
		PendingLockedTarget = None;
		return;
	}
//	`log("In CheckTargetLock 1");
	// support keeping lock as players get onto hoverboard
	if ( LockedTarget != None )
	{
//		`log("In CheckTargetLock 1a");
		if ( LockedTarget.bDeleteMe )
		{
			if ( (LockedTargetPRI != None) && (UTVehicle_Hoverboard(LockedTarget) != None) )
			{
//				`log("In CheckTargetLock 1b");
				// find the appropriate pawn
				/*
				for ( P=WorldInfo.PawnList; P!=None; P=P.NextPawn )
				{
					//`log("In CheckTargetLock 1c");
					if ( P.PlayerReplicationInfo == LockedTargetPRI )
					{
						AdjustLockTarget((Vehicle(P) != None) ? None : P);
						break;
					}
				}
				*/
			}
			else
			{
				//`log("In CheckTargetLock 1d");
				AdjustLockTarget(LockedTarget);
			}
		}
		else 
		{
//			`log("In CheckTargetLock 1e");
			LockedPawn = Pawn(LockedTarget);
			if ( (LockedPawn != None) && (LockedPawn.DrivenVehicle != None) ) 
			{
				AdjustLockTarget(UTVehicle_Hoverboard(LockedPawn.DrivenVehicle));
			
			}
		}
	}
	
//		`log("In CheckTargetLock 2");

	BestTarget = None;
	BotController = UDKBot(Instigator.Controller);
	if ( BotController != None )
	{
//	`log("In CheckTargetLock 2a");
		// only try locking onto bot's target
		if ( (BotController.Focus != None) && CanLockOnTo(BotController.Focus) )
		{
			// make sure bot can hit it
			BotController.GetPlayerViewPoint( StartTrace, AimRot );
			Aim = vector(AimRot);

			if ( (Aim dot Normal(BotController.Focus.Location - StartTrace)) > LockAim )
			{
				HitActor = Trace(HitLocation, HitNormal, BotController.Focus.Location, StartTrace, true,,, TRACEFLAG_Bullet);
				if ( (HitActor == None) || (HitActor == BotController.Focus) )
				{
					BestTarget = BotController.Focus;
				}
			}
		}
	}
	else
	{
//	`log("In CheckTargetLock 2b");
		// Begin by tracing the shot to see if it hits anyone
		Instigator.Controller.GetPlayerViewPoint( StartTrace, AimRot );
		Aim = vector(AimRot);
		EndTrace = StartTrace + Aim * LockRange;
		HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true,,, TRACEFLAG_Bullet);

		// Check for a hit

		if ( (HitActor == None) || !CanLockOnTo(HitActor) )
		{
//		`log("In CheckTargetLock 2c");
			// We didn't hit a valid target, have the controller attempt to pick a good target
			BestAim = ((UDKPlayerController(Instigator.Controller) != None) && UDKPlayerController(Instigator.Controller).bConsolePlayer) ? ConsoleLockAim : LockAim;
			BestDist = 0.0;
			TA = Instigator.Controller.PickTarget(class'Pawn', BestAim, BestDist, Aim, StartTrace, LockRange);
			if ( TA != None && CanLockOnTo(TA) )
			{
//			`log("In CheckTargetLock 2d");
				BestTarget = TA;
			}
		}
		else	// We hit a valid target
		{
//		`log("In CheckTargetLock 2e");
			BestTarget = HitActor;
		}
	}
//	`log("In CheckTargetLock 3");
	// If we have a "possible" target, note its time mark
	if ( BestTarget != None )
	{
		LastValidTargetTime = WorldInfo.TimeSeconds;

		if ( BestTarget == LockedTarget )
		{
//		`log("In CheckTargetLock 3a");
			LastLockedOnTime = WorldInfo.TimeSeconds;
		}
		else
		{
//		`log("In CheckTargetLock 3b");
			if ( LockedTarget != None && ((WorldInfo.TimeSeconds - LastLockedOnTime > LockTolerance) || !CanLockOnTo(LockedTarget)) )
			{
				// Invalidate the current locked Target
				AdjustLockTarget(None);
			}

			// We have our best target, see if they should become our current target.
			// Check for a new Pending Lock
			if (PendingLockedTarget != BestTarget)
			{
				PendingLockedTarget = BestTarget;
				PendingLockedTargetTime = ((Vehicle(PendingLockedTarget) != None) && (UDKPlayerController(Instigator.Controller) != None) && UDKPlayerController(Instigator.Controller).bConsolePlayer)
										? WorldInfo.TimeSeconds + 0.5*LockAcquireTime
										: WorldInfo.TimeSeconds + LockAcquireTime;
			}

			// Otherwise check to see if we have been tracking the pending lock long enough
			else if (PendingLockedTarget == BestTarget && WorldInfo.TimeSeconds >= PendingLockedTargetTime )
			{
				AdjustLockTarget(PendingLockedTarget);
				LastLockedOnTime = WorldInfo.TimeSeconds;
				PendingLockedTarget = None;
				PendingLockedTargetTime = 0.0;
			}
		}
	}
	else 
	{
		if ( LockedTarget != None && ((WorldInfo.TimeSeconds - LastLockedOnTime > LockTolerance) || !CanLockOnTo(LockedTarget)) )
		{
			// Invalidate the current locked Target
			AdjustLockTarget(None);
		}

		// Next attempt to invalidate the Pending Target
		if ( PendingLockedTarget != None && ((WorldInfo.TimeSeconds - LastValidTargetTime > LockTolerance) || !CanLockOnTo(PendingLockedTarget)) )
		{
			PendingLockedTarget = None;
		}
	}
}


// Given an potential target TA determine if we can lock on to it.  By default only allow locking on to pawns.  

simulated function bool CanLockOnTo(Actor TA)
{

/*	if ( (TA == None) || !TA.bProjTarget || TA.bDeleteMe || (Pawn(TA) == None) || (TA == Instigator) || (Pawn(TA).Health <= 0) )
	{
		return false;
	}
*/	
	if(TA.class == class'OSCProj_ShockBall') {
		`log("Locked on: "$LockedTarget$" with current: "$TA);
		return true;
	} else {
		return false;
	}
//	return ( (WorldInfo.Game == None) || !WorldInfo.Game.bTeamGame || (WorldInfo.GRI == None) || !WorldInfo.GRI.OnSameTeam(Instigator,TA) );
}
