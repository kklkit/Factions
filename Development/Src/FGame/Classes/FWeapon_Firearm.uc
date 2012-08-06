/**
 * Base class for firearm-type infantry weapons.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FWeapon_Firearm extends FWeapon;

var(Weapon) FMagazine MagazineArchetype;
var(Weapon) byte DefaultMagazineCount;

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
function GivenTo(Pawn thisPawn, optional bool bDoNotActivate)
{
	Super.GivenTo(thisPawn, bDoNotActivate);

	AddDefaultMagazines();

	ServerReload();
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
 * Adds starting magazines to the owner.
 */
function AddDefaultMagazines()
{
	local FMagazine Mag;
	local int MagazineCount;

	for (MagazineCount = 0; MagazineCount < DefaultMagazineCount; MagazineCount++)
	{
		Mag = Spawn(MagazineArchetype.Class, Owner,,,, MagazineArchetype);
		Mag.AmmoFor = Name;
		InvManager.AddInventory(Mag);
	}
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
