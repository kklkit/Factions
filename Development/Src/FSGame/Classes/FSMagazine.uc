/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSMagazine extends Inventory;

var() class<Inventory> AmmoType;
var() int AmmoCount;
var() int AmmoCountMax;

replication
{
	if (bNetInitial)
		AmmoType, AmmoCountMax;
	if (bNetDirty)
		AmmoCount;
}

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
