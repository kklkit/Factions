/**
 * Vehicle inventory manager.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicleInventoryManager extends InventoryManager;

simulated function ClientWeaponSet(Weapon NewWeapon, bool bOptionalSet, optional bool bDoNotActivate)
{
	NewWeapon.Activate();
}

defaultproperties
{
	PendingFire(0)=0
	PendingFire(1)=0
}
