/**
 * Vehicle inventory manager.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicleInventoryManager extends InventoryManager;

struct WeaponPendingFire
{
	var name WeaponName;
	var bool bPendingFire;
};

var array<WeaponPendingFire> VehicleWeaponPendingFire;

/**
 * @extends
 */
simulated function ClientWeaponSet(Weapon NewWeapon, bool bOptionalSet, optional bool bDoNotActivate);

/**
 * Creates a pending fire struct for the given weapon.
 */
simulated function WeaponPendingFire CreatePendingFire(Weapon InWeapon, bool bPendingFire)
{
	local int i;
	local WeaponPendingFire PendingFireInfo;

	i = VehicleWeaponPendingFire.Find('WeaponName', InWeapon.Name);

	if (i == INDEX_NONE)
	{
		PendingFireInfo.WeaponName = InWeapon.Name;
		PendingFireInfo.bPendingFire = bPendingFire;
		VehicleWeaponPendingFire.AddItem(PendingFireInfo);
		return PendingFireInfo;
	}
	else
	{
		return VehicleWeaponPendingFire[i];
	}
}

/**
 * @extends
 */
simulated function int GetPendingFireLength(Weapon InWeapon)
{
	return 1;
}

/**
 * @extends
 */
simulated function SetPendingFire(Weapon InWeapon, int InFiringMode)
{
	local int i;

	i = VehicleWeaponPendingFire.Find('WeaponName', InWeapon.Name);

	if (i != INDEX_NONE)
	{
		VehicleWeaponPendingFire[i].bPendingFire = True;
	}
	else
	{
		CreatePendingFire(InWeapon, True);
	}
}

/**
 * @extends
 */
simulated function ClearPendingFire(Weapon InWeapon, int InFiringMode)
{
	local int i;

	i = VehicleWeaponPendingFire.Find('WeaponName', InWeapon.Name);

	if (i != INDEX_NONE)
	{
		VehicleWeaponPendingFire[i].bPendingFire = False;
	}
	else
	{
		CreatePendingFire(InWeapon, False);
	}
}

/**
 * @extends
 */
simulated function ClearAllPendingFire(Weapon InWeapon)
{
	ClearPendingFire(InWeapon, INDEX_NONE);
}

/**
 * Returns true if the given weapon is pending fire.
 */
simulated function bool IsVehiclePendingFire(Weapon InWeapon, int InFiringMode)
{
	local int i;

	i = VehicleWeaponPendingFire.Find('WeaponName', InWeapon.Name);

	if (i != INDEX_NONE)
	{
		return VehicleWeaponPendingFire[i].bPendingFire;
	}
	else
	{
		return CreatePendingFire(InWeapon, False).bPendingFire;
	}
}

defaultproperties
{
	PendingFire(0)=0
	PendingFire(1)=0
}
