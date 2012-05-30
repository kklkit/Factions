/**
 * Equippable inventory items such as rifles or repair tools.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FWeapon extends UDKWeapon;

var FMagazine Magazine;
var name WeaponName;

replication
{
	if (bNetDirty)
		Magazine;
}

function ConsumeAmmo(byte FireModeNum)
{
	AddAmmo(-1);
}

function int AddAmmo(int Amount)
{
	AmmoCount = Magazine.AddAmmo(Amount);
	return AmmoCount;
}

simulated function bool HasAmmo(byte FireModeNum, optional int Amount)
{
	if (Amount != 0)
		return (AmmoCount >= Amount);
	else
		return (AmmoCount > 0);
}

simulated function bool HasAnyAmmo()
{
	return AmmoCount > 0;
}

simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional name SocketName)
{
	Super.AttachWeaponTo(MeshCpnt, SocketName);

	// Update equipment name on the pawn to replicate to clients
	if (Role == ROLE_Authority)
		FPawn(Instigator).EquippedWeaponName = WeaponName;

	// Update weapon attachment on local player
	if (Instigator.IsLocallyControlled())
		FPawn(Instigator).UpdateWeaponAttachment();
}

simulated function DetachWeapon()
{
	Super.DetachWeapon();

	// Clear equipment name on pawn
	if (Role == ROLE_Authority && FPawn(Instigator).EquippedWeaponName == WeaponName)
		FPawn(Instigator).EquippedWeaponName = '';

	// Update weapon attachment on local player
	if (Instigator.IsLocallyControlled())
		FPawn(Instigator).UpdateWeaponAttachment();
}

simulated function TimeWeaponEquipping()
{
	AttachWeaponTo(Instigator.Mesh);

	Super.TimeWeaponEquipping();
}

reliable server function ServerReload()
{
	local FMagazine NextMagazine;

	// Get the next magazine of the equipment's type
	foreach InvManager.InventoryActors(class'FMagazine', NextMagazine)
		if (NextMagazine.AmmoFor == Name)
			break;

	// Abort reloading if no magazine was found
	if (NextMagazine == None)
		return;

	if (Magazine != None)
	{
		// Throw away old magazine
		Magazine.Destroy();
		AmmoCount = 0;
	}

	// Remove next magazine from inventory
	InvManager.RemoveFromInventory(NextMagazine);

	// Insert magazine into weapon
	Magazine = NextMagazine;
	AmmoCount = Magazine.AmmoCount;
}

defaultproperties
{
	bCanThrow=False
}
