/**
 * Manages the player's equipment.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FInventoryManager extends InventoryManager;

const MaxLoadoutSize=4;

var FWeapon CurrentWeaponArchetypes[MaxLoadoutSize];

replication
{
	if (bNetDirty)
	CurrentWeaponArchetypes;
}

/**
 * Clears the player's inventory and populates it with the requested equipment.
 */
reliable server function ResetLoadout(FInfantryClass InfantryClassArchetype, array<FWeapon> WeaponArchetypes)
{
	local FWeapon WeaponArchetype;
	local FWeapon Weapon;
	local FMagazine Magazine;
	local int MagazineCount;
	local int i;

	// Need to be standing on a barracks to re-equip.
	if (FStructure_Barracks(FPawn(Instigator).Base) != None)
	{
		// Remove old inventory.
		DiscardInventory();

		for (i = 0; i < MaxLoadoutSize; i++)
			CurrentWeaponArchetypes[i] = None;

		// Equip each requested equipment.
		foreach WeaponArchetypes(WeaponArchetype, i)
		{
			// If there is a selection in the requested equipment slot.
			if (WeaponArchetype != None)
			{
				// Spawn the equipment.
				CurrentWeaponArchetypes[i] = WeaponArchetype;
				Weapon = Spawn(WeaponArchetype.Class, Owner,,,, WeaponArchetype);

				// Add the equipment to the inventory.
				AddInventory(Weapon);

				// Add default magazines to inventory.
				if (FWeapon_Firearm(Weapon) != None)
				{
					for (MagazineCount = 0; MagazineCount < 4; MagazineCount++)
					{
						Magazine = FMagazine(CreateInventory(class'FMagazine'));
						Magazine.AmmoFor = Weapon.Name;
					}

					// Reload the weapon if there's a magazine available.
					if (Magazine != None)
						FWeapon_Firearm(Weapon).ServerReload();
				}
			}
		}
	}
}

defaultproperties
{
	PendingFire(0)=0
	PendingFire(1)=0
}
