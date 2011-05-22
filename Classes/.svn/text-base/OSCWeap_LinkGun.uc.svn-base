class OSCWeap_LinkGun extends UTWeap_LinkGun;

function class<Projectile> GetProjectileClass()
{
	return (LinkStrength > 1) ? class'OSCProj_LinkPlasma' : Super.GetProjectileClass();
}

function ConsumeAmmo( byte FireModeNum )
{
	// dont consume ammo
}
/*
function setFireInterval(int mode, float val)
{
	FireInterval(mode)=+val;
}
*/
defaultproperties
{
WeaponProjectiles(0)=class'OSCProj_LinkPlasma'
   Name="Default__OSCWeap_LinkGun"
   ObjectArchetype=UTWeapon'UTGame.Default__UTWeapon'
   
   	FireInterval(0)=+0.3	

	FiringStatesArray(0)=WeaponBeamFiring
	BeamTemplate[0]=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Altbeam'
	BeamSockets[0]=MuzzleFlashSocket02
	BeamTemplate[0]=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Altbeam'
	BeamSockets[0]=MuzzleFlashSocket02
	eaponFireSnd(0)=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_AltFireCue'
	RechargeRate=.001
}
