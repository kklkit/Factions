/**
 * Physical projectile vehicle weapons.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicleWeapon_Projectile extends FVehicleWeapon;

/**
 * @extends
 */
protected simulated function Fire()
{
	local Vector SpawnLocation;
	local Rotator SpawnRotation;
	local Projectile SpawnedProjectile;

	Super.Fire();

	if (Role == ROLE_Authority)
	{
		MyVehicle.GetBarrelLocationAndRotation(SeatIndex, SpawnLocation, SpawnRotation);

		SpawnedProjectile = Spawn(class'UTProj_ScorpionGlob',,, SpawnLocation);

		if (SpawnedProjectile != None)
			SpawnedProjectile.Init(Vector(SpawnRotation));
	}
}

defaultproperties
{
}
