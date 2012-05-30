/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FInventoryManager extends InventoryManager
	dependson(FMapInfo);

const EquipmentSlots=4;
var FWeaponInfo RequestedEquipment[EquipmentSlots];

replication
{
	if (bNetDirty)
		RequestedEquipment;
}

reliable server function SelectEquipment(byte Slot, name EquipmentName)
{
	if (Slot >= 0 && Slot < EquipmentSlots)
	{
		RequestedEquipment[Slot] = FMapInfo(WorldInfo.GetMapInfo()).GetWeaponInfo(EquipmentName);

		// Update the equipment selection GUI
		if (WorldInfo.NetMode != NM_DedicatedServer)
			FHUD(FPlayerController(Pawn(Owner).Controller).myHUD).GFxOmniMenu.Invalidate("equipment selection");
	}
	else
	{
		`log("Failed to select equipment! Equipment slot" @ Slot @ "is out of bounds!");
	}
}

reliable server function ResetEquipment()
{
	local FWeapon InfantryEquipment;
	local FMagazine Magazine;
	local byte EquipmentSlot;
	local byte MagazineCount;

	// Need to be standing on a barracks to re-equip
	if (FStructure_Barracks(FPawn(Instigator).Base) != None)
	{
		// Remove old inventory
		DiscardInventory();

		// Equip each requested equipment
		for (EquipmentSlot = 0; EquipmentSlot < EquipmentSlots; EquipmentSlot++)
		{
			// If there is a selection in the requested equipment slot
			if (RequestedEquipment[EquipmentSlot].Archetype != None)
			{
				// Spawn the equipment
				InfantryEquipment = Spawn(RequestedEquipment[EquipmentSlot].Archetype.Class, Owner,,,, RequestedEquipment[EquipmentSlot].Archetype);
				InfantryEquipment.WeaponName = RequestedEquipment[EquipmentSlot].Name;

				// Add default magazines to inventory
				for (MagazineCount = 0; MagazineCount < 4; MagazineCount++)
				{
					Magazine = FMagazine(CreateInventory(class'FMagazine'));
					Magazine.AmmoFor = InfantryEquipment.Name;
				}

				// Add the equipment to the inventory
				AddInventory(InfantryEquipment);

				// Reload the weapon if there's a magazine available
				if (Magazine != None)
					InfantryEquipment.ServerReload();
			}
		}
	}
}

defaultproperties
{
	PendingFire(0)=0
	PendingFire(1)=0
}
