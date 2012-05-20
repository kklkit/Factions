/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSPawn extends UDKPawn
	dependson(FSWeaponInfo);

var DynamicLightEnvironmentComponent LightEnvironment;
var name WeaponSocket;

// Weapon attachment
var repnotify WeaponInfo CurrentWeaponInfo;
var FSWeaponAttachment CurrentWeaponAttachment;
var bool bWeaponAttachmentVisible;

replication
{
	if (bNetDirty)
		CurrentWeaponInfo;
}

simulated event ReplicatedEvent(name VarName)
{
	Super.ReplicatedEvent(VarName);

	if (VarName == 'CurrentWeaponInfo')
		UpdateWeaponAttachment();
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
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

simulated event Destroyed()
{
	if (CurrentWeaponAttachment != None)
	{
		CurrentWeaponAttachment.DetachFrom(Mesh);
		CurrentWeaponAttachment.Destroy();
	}

	Super.Destroyed();
}

simulated function PlayDying(class<DamageType> DamageType, Vector HitLoc)
{
	Super.PlayDying(DamageType, HitLoc);
	
	Mesh.MinDistFactorForKinematicUpdate = 0.0;
	Mesh.SetRBChannel(RBCC_Pawn);
	Mesh.SetRBCollidesWithChannel(RBCC_Default, True);
	Mesh.SetRBCollidesWithChannel(RBCC_Pawn, False);
	Mesh.SetRBCollidesWithChannel(RBCC_Vehicle, False);
	Mesh.SetRBCollidesWithChannel(RBCC_Untitled3, False);
	Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume, True);
	Mesh.ForceSkelUpdate();
	Mesh.SetTickGroup(TG_PostAsyncWork);
	PreRagdollCollisionComponent = CollisionComponent;
	CollisionComponent = Mesh;
	CylinderComponent.SetActorCollision(False, False);
	Mesh.SetActorCollision(True, False);
	Mesh.SetTraceBlocking(True, True);
	SetPhysics(PHYS_RigidBody);
	Mesh.PhysicsWeight = 1.0;

	if (Mesh.bNotUpdatingKinematicDueToDistance)
		Mesh.UpdateRBBonesFromSpaceBases(True, True);

	Mesh.PhysicsAssetInstance.SetAllBodiesFixed(False);
	Mesh.bUpdateKinematicBonesFromAnimation = False;
	Mesh.SetRBLinearVelocity(Velocity, False);
	Mesh.ScriptRigidBodyCollisionThreshold = MaxFallSpeed;
	Mesh.SetNotifyRigidBodyCollision(True);
	Mesh.WakeRigidBody();
}

simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	if (CurrentWeaponAttachment != None)
	{
		if (IsFirstPerson())
			CurrentWeaponAttachment.FirstPersonFireEffects(Weapon, HitLocation);
		else
			CurrentWeaponAttachment.ThirdPersonFireEffects(HitLocation);
	}

	Super.WeaponFired(InWeapon, bViaReplication, HitLocation);
}

simulated function WeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
	if (CurrentWeaponAttachment != None)
	{
		CurrentWeaponAttachment.StopFirstPersonFireEffects(Weapon);
		CurrentWeaponAttachment.StopThirdPersonFireEffects();
	}

	Super.WeaponStoppedFiring(InWeapon, bViaReplication);
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

simulated function UpdateWeaponAttachment()
{
	if (Mesh.SkeletalMesh != None)
	{
		if (CurrentWeaponAttachment != None) // Delete current weapon attachment
		{
			CurrentWeaponAttachment.DetachFrom(Mesh);
			CurrentWeaponAttachment.Destroy();
			CurrentWeaponAttachment = None;
		}

		if (CurrentWeaponInfo.Name != '') // Create new weapon attachment
		{
			CurrentWeaponAttachment = Spawn(class'FSFirearmAttachment', Self); //@todo set this to the actual weapon attachment

			if (CurrentWeaponAttachment != None) // Attach new weapon attachment to the mesh
			{
				CurrentWeaponAttachment.WeaponInfo = CurrentWeaponInfo;
				CurrentWeaponAttachment.Instigator = Self;
				CurrentWeaponAttachment.AttachTo(Self);
				CurrentWeaponAttachment.ChangeVisibility(bWeaponAttachmentVisible);
			}
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
	End Object
	Mesh=PawnMeshComponent
	Components.Add(PawnMeshComponent)

	InventoryManagerClass=class'FSInventoryManager'

	bCanCrouch=True
	bWeaponAttachmentVisible=True

	WeaponSocket=WeaponPoint
	LeftFootControlName=LeftFootControl
	RightFootControlName=RightFootControl
	bEnableFootPlacement=True
}