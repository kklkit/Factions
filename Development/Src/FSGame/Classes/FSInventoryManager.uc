/**
 * Inventory manager for pawns.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSInventoryManager extends InventoryManager
	config(GameFS);

var Weapon PreviousWeapon;
var FSWeapon PendingSwitchWeapon;
var float LastAdjustWeaponTime;

/**
 * Sets the weapon to the given weapon.
 */
reliable client function ClientSyncWeapon(Weapon NewWeapon)
{
	local Weapon OldWeapon;

	if (NewWeapon == Instigator.Weapon)
	{
		return;
	}

	`LogInv("Forcing weapon:" @ NewWeapon @ "from:" @ Instigator.Weapon);

	OldWeapon = Instigator.Weapon;

	Instigator.Weapon = NewWeapon;
	Instigator.PlayWeaponSwitch(OldWeapon, NewWeapon);

	if (NewWeapon != None)
	{
		Instigator.Weapon.Instigator = Instigator;

		if (WorldInfo.Game != None)
		{
			Instigator.MakeNoise(0.1, 'ChangedWeapon' );
		}

		Instigator.Weapon.Activate();
	}

	if (Instigator.Controller != None)
	{
		Instigator.Controller.NotifyChangedWeapon(OldWeapon, Instigator.Weapon);
	}
}

/**
 * Returns weapons sorted by inventory weight.
 */
simulated function GetWeaponList(out array<FSWeapon> WeaponList, optional bool bFilter, optional int GroupFilter, optional bool bNoEmpty)
{
	local FSWeapon Weap;
	local int i;

	ForEach InventoryActors( class'FSWeapon', Weap )
	{
		if ((!bFilter || Weap.InventoryGroup == GroupFilter) && (!bNoEmpty || Weap.HasAnyAmmo()))
		{
			if (WeaponList.Length > 0)
			{
				for (i = 0; i < WeaponList.Length; i++)
				{
					if (WeaponList[i].InventoryWeight > Weap.InventoryWeight)
					{
						WeaponList.Insert(i,1);
						WeaponList[i] = Weap;
						break;
					}
				}
				if (i == WeaponList.Length)
				{
					WeaponList.Length = WeaponList.Length + 1;
					WeaponList[i] = Weap;
				}
			}
			else
			{
				WeaponList.Length = 1;
				WeaponList[0] = Weap;
			}
		}
	}
}

/**
 * Switch to the given weapon group.
 */
simulated function SwitchWeapon(byte NewGroup)
{
	local FSWeapon CurrentWeapon;
	local array<FSWeapon> WeaponList;
	local int NewIndex;

	GetWeaponList(WeaponList, true, NewGroup);

	if (WeaponList.Length <= 0)
		return;

	CurrentWeapon = FSWeapon(PendingWeapon);
	if (CurrentWeapon == None)
	{
		CurrentWeapon = FSWeapon(Instigator.Weapon);
	}

	if (CurrentWeapon == none || CurrentWeapon.InventoryGroup != NewGroup)
	{
		NewIndex = 0;
	}
	else
	{
		for (NewIndex=0; NewIndex < WeaponList.Length; NewIndex++)
		{
			if (WeaponList[NewIndex] == CurrentWeapon)
				break;
		}
		NewIndex++;
		if (NewIndex >= WeaponList.Length)
			NewIndex = 0;
	}

	if (WeaponList[NewIndex].HasAnyAmmo())
	{
		SetCurrentWeapon(WeaponList[NewIndex]);
	}
}

simulated function AdjustWeapon(int NewOffset)
{
	local Weapon CurrentWeapon;
	local array<FSWeapon> WeaponList;
	local int i, Index;

	if (WorldInfo.TimeSeconds - LastAdjustWeaponTime < 0.05)
	{
		return;
	}
	LastAdjustWeaponTime = WorldInfo.TimeSeconds;

	CurrentWeapon = FSWeapon(PendingWeapon);
	if (CurrentWeapon == None)
	{
		CurrentWeapon = FSWeapon(Instigator.Weapon);
	}

	GetWeaponList(WeaponList, , , true);
	if (WeaponList.length == 0)
	{
		return;
	}

	for (i = 0; i < WeaponList.Length; i++)
	{
		if (WeaponList[i] == CurrentWeapon)
		{
			Index = i;
			break;
		}
	}

	Index += NewOffset;
	if (Index < 0)
	{
		Index = WeaponList.Length - 1;
	}
	else if (Index >= WeaponList.Length)
	{
		Index = 0;
	}

	if (Index >= 0)
	{
		SetCurrentWeapon(WeaponList[Index]);
	}
}

/**
 * Override.
 * 
 * @extends
 */
simulated function PrevWeapon()
{
	if (FSWeapon(Pawn(Owner).Weapon) != None && FSWeapon(Pawn(Owner).Weapon).DoOverridePrevWeapon())
		return;

	AdjustWeapon(-1);
}

/**
 * Override.
 * 
 * @extends
 */
simulated function NextWeapon()
{
	if (FSWeapon(Pawn(Owner).Weapon) != None && FSWeapon(Pawn(Owner).Weapon).DoOverrideNextWeapon())
		return;

	AdjustWeapon(+1);
}

/**
 * Override.
 * 
 * @extends
 */
reliable client function SetCurrentWeapon(Weapon DesiredWeapon)
{
	SetPendingWeapon(DesiredWeapon);

	if (Role < Role_Authority)
	{
		ServerSetCurrentWeapon(DesiredWeapon);
	}
}

/**
 * Begins a weapon switch on the client.
 */
reliable client function ClientSetCurrentWeapon(Weapon DesiredWeapon)
{
	SetPendingWeapon(DesiredWeapon);
}

/**
 * Override.
 * 
 * @extends
 */
reliable server function ServerSetCurrentWeapon(Weapon DesiredWeapon)
{
	SetPendingWeapon(DesiredWeapon);
}

/**
 * Override.
 * 
 * @extends
 */
simulated function SetPendingWeapon(Weapon DesiredWeapon)
{
	local FSWeapon PrevWeapon, CurrentPending;
	local FSPawn FSP;

	if (Instigator == None)
	{
		return;
	}

	PrevWeapon = FSWeapon(Instigator.Weapon);
	CurrentPending = FSWeapon(PendingWeapon);

	if ((PrevWeapon == None || PrevWeapon.AllowSwitchTo(DesiredWeapon)) && (CurrentPending == None || CurrentPending.AllowSwitchTo(DesiredWeapon)))
	{
		if (DesiredWeapon != None && DesiredWeapon == Instigator.Weapon)
		{
			if (PendingWeapon != None)
			{
				PendingWeapon = None;
			}
			else
			{
				PrevWeapon.ServerReselectWeapon();
			}

			if (!PrevWeapon.bReadyToFire())
			{
				PrevWeapon.Activate();
			}
			else
			{
				PrevWeapon.bWeaponPutDown = false;
			}
		}
		else
		{
			PendingWeapon = DesiredWeapon;

			if (PrevWeapon != None && !PrevWeapon.bDeleteMe && !PrevWeapon.IsInState('Inactive'))
			{
				PrevWeapon.TryPutDown();
			}
			else
			{
				ChangedWeapon();
			}
		}
	}

	FSP = FSPawn(Instigator);
	if (FSP != None)
	{
		FSP.SetPuttingDownWeapon((PendingWeapon != None));
	}
}

/**
 * Override.
 * 
 * @extends
 */
simulated function ClientWeaponSet(Weapon NewWeapon, bool bOptionalSet, optional bool bDoNotActivate)
{
	local Weapon OldWeapon;

	OldWeapon = Instigator.Weapon;

	// If no current weapon, then set this one
	if (OldWeapon == None || OldWeapon.bDeleteMe || OldWeapon.IsInState('Inactive'))
	{
		SetCurrentWeapon(NewWeapon);
		return;
	}

	if (OldWeapon == NewWeapon)
	{
		return;
	}

	if (!bOptionalSet)
	{
		SetCurrentWeapon(NewWeapon);
		return;
	}

	if (Instigator.IsHumanControlled() && PlayerController(Instigator.Controller).bNeverSwitchOnPickup)
	{
		NewWeapon.GotoState('Inactive');
		return;
	}
	
	if (OldWeapon.IsFiring() || OldWeapon.DenyClientWeaponSet() && (FSWeapon(NewWeapon) != None))
	{
		NewWeapon.GotoState('Inactive');
		RetrySwitchTo(FSWeapon(NewWeapon));
			return;
		}

		if ((PendingWeapon == None || !PendingWeapon.HasAnyAmmo() || PendingWeapon.GetWeaponRating() < NewWeapon.GetWeaponRating()) &&
			(!Instigator.Weapon.HasAnyAmmo() || Instigator.Weapon.GetWeaponRating() < NewWeapon.GetWeaponRating()) )
		{
			SetCurrentWeapon(NewWeapon);
			return;
		}

	NewWeapon.GotoState('Inactive');
}

/**
 * @extends
 */
simulated function Inventory CreateInventory(class<Inventory> NewInventoryItemClass, optional bool bDoNotActivate)
{
	if (Role == ROLE_Authority)
	{
		return Super.CreateInventory(NewInventoryItemClass, bDoNotActivate);
	}
	return none;
}

/**
 * Switches to the pending weapon.
 */
simulated function ProcessRetrySwitch()
{
	local FSWeapon NewWeapon;

	NewWeapon = PendingSwitchWeapon;
	PendingSwitchWeapon = None;
	if (NewWeapon != None)
	{
		CheckSwitchTo(NewWeapon);
	}
}

/**
 * Tries switching to the given weapon.
 */
simulated function RetrySwitchTo(FSWeapon NewWeapon)
{
	PendingSwitchWeapon = NewWeapon;
	SetTimer(0.1, false, 'ProcessRetrySwitch');
}

/**
 * Check if the server weapon needs to be switched.
 */
simulated function CheckSwitchTo(FSWeapon NewWeapon)
{
	if (FSWeapon(Instigator.Weapon) == None ||
			(Instigator != None && PlayerController(Instigator.Controller) != None &&
				FSWeapon(Instigator.Weapon).ShouldSwitchTo(NewWeapon)))
	{
		NewWeapon.ClientWeaponSet(true);
	}
}

/**
 * @extends
 */
simulated function bool AddInventory(Inventory NewItem, optional bool bDoNotActivate)
{
	local bool bResult;

	if (Role == ROLE_Authority)
	{
		bResult = super.AddInventory(NewItem, bDoNotActivate);

		if (bResult && FSWeapon(NewItem) != None)
		{
			if (!bDoNotActivate)
			{
				CheckSwitchTo(FSWeapon(NewItem));
			}
		}
	}

	return bResult;
}

/**
 * @extends
 */
simulated function DiscardInventory()
{
	local Vehicle V;

	if (Role == ROLE_Authority)
	{
		Super.DiscardInventory();

		V = Vehicle(Owner);
		if (V != None && V.Driver != None && V.Driver.InvManager != None)
		{
			V.Driver.InvManager.DiscardInventory();
		}
	}
}

/**
 * @extends
 */
simulated function RemoveFromInventory(Inventory ItemToRemove)
{
	if (Role == ROLE_Authority)
	{
		Super.RemoveFromInventory(ItemToRemove);
		if (PendingSwitchWeapon == ItemToRemove)
		{
			PendingSwitchWeapon = None;
			ClearTimer('ProcessRetrySwitch');
		}
	}
}

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

/**
 * @extends
 */
simulated function ChangedWeapon()
{
	local FSWeapon Wep;
	local FSPawn FSP;

	PreviousWeapon = Instigator.Weapon;
	Super.ChangedWeapon();

	Wep = FSWeapon(Instigator.Weapon);

	// Clear out Pending fires if the weapon doesn't allow them

	if (Wep != none && Wep.bNeverForwardPendingFire)
	{
		ClearAllPendingFire(Wep);
	}

	FSP = FSPawn(Instigator);
	if (FSP != None)
	{
		FSP.SetPuttingDownWeapon((PendingWeapon != None));
	}
}

defaultproperties
{
	PendingFire(0)=0
	PendingFire(1)=0
}
