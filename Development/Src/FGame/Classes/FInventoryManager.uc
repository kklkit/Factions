/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FInventoryManager extends InventoryManager;

const EquipmentSlots=4;

var class<Inventory> RequestedEquipment[EquipmentSlots];
var name RequestedEquipmentName[EquipmentSlots];

replication
{
	if (bNetDirty)
		RequestedEquipment;
}

reliable server function SelectEquipment(byte Slot, string EquipmentName)
{
	if (Slot >= 0 && Slot < EquipmentSlots)
	{
		RequestedEquipment[Slot] = class'FFirearmWeapon';
		RequestedEquipmentName[Slot] = name(EquipmentName);
		if (WorldInfo.NetMode != NM_DedicatedServer)
			FHUD(FPlayerController(Pawn(Owner).Controller).myHUD).GFxOmniMenu.Invalidate("equipment selection");
	}
}

reliable server function ResetEquipment()
{
	local byte EquipmentSlot;
	local byte MagazineCount;
	local Inventory Item;
	local FWeapon NewWeapon;
	local FMagazine Mag;

	if (FStructure_Barracks(FPawn(Instigator).Base) != None)
	{
		DiscardInventory();

		for (EquipmentSlot = 0; EquipmentSlot < EquipmentSlots; EquipmentSlot++)
		{
			if (RequestedEquipment[EquipmentSlot] != None)
			{
				Item = Spawn(RequestedEquipment[EquipmentSlot], Owner);
				if (FWeapon(Item) != None)
				{
					NewWeapon = FWeapon(Item);
					NewWeapon.Initialize(RequestedEquipmentName[EquipmentSlot]);
					for (MagazineCount = 0; MagazineCount < NewWeapon.GetDefaultMagazines(); MagazineCount++)
					{
						Mag = FMagazine(CreateInventory(class'FMagazine'));
						Mag.AmmoType = NewWeapon.AmmoType;
					}
				}
				AddInventory(Item);
				if (Mag != None)
					NewWeapon.ServerReload();
			}
		}
	}
}

defaultproperties
{
	PendingFire(0)=0
	PendingFire(1)=0
}
