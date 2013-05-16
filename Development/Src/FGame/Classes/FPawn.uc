class FPawn extends UDKPawn;

var DynamicLightEnvironmentComponent LightEnvironment;
var TeamInfo LastTeam;

var() float Stamina;
var() float StaminaMax;
var() float StaminaJumpCost;
var() float StaminaIncreaseRate;
var() float StaminaDecreaseRate;

// Weapon attachment
var repnotify FWeaponAttachment WeaponAttachmentArchetype;
var FWeaponAttachment WeaponAttachment;
var name WeaponSocketName;

// Movement bob
var float Bob;
var	float AppliedBob;
var float BobTime;
var	Vector WalkBob;

replication
{
	if (bNetDirty)
		Stamina, StaminaMax, WeaponAttachmentArchetype;
}

/**
 * @extends
 */
simulated event ReplicatedEvent(name VarName)
{
	Super.ReplicatedEvent(VarName);

	// Update the pawn's weapon attachment when their equipped weapon has changed
	if (VarName == 'WeaponAttachmentArchetype')
		UpdateWeaponAttachment();
}

/**
 * @extends
 */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	// Sets the skeletal controls for animations to play correctly
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
function AddDefaultInventory()
{
	local FPlayerController PC;

	Super.AddDefaultInventory();

	PC = FPlayerController(Controller);

	if (PC != None && PC.CurrentInfantryClassArchetype == None)
	{
		ClientSelectDefaultInfantryPreset();
	}
	else
	{
		FInventoryManager(InvManager).EquipLoadout();
	}
}

/**
 * Selects an infantry preset.
 */
reliable client function ClientSelectDefaultInfantryPreset()
{
	FHUD(PlayerController(Controller).myHUD).GFxOmniMenu.SelectInfantryPreset("");
}

/**
 * @extends
 */
simulated event Destroyed()
{
	// Remove the pawn's weapon attachment
	if (WeaponAttachment != None)
	{
		WeaponAttachment.DetachFrom(Mesh);
		WeaponAttachment.Destroy();
		WeaponAttachment = None;
	}

	Super.Destroyed();
}

/**
 * @extends
 */
event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (Role == ROLE_Authority)
	{
		if (bIsWalking || VSize2D(Acceleration) == 0)
		{
			if (Stamina < StaminaMax)
			{
				Stamina += StaminaIncreaseRate;
				
			}
		}
		else // Player is sprinting
		{
			if (Stamina > 0)
			{
				Stamina -= StaminaDecreaseRate;
			}
		}

		if (Stamina <= 0)
		{
			SetWalking(True);
		}
	}
}

/**
 * @extends
 */
simulated event StartDriving(Vehicle PlayerVehicle)
{
	Super.StartDriving(PlayerVehicle);

	// Hide the pawn's first-person weapon model while in a vehicle
	SetWeaponVisibility(False);
}

/**
 * @extends
 */
simulated event StopDriving(Vehicle PlayerVehicle)
{
	Super.StopDriving(PlayerVehicle);

	// Unhide the first-person weapon model when exiting a vehicle
	SetWeaponVisibility(IsFirstPerson());
}

/**
 * @extends
 */
event UpdateEyeHeight(float DeltaTime)
{
	local Vector X, Y, Z;
	local float Speed2D;

	// This block is taken from UTPawn
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

/**
 * @extends
 */
function bool DoJump(bool bUpdating)
{
	local bool bJumped;

	if (Stamina >= StaminaJumpCost)
	{
		bJumped = Super.DoJump(bUpdating);
		if (bJumped)
		{
			Stamina -= StaminaJumpCost;
		}
	}

	return bJumped;
}

/**
 * Returns the current amount of bob to apply to the weapon.
 */
simulated function Vector WeaponBob(float BobDamping)
{
	local Vector BobAmount;

	BobAmount = BobDamping * WalkBob;
	BobAmount.Z = (0.45 + 0.55 * BobDamping) * WalkBob.Z;
	return BobAmount;
}

/**
 * @extends
 */
function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	FTeamGame(WorldInfo.Game).PlayerStatusChanged();

	return Super.Died(Killer, DamageType, HitLocation);
}

/**
 * @extends
 */
simulated function PlayDying(class<DamageType> DamageType, Vector HitLoc)
{
	Super.PlayDying(DamageType, HitLoc);
	
	// Ragdoll the pawn
	// This is taken from the UDN
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

/**
 * @extends
 */
simulated function bool CalcCamera(float fDeltaTime, out Vector out_CamLoc, out Rotator out_CamRot, out float out_FOV)
{
	local Vector Pos, HitLocation, HitNormal;

	GetActorEyesViewPoint(out_CamLoc, out_CamRot);

	if (!IsFirstPerson())
	{
		Pos = out_CamLoc - Vector(out_CamRot) * 512.0;
		if (Trace(HitLocation, HitNormal, Pos, out_CamLoc, False, Vect(0,0,0)) != None)
		{
			out_CamLoc = HitLocation + HitNormal * 2;
		}
		else
		{
			out_CamLoc = Pos;
		}
	}

	return True;
}

/**
 * Sets the visibility of the pawn's weapon.
 */
simulated function SetWeaponVisibility(bool bWeaponVisible)
{
	local FWeapon PlayerWeapon;

	PlayerWeapon = FWeapon(Weapon);
	if (PlayerWeapon != None)
		PlayerWeapon.ChangeVisibility(bWeaponVisible);
}

/**
 * @extends
 */
simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	// Fire effects on the pawn's weapon attachment
	if (WeaponAttachment != None)
	{
		if (IsFirstPerson())
			WeaponAttachment.FirstPersonFireEffects(Weapon, HitLocation);
		else
			WeaponAttachment.ThirdPersonFireEffects(HitLocation);
	}

	Super.WeaponFired(InWeapon, bViaReplication, HitLocation);
}

/**
 * @extends
 */
simulated function WeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
	// Stop firing effects on the pawn's weapon attachment
	if (WeaponAttachment != None)
	{
		WeaponAttachment.StopFirstPersonFireEffects(Weapon);
		WeaponAttachment.StopThirdPersonFireEffects();
	}

	Super.WeaponStoppedFiring(InWeapon, bViaReplication);
}

/**
 * Updates the pawn's current weapon attachment.
 */
simulated function UpdateWeaponAttachment()
{
	if (Mesh.SkeletalMesh != None)
	{
		if (WeaponAttachment != None)
		{
			// Delete current weapon attachment
			WeaponAttachment.DetachFrom(Mesh);
			WeaponAttachment.Destroy();
		}

		if (WeaponAttachmentArchetype != None)
		{
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
				`log("Failed to spawn weapon attachment for archetype" @ WeaponAttachmentArchetype);
			}			
		}
	}
}

defaultproperties
{
	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionRadius=21.0
		CollisionHeight=40.0
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
		SkeletalMesh=SkeletalMesh'r_character.SK_CH_Character'
		AnimTreeTemplate=AnimTree'r_character.AT_CH_Character'		
		//PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimSets(0)=AnimSet'r_character.AS_CH_Character_1'
		Translation=(Z=0.0)
		Scale=0.700		
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

	Stamina=100.0
	StaminaMax=100.0
	StaminaJumpCost=25.0
	StaminaIncreaseRate=0.25
	StaminaDecreaseRate=0.2

	BaseTranslationOffset=6.0
	WalkingPct=0.7
	CrouchedPct=0.4
	BaseEyeHeight=50.0
	EyeHeight=50.0
	GroundSpeed=290.0
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