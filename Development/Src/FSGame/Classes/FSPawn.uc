/**
 * Pawn class for the player.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSPawn extends UDKPawn
	Implements(FSActorInterface)
	config(GameFS)
	notplaceable;

const MinimapCaptureFOV=90; // This must be 90 degrees otherwise the minimap overlays will be incorrect.\

var DynamicLightEnvironmentComponent LightEnvironment;

// Weapon
var repnotify class<FSWeaponAttachment> CurrentWeaponAttachmentClass;
var FSWeaponAttachment CurrentWeaponAttachment;
var name WeaponSocket;
var bool bWeaponAttachmentVisible;

// Minimap
var SceneCapture2DComponent MinimapCaptureComponent;
var Vector MinimapCapturePosition;
var Rotator MinimapCaptureRotation;

replication
{
	if (bNetDirty)
		CurrentWeaponAttachmentClass;
}

/**
 * @extends
 */
simulated function ReplicatedEvent(name VarName)
{
	if (VarName == 'CurrentWeaponAttachmentClass')
		WeaponAttachmentChanged();
	else if (VarName == 'bPuttingDownWeapon')
		SetPuttingDownWeapon(bPuttingDownWeapon);

	Super.ReplicatedEvent(VarName);
}

/**
 * @extends
 */
simulated function PostBeginPlay()
{
	local FSMapInfo MI;

	Super.PostBeginPlay();

	MI = FSMapInfo(WorldInfo.GetMapInfo());

	// Initialize the minimap capture component
	if (WorldInfo.NetMode != NM_DedicatedServer && MI != None)
	{
		//@todo Create in defaultproperties and use AlwaysLoadOnServer=false and CollideActors=False
		MinimapCaptureComponent = new(self) class'SceneCapture2DComponent';
		MinimapCaptureComponent.SetCaptureParameters(TextureRenderTarget2D'FSAssets.HUD.minimap_render_texture', MinimapCaptureFOV, , 0);
		MinimapCaptureComponent.bUpdateMatrices = false;
		AttachComponent(MinimapCaptureComponent);

		MinimapCapturePosition.X = MI.MapCenter.X;
		MinimapCapturePosition.Y = MI.MapCenter.Y;
		MinimapCapturePosition.Z = MI.MapRadius;
	}
}

/**
 * @extends
 */
simulated function PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	// These variables need to be set for animations to work properly.
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

/**
* @extends
*/
simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	// Update the capture component's position
	if (WorldInfo.NetMode != NM_DedicatedServer)
		MinimapCaptureComponent.SetView(MinimapCapturePosition, MinimapCaptureRotation);
}

/**
 * @extends
 */
simulated function Destroyed()
{
	Super.Destroyed();

	if (CurrentWeaponAttachment != None)
	{
		CurrentWeaponAttachment.DetachFrom(Mesh);
		CurrentWeaponAttachment.Destroy();
	}
}

/**
 * Override.
 * 
 * @extends
 */
simulated function Rotator GetAdjustedAimFor(Weapon W, Vector StartFireLoc)
{
	local Vector MuzVec;
	local Rotator MuzRot;
	
	// Fallback if there is no weapon.
	if (CurrentWeaponAttachment == None)
		return GetBaseAimRotation();

	// Set the aim to the weapon's rotation.
	CurrentWeaponAttachment.Mesh.GetSocketWorldLocationAndRotation(CurrentWeaponAttachment.MuzzleFlashSocket, MuzVec, MuzRot);

	return MuzRot;
}

/**
 * Override.
 * 
 * @extends
 */
simulated function bool CalcCamera(float fDeltaTime, out vector out_CamLoc, out Rotator out_CamRot, out float out_FOV)
{
	// Set the camera to the player's eyes.
	Mesh.GetSocketWorldLocationAndRotation('Eyes', out_CamLoc);
	out_CamRot = GetViewRotation();
	return true;
}

/**
 * @extends
 */
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

