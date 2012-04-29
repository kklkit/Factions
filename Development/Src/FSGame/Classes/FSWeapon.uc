/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSWeapon extends UDKWeapon
	config(WeaponFS)
	abstract;

var class<FSWeaponAttachment> AttachmentClass;
var repnotify int AmmoCountMax;

function ConsumeAmmo(byte FireModeNum)
{
	Super.ConsumeAmmo(FireModeNum);

	AddAmmo(-1);
}

function int AddAmmo(int Amount)
{
	Super.AddAmmo(Amount);

	AmmoCount = Clamp(AmmoCount + Amount, 0, AmmoCountMax);

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
		{
			InstigatorPawn.WeaponAttachmentChanged();
		}
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
		{
			InstigatorPawn.WeaponAttachmentChanged();
		}
	}
}

simulated function TimeWeaponEquipping()
{
	AttachWeaponTo(Instigator.Mesh);

	Super.TimeWeaponEquipping();
}

defaultproperties
{
	Begin Object Class=SkeletalMeshComponent Name=PickupMeshComponent
	End Object
	PickupFactoryMesh=PickupMeshComponent
	DroppedPickupMesh=PickupMeshComponent

	RespawnTime=1.0
	bDelayedSpawn=false
}
