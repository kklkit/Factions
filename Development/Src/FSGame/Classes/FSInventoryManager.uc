/**
 * Inventory manager for pawns.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSInventoryManager extends InventoryManager;

/**
 * Returns an inventory item of the given class, or none if not found.
 */
function Inventory GetInventoryOfClass(class<Inventory> InvClass)
{
	local Inventory Inv;

	Inv = InventoryChain;
	while (Inv != none)
	{
		if (Inv.Class == InvClass)
			return Inv;

		Inv = Inv.Inventory;
	}

	return none;
}

defaultproperties
{
	PendingFire(0)=0
	PendingFire(1)=0
}
