/**
 * Pawn class for the player.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSPawn extends UDKPawn
	Implements(FSActorInterface)
	config(GameFS)
	notplaceable;

const MinimapCaptureFOV=90; // This must be 90 degrees otherwise the minimap overlays will be incorrect.

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
simulated event PostBeginPlay()
{
	local FSMapInfo MI;

	super.PostBeginPlay();

	MI = FSMapInfo(WorldInfo.GetMapInfo());
	if (MI != none)
	{
		// Initialize the minimap capture component
		MinimapCaptureComponent = new class'SceneCapture2DComponent';
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
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	// Only refresh anim nodes if our main mesh was updated
	if (SkelComp == Mesh)
	{
		LeftLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(LeftFootControlName));
		RightLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(RightFootControlName));

		LeftHandIK = SkelControlLimb( mesh.FindSkelControl('LeftHandIK') );

		RightHandIK = SkelControlLimb( mesh.FindSkelControl('RightHandIK') );

		RootRotControl = SkelControlSingleBone( mesh.FindSkelControl('RootRot') );
		AimNode = AnimNodeAimOffset( mesh.FindAnimNode('AimNode') );
		GunRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('GunRecoilNode') );
		LeftRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('LeftRecoilNode') );
		RightRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('RightRecoilNode') );

		FlyingDirOffset = AnimNodeAimOffset( mesh.FindAnimNode('FlyingDirOffset') );
	}
}

/**
 * @extends
 */
simulated event Destroyed()
{
	super.Destroyed();

	if (CurrentWeaponAttachment != None)
	{
		CurrentWeaponAttachment.DetachFrom(Mesh);
		CurrentWeaponAttachment.Destroy();
	}
}


/**
 * @extends
 */
simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	// Update the capture component's position
	MinimapCaptureComponent.SetView(MinimapCapturePosition, MinimapCaptureRotation);
}

/**
 * @extends
 */
simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'Controller' && Controller != None)
	{
		if (FSWeapon(Weapon) != None)
		{
			UTWeapon(Weapon).ClientEndFire(0);
			UTWeapon(Weapon).ClientEndFire(1);
			if (!Weapon.HasAnyAmmo())
			{
				Weapon.WeaponEmpty();
			}
		}
	}
	else if (VarName == 'CurrentWeaponAttachmentClass')
	{
		WeaponAttachmentChanged();
		return;
	}
	else if (VarName == 'bPuttingDownWeapon')
	{
		SetPuttingDownWeapon(bPuttingDownWeapon);
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

/**
 * Override.
 * 
 * @extends
 */
simulated function Rotator GetAdjustedAimFor(Weapon W, vector StartFireLoc)
{
	local vector MuzVec;
	local rotator MuzRot;
	
	if (CurrentWeaponAttachment == None)
		return GetBaseAimRotation();

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
	// Set the camera to the player's eyes
	Mesh.GetSocketWorldLocationAndRotation('Eyes', out_CamLoc);
	out_CamRot = GetViewRotation();
	return true;
}

/**
 * @extends
 */
simulated function NotifyTeamChanged()
{
	super.NotifyTeamChanged();
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
	super.PlayDying(DamageType, HitLoc);

	CurrentWeaponAttachmentClass = None;
	WeaponAttachmentChanged();
}

/**
 * @extends
 */
simulated function FiringModeUpdated(Weapon InWeapon, byte InFiringMode, bool bViaReplication)
{
	super.FiringModeUpdated(InWeapon, InFiringMode, bViaReplication);
	if (CurrentWeaponAttachment != None)
	{
		CurrentWeaponAttachment.FireModeUpdated(InFiringMode, bViaReplication);
	}
}

/**
 * @extends
 */
simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	super.WeaponFired(InWeapon, bViaReplication, HitLocation);

	if (CurrentWeaponAttachment != None)
	{
		if (!IsFirstPerson())
			CurrentWeaponAttachment.ThirdPersonFireEffects(HitLocation);
		else
		{
			CurrentWeaponAttachment.FirstPersonFireEffects(Weapon, HitLocation);
	        if (class'Engine'.static.IsSplitScreen() && CurrentWeaponAttachment.EffectIsRelevant(CurrentWeaponAttachment.Location, false, CurrentWeaponAttachment.MaxFireEffectDistance))
		        CurrentWeaponAttachment.CauseMuzzleFlash();
		}
	}
}

/**
 * @extends
 */
simulated function WeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
	super.WeaponFired(InWeapon, bViaReplication);

	if (CurrentWeaponAttachment != None)
	{
		CurrentWeaponAttachment.StopThirdPersonFireEffects();
		CurrentWeaponAttachment.StopFirstPersonFireEffects(Weapon);
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
		{
			CurrentWeaponAttachment.SetPuttingDownWeapon(bPuttingDownWeapon);
		}
	}
}

simulated function ChangeClass()
{
}

defaultproperties
{
	Components.Remove(Sprite)

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=TRUE
		bIsCharacterLightEnvironment=TRUE
		bUseBooleanEnvironmentShadowing=FALSE
		InvisibleUpdateTime=1
		MinTimeBetweenFullUpdates=.2
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment

	Begin Object Class=SkeletalMeshComponent Name=WSkeletalMeshComponent
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
		LightEnvironment=MyLightEnvironment
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
	Mesh=WSkeletalMeshComponent
	Components.Add(WSkeletalMeshComponent)

	BaseTranslationOffset=6.0

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object class=AnimNodeSequence Name=MeshSequenceB
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