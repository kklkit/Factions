/**
 * Physical projectile vehicle weapons.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicleWeapon_Projectile extends FVehicleWeapon;

/**
 * @extends
 */
simulated function Projectile ProjectileFire()
{
	local Vector SpawnLocation;
	local Rotator FireRotation;
	local Projectile SpawnedProjectile;

	IncrementFlashCount();

	if (Role == ROLE_Authority)
	{
		MyVehicle.GetBarrelLocationAndRotation(WeaponIndex, SpawnLocation, FireRotation);

		SpawnedProjectile = Spawn(class'UTProj_ScorpionGlob',,, SpawnLocation);

		if (SpawnedProjectile != None)
			SpawnedProjectile.Init(Vector(AddSpread(FireRotation)));
	}

	return SpawnedProjectile;
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_Projectile
	FireInterval(0)=0.75
	FireInterval(1)=0.75
	Spread(0)=0.01
	Spread(1)=0.01
}
