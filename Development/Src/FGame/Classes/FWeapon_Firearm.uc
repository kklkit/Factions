/**
 * Base class for firearm-type infantry weapons.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FWeapon_Firearm extends FWeapon;

// Loaded magazine
var private FMagazine Magazine;

replication
{
	if (bNetDirty)
		Magazine;
}

/**
 * @extends
 */
function int AddAmmo(int Amount)
{
	AmmoCount = Magazine.AddAmmo(Amount);
	return AmmoCount;
}

/**
 * Executes reloading the weapon.
 */
reliable server function ServerReload()
{
	local FMagazine NextMagazine;

	// Get the next magazine of the equipment's type
	foreach InvManager.InventoryActors(class'FMagazine', NextMagazine)
		if (NextMagazine.AmmoFor == Name)
			break;

	// Abort reloading if no magazine was found
	if (NextMagazine == None)
		return;

	// Throw away current magazine
	if (Magazine != None)
	{
		Magazine.Destroy();
		AmmoCount = 0;
		MaxAmmoCount = 0;
	}

	// Remove next magazine from inventory
	InvManager.RemoveFromInventory(NextMagazine);

	// Insert magazine into weapon
	Magazine = NextMagazine;
	AmmoCount = Magazine.AmmoCount;
	MaxAmmoCount = Magazine.MaxAmmoCount;
}

defaultproperties
{
}
