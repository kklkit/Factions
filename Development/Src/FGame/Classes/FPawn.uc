/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FPawn extends UDKPawn;

var DynamicLightEnvironmentComponent LightEnvironment;
var TeamInfo LastTeam; // Used to detect when the player has joined a new team
var name WeaponSocketName;

var float Bob;
var	float AppliedBob;
var float BobTime;
var	Vector	WalkBob;

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

event UpdateEyeHeight(float DeltaTime)
{
	local Vector X, Y, Z;
	local float Speed2D;

	Bob = FClamp(Bob, -0.05, 0.05);
	GetAxes(Rotation, X, Y, Z);
	Speed2D = VSize(Velocity);
	if (Speed2D < 10.0)
		BobTime += 0.2 * DeltaTime;
	else
		BobTime += DeltaTime * (0.3 + 0.7 * Speed2D / GroundSpeed);
	WalkBob = Y * Bob * Speed2D * sin(8 * BobTime);
	AppliedBob = AppliedBob * (1 - FMin(1, 16 * DeltaTime));
	WalkBob.Z = AppliedBob;
	if (Speed2D > 10.0)
		WalkBob.Z = WalkBob.Z + 0.75 * Bob * Speed2D * sin(16 * BobTime);
}

simulated function Vector WeaponBob(float BobDamping)
{
	local Vector BobAmount;

	BobAmount = BobDamping * WalkBob;
	BobAmount.Z = (0.45 + 0.55 * BobDamping) * WalkBob.Z;
	return BobAmount;
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

simulated function bool CalcCamera( float fDeltaTime, out Vector out_CamLoc, out Rotator out_CamRot, out float out_FOV )
{
	local bool bUseCamera;

	if (IsFirstPerson())
	{
		GetActorEyesViewPoint(out_CamLoc, out_CamRot);
		bUseCamera = True;
	}
	else
	{
		bUseCamera = False;
	}

	return bUseCamera;
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
		CollisionRadius=21.0
		CollisionHeight=44.0
	End Object
	CylinderComponent=CollisionCylinder

	Begin Object Class=DynamicLightEnvironmentComponent Name=LightEnvironment0
		bSynthesizeSHLight=True
		bIsCharacterLightEnvironment=True
		bUseBooleanEnvironmentShadowing=False
		InvisibleUpdateTime=1
		MinTimeBetweenFullUpdates=0.2
	End Object
	Components.Add(LightEnvironment0)
	LightEnvironment=LightEnvironment0

	Begin Object Class=SkeletalMeshComponent Name=SkeletalMesh0
		SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		Translation=(Z=8.0)
		Scale=1.075
		LightEnvironment=LightEnvironment0
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=True)
		BlockRigidBody=True
		bHasPhysicsAssetInstance=True
		bEnableFullAnimWeightBodies=True
		bOwnerNoSee=True
		CastShadow=True
		bCastDynamicShadow=true
	End Object
	Mesh=SkeletalMesh0
	Components.Add(SkeletalMesh0)

	InventoryManagerClass=class'FInventoryManager'
	FallImpactSound=SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_BodyImpact_BodyFall_Cue'

	BaseTranslationOffset=6.0
	WalkingPct=0.4
	CrouchedPct=0.4
	BaseEyeHeight=38.0
	EyeHeight=38.0
	GroundSpeed=440.0
	AirSpeed=440.0
	WaterSpeed=220.0
	AccelRate=2048.0
	JumpZ=322.0
	CrouchHeight=29.0
	CrouchRadius=21.0
	Bob=0.001
	MaxStepHeight=26.0
	MaxJumpHeight=49.0
	MaxFootPlacementDistSquared=56250000.0
	FallSpeedThreshold=125.0

	bUpdateEyeheight=True
	bCanCrouch=True
	bEnableFootPlacement=True
	bPhysRigidBodyOutOfWorldCheck=True
	bRunPhysicsWithNoController=True

	WeaponSocketName=WeaponPoint
	LeftFootControlName=LeftFootControl
	RightFootControlName=RightFootControl
	TorsoBoneName=b_Spine2
}