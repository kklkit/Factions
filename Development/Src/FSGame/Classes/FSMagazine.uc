/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSMagazine extends Inventory;

var() int AmmoCount;
var() int AmmoCountMax;

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
