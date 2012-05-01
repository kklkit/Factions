/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSInventoryManager extends InventoryManager
	config(GameFS);

const NumSlots=4;

var class<Inventory> RequestedEquipment[NumSlots];

replication
{
	if (bNetDirty)
		RequestedEquipment;
}

reliable server function SelectEquipment(byte Slot, string EquipmentName)
{
	if (Slot >= 0 && Slot < NumSlots)
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
			return;
		}
	}

	FSHUD(FSPlayerController(FSPawn(Instigator).Controller).myHUD).GFxOmniMenu.UpdateEquipmentSelection(Slot, EquipmentName);
}

reliable server function ResetEquipment()
{
	local byte i;

	if (FSStruct_Barracks(FSPawn(Instigator).Base) != None)
	{
		DiscardInventory();

		for (i = 0; i < NumSlots; i++)
			if (RequestedEquipment[i] != None)
				CreateInventory(RequestedEquipment[i]);
	}
}

defaultproperties
{
	PendingFire(0)=0
	PendingFire(1)=0
	bMustHoldWeapon=true
}
