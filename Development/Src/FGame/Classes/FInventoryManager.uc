/**
 * Manages the player's equipment.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FInventoryManager extends InventoryManager;

/**
 * Spawns the loadout items and adds them to the inventory.
 */
function EquipLoadout()
{
	local FPlayerController PlayerController;
	local FWeapon SpawnedWeapon;
	local FWeapon WeaponArchetype;
	local FMagazine Magazine;
	local int MagazineCount;
	local int i;

	PlayerController = FPlayerController(Pawn(Owner).Controller);

	// Remove old inventory.
	DiscardInventory();

	// Equip each requested equipment.
	for (i = 0; i < class'FPlayerController'.const.MaxLoadoutSlots; i++)
	{
		WeaponArchetype = PlayerController.CurrentWeaponArchetypes[i];

		if (WeaponArchetype != None)
		{
			SpawnedWeapon = Spawn(WeaponArchetype.Class, Owner,,,, WeaponArchetype);
			AddInventory(SpawnedWeapon);

			// Add default magazines to inventory.
			if (FWeapon_Firearm(SpawnedWeapon) != None)
			{
				for (MagazineCount = 0; MagazineCount < 4; MagazineCount++)
				{
					Magazine = FMagazine(CreateInventory(class'FMagazine'));
					Magazine.AmmoFor = SpawnedWeapon.Name;
				}

				if (Magazine != None)
					FWeapon_Firearm(SpawnedWeapon).ServerReload();
			}
		}
	}
}

defaultproperties
{
	PendingFire(0)=0
	PendingFire(1)=0
}
