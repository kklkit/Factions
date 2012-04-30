/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSInventoryManager extends InventoryManager
	config(GameFS);

const EquipmentSlots=4;

var class<Inventory> EquipmentClass[EquipmentSlots];

replication
{
	if (bNetDirty)
		EquipmentClass;
}

reliable server function SelectEquipment(byte Slot, string EquipmentName)
{
	switch (EquipmentName) {
	case "Heavy Pistol":
		EquipmentClass[Slot] = class'FSWeap_HeavyPistol';
		break;
	case "Assault Rifle":
		EquipmentClass[Slot] = class'FSWeap_AssaultRifle';
		break;
	case "Battle Rifle":
		EquipmentClass[Slot] = class'FSWeap_BattleRifle';
		break;
	}
}

reliable server function EquipLoadout()
{
	local byte i;

	DiscardInventory();

	for (i = 0; i < EquipmentSlots; i++)
	{
		if (EquipmentClass[i] != None)
			CreateInventory(EquipmentClass[i]);
	}
}

defaultproperties
{
	PendingFire(0)=0
	PendingFire(1)=0
	bMustHoldWeapon=true
}
