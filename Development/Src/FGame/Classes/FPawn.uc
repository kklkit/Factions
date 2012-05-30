/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FPawn extends UDKPawn;

var DynamicLightEnvironmentComponent LightEnvironment;
var TeamInfo LastTeam; // Used to detect when the player has joined a new team
var name WeaponSocketName;

// Weapon attachment
var repnotify name EquippedWeaponName;
var FWeaponAttachment WeaponAttachment;

replication
{
	if (bNetDirty)
		EquippedWeaponName;
}

simulated event ReplicatedEvent(name VarName)
{
	Super.ReplicatedEvent(VarName);

	if (VarName == 'EquippedWeaponName')
		UpdateWeaponAttachment();
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	// Sets skeletal controls for animations to play correctly
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
	if (WeaponAttachment != None)
	{
		WeaponAttachment.DetachFrom(Mesh);
		WeaponAttachment.Destroy();
		WeaponAttachment = None;
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
	if (WeaponAttachment != None)
	{
		if (IsFirstPerson())
			WeaponAttachment.FirstPersonFireEffects(Weapon, HitLocation);
		else
			WeaponAttachment.ThirdPersonFireEffects(HitLocation);
	}

	Super.WeaponFired(InWeapon, bViaReplication, HitLocation);
}

simulated function WeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
	if (WeaponAttachment != None)
	{
		WeaponAttachment.StopFirstPersonFireEffects(Weapon);
		WeaponAttachment.StopThirdPersonFireEffects();
	}

	Super.WeaponStoppedFiring(InWeapon, bViaReplication);
}

simulated function Rotator GetAdjustedAimFor(Weapon W, Vector StartFireLoc)
{
	local Vector MuzVec;
	local Rotator MuzRot;
	
	if (WeaponAttachment == None)
		return GetBaseAimRotation();

	WeaponAttachment.Mesh.GetSocketWorldLocationAndRotation(WeaponAttachment.MuzzleSocketName, MuzVec, MuzRot);

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
	local FWeaponAttachment WeaponAttachmentArchetype;

	if (Mesh.SkeletalMesh != None)
	{
		if (WeaponAttachment != None)
		{
			// Delete current weapon attachment
			WeaponAttachment.DetachFrom(Mesh);
			WeaponAttachment.Destroy();
		}

		if (EquippedWeaponName != '')
		{
			WeaponAttachmentArchetype = FMapInfo(WorldInfo.GetMapInfo()).GetWeaponInfo(EquippedWeaponName).AttachmentArchetype;

			// Create the new weapon attachment
			WeaponAttachment = Spawn(WeaponAttachmentArchetype.Class, Self,,,, WeaponAttachmentArchetype);

			if (WeaponAttachment != None)
			{
				WeaponAttachment.Instigator = Self;
				WeaponAttachment.AttachTo(Self);
				WeaponAttachment.ChangeVisibility(True);
			}
			else
			{
				`log("Failed to spawn weapon attachment for archetype" @ WeaponAttachmentArchetype @ "for weapon" @ EquippedWeaponName @ "!");
			}
		}
	}
}

function PlayerChangedTeam()
{
	if (LastTeam != None)
		Super.PlayerChangedTeam();

	LastTeam = GetTeam();
}

exec function ResetEquipment()
{
	FInventoryManager(InvManager).ResetEquipment();
}

defaultproperties
{
	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0021.000000
		CollisionHeight=+0044.000000
	End Object
	CylinderComponent=CollisionCylinder

	Begin Object Class=DynamicLightEnvironmentComponent Name=LightEnvironment0
	End Object
	Components.Add(LightEnvironment0)
	LightEnvironment=LightEnvironment0

	Begin Object Class=SkeletalMeshComponent Name=SkeletalMesh0
		SkeletalMesh=SkeletalMesh'Factions_Assets.Mesh.CH_IronGuard'
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		LightEnvironment=LightEnvironment0
		BlockRigidBody=True
		bHasPhysicsAssetInstance=True
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=True)
	End Object
	Mesh=SkeletalMesh0
	Components.Add(SkeletalMesh0)

	InventoryManagerClass=class'FInventoryManager'
	bCanCrouch=True
	WeaponSocketName=WeaponPoint
	LeftFootControlName=LeftFootControl
	RightFootControlName=RightFootControl
	bEnableFootPlacement=True
}