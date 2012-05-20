/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSInventoryManager extends InventoryManager;

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
		RequestedEquipment[Slot] = class'FSFirearmWeapon';
		RequestedEquipmentName[Slot] = name(EquipmentName);
		if (WorldInfo.NetMode != NM_DedicatedServer)
			FSHUD(FSPlayerController(Pawn(Owner).Controller).myHUD).GFxOmniMenu.Invalidate("equipment selection");
	}
}

reliable server function ResetEquipment()
{
	local byte EquipmentSlot;
	local byte MagazineCount;
	local Inventory Item;
	local FSWeapon NewWeapon;
	local FSMagazine Mag;

	if (FSStruct_Barracks(FSPawn(Instigator).Base) != None)
	{
		DiscardInventory();

		for (EquipmentSlot = 0; EquipmentSlot < EquipmentSlots; EquipmentSlot++)
		{
			if (RequestedEquipment[EquipmentSlot] != None)
			{
				Item = Spawn(RequestedEquipment[EquipmentSlot], Owner);
				if (FSWeapon(Item) != None)
				{
					NewWeapon = FSWeapon(Item);
					NewWeapon.Initialize(RequestedEquipmentName[EquipmentSlot]);
					for (MagazineCount = 0; MagazineCount < NewWeapon.GetDefaultMagazines(); MagazineCount++)
					{
						Mag = FSMagazine(CreateInventory(class'FSMagazine'));
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
