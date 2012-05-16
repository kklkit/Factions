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
	}
}

reliable server function ResetEquipment()
{
	local byte EquipmentSlot;
	local byte i;
	local Inventory Item;
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
					FSWeapon(Item).Initialize(RequestedEquipmentName[EquipmentSlot]);
					for (i = 0; i < FSWeapon(Item).GetDefaultMagazines(); i++)
					{
						Mag = FSMagazine(CreateInventory(class'FSMagazine'));
						Mag.AmmoType = FSWeapon(Item).AmmoType;
					}
				}
				AddInventory(Item);
			}
		}
	}
}

defaultproperties
{
	PendingFire(0)=0
	PendingFire(1)=0
}
