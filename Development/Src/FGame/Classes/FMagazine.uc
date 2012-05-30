/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FMagazine extends Inventory;

var() name AmmoFor;
var() int AmmoCount;
var() int AmmoCountMax;

replication
{
	if (bNetDirty)
		AmmoFor, AmmoCount, AmmoCountMax;
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
