/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSInventoryManager extends InventoryManager;

const EquipmentSlots=4;

var class<Inventory> RequestedEquipment[EquipmentSlots];

replication
{
	if (bNetDirty)
		RequestedEquipment;
}

reliable server function SelectEquipment(byte Slot, string EquipmentName)
{
	if (Slot >= 0 && Slot < EquipmentSlots)
	{
		switch (EquipmentName) {
		case "Heavy Pistol":
			RequestedEquipment[Slot] = class'FSWeap_HeavyPistol';
			break;
		case "Assault Rifle":
			RequestedEquipment[Slot] = class'FSWeap_AssaultRifle';
			break;
		case "Battle Rifle":
			RequestedEquipment[Slot] = class'FSWeap_BattleRifle';
			break;
		default:
			`log("Unknown equipment selected!");
			break;
		}
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
				Item = CreateInventory(RequestedEquipment[EquipmentSlot]);
				if (FSWeapon(Item) != None)
				{
					for (i = 0; i < FSWeapon(Item).GetDefaultMagazines(); i++)
					{
						Mag = FSMagazine(CreateInventory(class'FSMagazine'));
						Mag.AmmoType = RequestedEquipment[EquipmentSlot];
					}
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
