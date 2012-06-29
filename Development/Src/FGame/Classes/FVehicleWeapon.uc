/**
 * Base class for vehicle weapons.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicleWeapon extends FWeapon
	perobjectlocalized;

var int SeatIndex;
var FVehicle MyVehicle;

replication
{
	if (bNetInitial && bNetOwner)
		SeatIndex, MyVehicle;
}

simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional name SocketName);

simulated function DetachWeapon();

defaultproperties
{
	AmmoCount=1000
	FiringStatesArray(0)=WeaponFiring
	FiringStatesArray(1)=WeaponFiring
}
