/**
 * Base class for vehicle weapons.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicleWeapon extends FWeapon;

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
