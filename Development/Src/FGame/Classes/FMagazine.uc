/**
 * Holds ammo to be used in a weapon.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FMagazine extends Inventory;

// Name of the weapon this magazine provides ammo for.
var() name AmmoFor;

var() int AmmoCount;
var() int AmmoCountMax;

replication
{
	if (bNetDirty)
		AmmoFor, AmmoCount, AmmoCountMax;
}

/**
 * Adds ammo to the magazine.
 * 
 * Amount can be negative to subtract ammo.
 */
function int AddAmmo(int Amount)
{
	AmmoCount = Clamp(AmmoCount + Amount, 0, AmmoCountMax);

	return AmmoCount;
}

defaultproperties
{
	AmmoCount=30
	AmmoCountMax=30
}
