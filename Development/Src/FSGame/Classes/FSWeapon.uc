class FSWeapon extends UDKWeapon
	config(WeaponFS)
	abstract;

var class<FSWeaponAttachment> AttachmentClass;
var repnotify int AmmoCountMax;

function ConsumeAmmo(byte FireModeNum)
{
	AddAmmo(-1);
}

function int AddAmmo(int Amount)
{
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
	Begin Object Class=AnimNodeSequence Name=MeshSequenceA
		bCauseActorAnimEnd=true
	End Object

	Begin Object Class=SkeletalMeshComponent Name=PickupMesh
		bOnlyOwnerSee=false
	End Object

	PickupFactoryMesh=PickupMesh
	DroppedPickupMesh=PickupMesh

	FiringStatesArray(0)=WeaponFiring
	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponProjectiles(0)=None
	FireInterval(0)=+0.1
	Spread(0)=0.0
	InstantHitDamage(0)=100.0
	InstantHitMomentum(0)=5.0
	InstantHitDamageTypes(0)=class'DamageType'
	ShouldFireOnRelease(0)=0

	EquipTime=+0.45
	PutDownTime=+0.33
	WeaponRange=22000

	AimTraceRange=22000

	AmmoCount=30
	AmmoCountMax=30

	RespawnTime=1.0

	bDelayedSpawn=false
}