/**
 * @extends
 */
simulated function PlayDying(class<DamageType> DamageType, Vector HitLoc)
{
	Super.PlayDying(DamageType, HitLoc);

	CurrentWeaponAttachmentClass = None;
	WeaponAttachmentChanged();
}

/**
 * @extends
 */
simulated function FiringModeUpdated(Weapon InWeapon, byte InFiringMode, bool bViaReplication)
{
	Super.FiringModeUpdated(InWeapon, InFiringMode, bViaReplication);

	if (CurrentWeaponAttachment != None)
		CurrentWeaponAttachment.FireModeUpdated(InFiringMode, bViaReplication);
}

/**
 * @extends
 */
simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	Super.WeaponFired(InWeapon, bViaReplication, HitLocation);

	if (CurrentWeaponAttachment != None)
	{
		if (IsFirstPerson())
		{
			CurrentWeaponAttachment.FirstPersonFireEffects(Weapon, HitLocation);
		}
		else
			CurrentWeaponAttachment.ThirdPersonFireEffects(HitLocation);
	}
}

/**
 * @extends
 */
simulated function WeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
	Super.WeaponStoppedFiring(InWeapon, bViaReplication);

	if (CurrentWeaponAttachment != None)
	{
		CurrentWeaponAttachment.StopFirstPersonFireEffects(Weapon);
		CurrentWeaponAttachment.StopThirdPersonFireEffects();
	}
}

/**
 * Called when the weapon attachment needs to be changed.
 */
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

/**
 * Called when weapon is being put down.
 */
simulated function SetPuttingDownWeapon(bool bNowPuttingDownWeapon)
{
	if (bPuttingDownWeapon != bNowPuttingDownWeapon || Role < ROLE_Authority)
	{
		bPuttingDownWeapon = bNowPuttingDownWeapon;
		if (CurrentWeaponAttachment != None)
			CurrentWeaponAttachment.SetPuttingDownWeapon(bPuttingDownWeapon);
	}
}

defaultproperties
{
	Components.Remove(Sprite)

	Begin Object Class=DynamicLightEnvironmentComponent Name=LightEnvironment0
		bSynthesizeSHLight=true
		bIsCharacterLightEnvironment=true
		bUseBooleanEnvironmentShadowing=false
		InvisibleUpdateTime=1
		MinTimeBetweenFullUpdates=.2
	End Object
	Components.Add(LightEnvironment0)
	LightEnvironment=LightEnvironment0

	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'FSAssets.Mesh.IronGuard'
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
		bCacheAnimSequenceNodes=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bOwnerNoSee=false
		CastShadow=true
		BlockRigidBody=true
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		Translation=(Z=8.0)
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		LightEnvironment=LightEnvironment0
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=false
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		MinDistFactorForKinematicUpdate=0.2
		bChartDistanceFactor=true
		RBDominanceGroup=20
		Scale=1.075
		bUseOnePassLightingOnTranslucency=true
		bPerBoneMotionBlur=true
	End Object
	Mesh=SkeletalMeshComponent0
	Components.Add(SkeletalMeshComponent0)

	BaseTranslationOffset=6.0

	Begin Object Class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Class=AnimNodeSequence Name=MeshSequenceB
	End Object

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0040.000000
		CollisionHeight=+0044.000000
	End Object
	CylinderComponent=CollisionCylinder

	AlwaysRelevantDistanceSquared=+1960000.0
	bCanCrouch=true
	bWeaponAttachmentVisible=true
	WeaponSocket=WeaponPoint
	bCanPickupInventory=true
	InventoryManagerClass=class'FSGame.FSInventoryManager'

	LeftFootControlName=LeftFootControl
	RightFootControlName=RightFootControl
	bEnableFootPlacement=true
	MaxFootPlacementDistSquared=56250000.0

	MinimapCaptureRotation=(Pitch=-16384,Yaw=-16384,Roll=0) // Camera needs to be rotated to make up point north.
}