/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FWeapon extends UDKWeapon
	dependson(FWeaponInfo)
	abstract;

var FMagazine Magazine;
var class<FWeaponAttachment> AttachmentClass;
var WeaponInfo WeaponInfo;
var name AmmoType;

replication
{
	if (bNetDirty)
		Magazine, WeaponInfo, AmmoType;
}

function Initialize(name WeaponName)
{
	local int Index;

	AmmoType = WeaponName;

	// Set weapon info
	Index = class'FWeaponInfo'.default.Weapons.Find('Name', WeaponName);
	if (Index != INDEX_NONE)
		WeaponInfo = class'FWeaponInfo'.default.Weapons[Index];
	else
		`Log("Failed to find weapon info for weapon" @ WeaponName);
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

	if (Role == ROLE_Authority)
		FPawn(Instigator).CurrentWeaponInfo = WeaponInfo;

	if (Instigator.IsLocallyControlled())
		FPawn(Instigator).UpdateWeaponAttachment();
}

simulated function DetachWeapon()
{
	Super.DetachWeapon();

	if (Role == ROLE_Authority && FPawn(Instigator).CurrentWeaponInfo == WeaponInfo)
		FPawn(Instigator).CurrentWeaponInfo.Name = '';

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
	local FMagazine M;

	foreach InvManager.InventoryActors(class'FMagazine', M)
		if (M.AmmoType == AmmoType)
			break;

	if (M == None)
		return;

	if (Magazine != None)
	{
		Magazine.Destroy();
		AmmoCount = 0;
	}

	InvManager.RemoveFromInventory(M);
	Magazine = M;
	AmmoCount = Magazine.AmmoCount;
}

function int GetDefaultMagazines()
{
	return 4;
}

defaultproperties
{
	RespawnTime=1.0
	bDelayedSpawn=False
	bDropOnDeath=False
	bCanThrow=False
}
