/**
 * Base class for vehicle weapons.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicleWeapon extends FWeapon;

var int SeatIndex;
var FVehicle MyVehicle;

replication
{
	if (bNetInitial && bNetOwner)
		SeatIndex, MyVehicle;
}

simulated function bool HasAmmo(byte FireModeNum, optional int Amount)
{
	return True;
}

simulated function bool HasAnyAmmo()
{
	return True;
}

/**
 * @extends
 */
simulated function Projectile ProjectileFire()
{
	local Vector SpawnLocation;
	local Rotator SpawnRotation;
	local Projectile SpawnedProjectile;

	IncrementFlashCount();

	if (Role == ROLE_Authority)
	{
		MyVehicle.GetBarrelLocationAndRotation(SeatIndex, SpawnLocation, SpawnRotation);

		SpawnedProjectile = Spawn(GetProjectileClass(),,, SpawnLocation);

		if (SpawnedProjectile != None)
			SpawnedProjectile.Init(Vector(AddSpread(SpawnRotation)));
	}

	return SpawnedProjectile;
}

/**
 * @extends
 */
simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional Name SocketName);

/**
 * @extends
 */
simulated function DetachWeapon();

defaultproperties
{
}
