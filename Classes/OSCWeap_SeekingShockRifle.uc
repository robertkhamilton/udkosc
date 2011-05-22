class OSCWeap_SeekingShockRifle extends UTWeap_ShockRifle;

function ConsumeAmmo( byte FireModeNum )
{
	// dont consume ammo
}

defaultproperties
{
WeaponProjectiles(1)=class'OSCProj_SeekingShockBall'
   Name="Default__OSCWeap_SeekingShockRIfle"
   ObjectArchetype=UTWeapon'UTGame.Default__UTWeapon'
   
	FireInterval(1)=+0.2	
}