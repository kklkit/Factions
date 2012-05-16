/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSWeapon extends UDKWeapon
	abstract;

var FSMagazine Magazine;
var class<FSWeaponAttachment> AttachmentClass;

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
	local FSPawn InstigatorPawn;

	Super.AttachWeaponTo(MeshCpnt, SocketName);

	InstigatorPawn = FSPawn(Instigator);

	if (Role == ROLE_Authority && InstigatorPawn != None)
	{
		InstigatorPawn.CurrentWeaponAttachmentClass = AttachmentClass;
		if (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || (WorldInfo.NetMode == NM_Client && InstigatorPawn.IsLocallyControlled()))
			InstigatorPawn.WeaponAttachmentChanged();
	}
}

simulated function DetachWeapon()
{
	local FSPawn InstigatorPawn;

	Super.DetachWeapon();

	InstigatorPawn = FSPawn(Instigator);
	if (InstigatorPawn != None && Role == ROLE_Authority && InstigatorPawn.CurrentWeaponAttachmentClass == AttachmentClass)
	{
		InstigatorPawn.CurrentWeaponAttachmentClass = None;
		if (Instigator.IsLocallyControlled())
			InstigatorPawn.WeaponAttachmentChanged();
	}
}

simulated function TimeWeaponEquipping()
{
	AttachWeaponTo(Instigator.Mesh);

	Super.TimeWeaponEquipping();
}

reliable server function ServerReload()
{
	local FSMagazine M;

	foreach InvManager.InventoryActors(class'FSMagazine', M)
		if (M.AmmoType == Self.Class)
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
	Begin Object Class=SkeletalMeshComponent Name=PickupMeshComponent
	End Object
	PickupFactoryMesh=PickupMeshComponent
	DroppedPickupMesh=PickupMeshComponent

	RespawnTime=1.0
	bDelayedSpawn=False
	bDropOnDeath=False
}
