/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSPawn extends UDKPawn
	config(GameFS)
	notplaceable;

var DynamicLightEnvironmentComponent LightEnvironment;

var repnotify class<FSWeaponAttachment> CurrentWeaponAttachmentClass;
var FSWeaponAttachment CurrentWeaponAttachment;
var name WeaponSocket;
var bool bWeaponAttachmentVisible;

replication
{
	if (bNetDirty)
		CurrentWeaponAttachmentClass;
}

simulated function ReplicatedEvent(name VarName)
{
	if (VarName == 'CurrentWeaponAttachmentClass')
		WeaponAttachmentChanged();

	Super.ReplicatedEvent(VarName);
}

simulated function PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	if (SkelComp == Mesh)
	{
		LeftLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(LeftFootControlName));
		RightLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(RightFootControlName));
		LeftHandIK = SkelControlLimb(Mesh.FindSkelControl('LeftHandIK'));
		RightHandIK = SkelControlLimb(Mesh.FindSkelControl('RightHandIK'));
		RootRotControl = SkelControlSingleBone(Mesh.FindSkelControl('RootRot'));
		AimNode = AnimNodeAimOffset(Mesh.FindAnimNode('AimNode'));
		GunRecoilNode = GameSkelCtrl_Recoil(Mesh.FindSkelControl('GunRecoilNode'));
		LeftRecoilNode = GameSkelCtrl_Recoil(Mesh.FindSkelControl('LeftRecoilNode'));
		RightRecoilNode = GameSkelCtrl_Recoil(Mesh.FindSkelControl('RightRecoilNode'));
		FlyingDirOffset = AnimNodeAimOffset(Mesh.FindAnimNode('FlyingDirOffset'));
	}
}

simulated function Destroyed()
{
	Super.Destroyed();

	if (CurrentWeaponAttachment != None)
	{
		CurrentWeaponAttachment.DetachFrom(Mesh);
		CurrentWeaponAttachment.Destroy();
	}
}

simulated function NotifyTeamChanged()
{
	Super.NotifyTeamChanged();

	if (CurrentWeaponAttachmentClass != None)
	{
		if (WorldInfo.NetMode != NM_DedicatedServer && CurrentWeaponAttachment != None)
		{
			CurrentWeaponAttachment.DetachFrom(Mesh);
			CurrentWeaponAttachment.Destroy();
			CurrentWeaponAttachment = None;
		}
		WeaponAttachmentChanged();
	}
}

simulated function PlayDying(class<DamageType> DamageType, Vector HitLoc)
{
	CurrentWeaponAttachmentClass = None;
	WeaponAttachmentChanged();

	SetPhysics(PHYS_RigidBody);

	PreRagdollCollisionComponent = CollisionComponent;
	CollisionComponent = Mesh;
	
	Mesh.PhysicsWeight = 1.0;
	Mesh.bUpdateJointsFromAnimation = True;
	Mesh.SetRBChannel(RBCC_Pawn);
	Mesh.SetRBCollidesWithChannel(RBCC_Default, True);
	Mesh.SetRBCollidesWithChannel(RBCC_Pawn, True);
	Mesh.SetRBCollidesWithChannel(RBCC_Vehicle, True);
	Mesh.SetRBCollidesWithChannel(RBCC_Untitled3, False);
	Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume, True);
	Mesh.PhysicsAssetInstance.SetAllBodiesFixed(False);

	Super.PlayDying(DamageType, HitLoc);
}

simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	Super.WeaponFired(InWeapon, bViaReplication, HitLocation);

	if (CurrentWeaponAttachment != None)
	{
		if (IsFirstPerson())
			CurrentWeaponAttachment.FirstPersonFireEffects(Weapon, HitLocation);
		else
			CurrentWeaponAttachment.ThirdPersonFireEffects(HitLocation);
	}
}

simulated function WeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
	Super.WeaponStoppedFiring(InWeapon, bViaReplication);

	if (CurrentWeaponAttachment != None)
	{
		CurrentWeaponAttachment.StopFirstPersonFireEffects(Weapon);
		CurrentWeaponAttachment.StopThirdPersonFireEffects();
	}
}

simulated function Rotator GetAdjustedAimFor(Weapon W, Vector StartFireLoc)
{
	local Vector MuzVec;
	local Rotator MuzRot;
	
	if (CurrentWeaponAttachment == None)
		return GetBaseAimRotation();

	CurrentWeaponAttachment.Mesh.GetSocketWorldLocationAndRotation(CurrentWeaponAttachment.MuzzleSocket, MuzVec, MuzRot);

	return MuzRot;
}

simulated function bool CalcCamera(float fDeltaTime, out vector out_CamLoc, out Rotator out_CamRot, out float out_FOV)
{
	Mesh.GetSocketWorldLocationAndRotation('Eyes', out_CamLoc);
	out_CamRot = GetViewRotation();
	return True;
}

simulated function WeaponAttachmentChanged()
{
	if ((CurrentWeaponAttachment == None || CurrentWeaponAttachment.Class != CurrentWeaponAttachmentClass) && Mesh.SkeletalMesh != None)
	{
		if (CurrentWeaponAttachment != None)
		{
			CurrentWeaponAttachment.DetachFrom(Mesh);
			CurrentWeaponAttachment.Destroy();
		}

		if (CurrentWeaponAttachmentClass != None)
		{
			CurrentWeaponAttachment = Spawn(CurrentWeaponAttachmentClass, self);
			CurrentWeaponAttachment.Instigator = self;
		}
		else
			CurrentWeaponAttachment = None;

		if (CurrentWeaponAttachment != None)
		{
			CurrentWeaponAttachment.AttachTo(self);
			CurrentWeaponAttachment.ChangeVisibility(bWeaponAttachmentVisible);
		}
	}
}

exec function ResetEquipment()
{
	FSInventoryManager(InvManager).ResetEquipment();
}

defaultproperties
{
	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0021.000000
		CollisionHeight=+0044.000000
	End Object
	CylinderComponent=CollisionCylinder

	Begin Object Class=DynamicLightEnvironmentComponent Name=PawnLightEnvironmentComponent
	End Object
	Components.Add(PawnLightEnvironmentComponent)
	LightEnvironment=PawnLightEnvironmentComponent

	Begin Object Class=SkeletalMeshComponent Name=PawnMeshComponent
		SkeletalMesh=SkeletalMesh'FSAssets.Mesh.IronGuard'
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		LightEnvironment=PawnLightEnvironmentComponent
		BlockRigidBody=True
		bHasPhysicsAssetInstance=True
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=True)
		Scale=1.075
	End Object
	Mesh=PawnMeshComponent
	Components.Add(PawnMeshComponent)

	BaseTranslationOffset=6.0

	InventoryManagerClass=class'FSInventoryManager'

	bCanCrouch=True
	bCanPickupInventory=True
	bWeaponAttachmentVisible=True

	WeaponSocket=WeaponPoint
	LeftFootControlName=LeftFootControl
	RightFootControlName=RightFootControl
	bEnableFootPlacement=True
}