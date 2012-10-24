class FVehicle extends UDKVehicle
	dependson(FVehicleWeapon)
	perobjectlocalized
	notplaceable;

const MAX_VEHICLE_ROTATE_CONTROLS = 2;

const MAX_VEHICLE_WEAPONS = 2;

const MAX_VEHICLE_SEATS = 8;

enum ESeatCamera
{
	SC_Fixed,
	SC_Free,
	SC_Follow_Mesh_Free
};

enum ERotationConstraint
{
	RC_Pitch,
	RC_Yaw,
	RC_Roll
};

struct TurretConstraint
{
	var() ERotationConstraint RotationConstraint;
	var() int MinAngle;
	var() int MaxAngle;
};

struct TurretControl
{
	var() int SeatIndex;
	var() name RotateControl;
	var() array<TurretConstraint> TurretConstraints;
	var UDKSkelControl_Rotate RotateController;
};

struct VehicleHardpoint
{
	var() int SeatIndex;
	var() name SocketName;
	var() EHardpointTypes HardpointType;
};

struct WeaponFireEffect
{
	var int WeaponIndex;
	var Vector EndLocation;
};

struct VehicleWeaponAttachment
{
	var name SocketName;
	var ParticleSystem EffectParticleSystem;

	structdefaultproperties
	{
		EffectParticleSystem=ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_2ndPrim_Beam'
	}
};

var(Factions) byte InitialTeam;
var(Factions) int ResourceCost;
var(Factions) bool bIsCommandVehicle;
var(Weapons) array<TurretControl> TurretControls;
var(Weapons) array<VehicleHardpoint> VehicleHardpoints;
var(Seats) array<ESeatCamera> SeatCameras;

var repnotify Rotator TurretRotations[MAX_VEHICLE_ROTATE_CONTROLS];
var repnotify WeaponFireEffect WeaponEffect;

// Active vehicle weapons
var FVehicleWeapon VehicleWeapons[MAX_VEHICLE_WEAPONS];
var VehicleWeaponAttachment VehicleWeaponAttachments[MAX_VEHICLE_WEAPONS];

// Explosion effects
var ParticleSystem ExplosionTemplate;
var array<DistanceBasedParticleTemplate> BigExplosionTemplates;

var Emitter DeathExplosion;
var ParticleSystem SecondaryExplosion;
var name BigExplosionSocket;
var class<UDKExplosionLight> ExplosionLightClass;
var SoundCue ExplosionSound;

var float ExplosionDamage, ExplosionRadius, ExplosionMomentum;
var float ExplosionInAirAngVel;

// Seats
var PlayerReplicationInfo PassengerPRIs[MAX_VEHICLE_SEATS];

replication
{
	if (bNetDirty)
		WeaponEffect, VehicleWeaponAttachments, PassengerPRIs, TurretRotations;

	if (bNetDirty && bNetOwner)
		VehicleWeapons;
}

/**
 * @extends
 */
simulated event ReplicatedEvent(name VarName)
{
	Super.ReplicatedEvent(VarName);

	if (VarName == 'Team')
	{
		NotifyTeamChanged();
	}
	else if (VarName == 'TurretRotations')
	{
		TurretRotationChanged();
	}
	else if (Varname == 'WeaponEffect')
	{
		WeaponEffectLocationUpdated(True);
	}
	else if (Varname == 'bDeadVehicle')
	{
		BlowUpVehicle();
	}
}

/**
 * @extends
 */
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Role == ROLE_Authority)
	{
		InitializeSeats();

		if (InitialTeam != class'FTeamGame'.const.TEAM_NONE)
		{
			Team = InitialTeam;
			NotifyTeamChanged();
		}
	}
	else if (Seats.Length > 0)
	{
		Seats[0].SeatPawn = Self;
	}

	InitializeTurrets();
}

/**
 * @extends
 */
function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	local int i;

	if (Super.Died(Killer, DamageType, HitLocation))
	{
		KillerController = Killer;
		HitDamageType = DamageType;
		TakeHitLocation = HitLocation;

		BlowupVehicle();

		HandleDeadVehicleDriver();

		for (i = 1; i < Seats.Length; i++)
		{
			if (Seats[i].SeatPawn != None)
			{
				Seats[i].SeatPawn.Died(Killer, DamageType, HitLocation);
			}
		}

		if (Role == ROLE_Authority && bIsCommandVehicle && FCommanderGame(WorldInfo.Game) != None)
		{
			FCommanderGame(WorldInfo.Game).CommandVehicleDestroyed(Self, Killer);
		}

		return True;
	}

	return False;
}

/**
 * @extends
 */
function DriverDied(class<DamageType> DamageType)
{
	Super.DriverDied(DamageType);

	// Handle switching to spectator
	if (Controller == None)
	{
		WorldInfo.Game.DriverLeftVehicle(Self, Driver);
		DriverLeft();
	}
}

/**
 * Explodes the vehicle.
 */
simulated function BlowupVehicle()
{
	local int i;

	bCanBeBaseForPawns = False;
	GotoState('DyingVehicle');
	AddVelocity(TearOffMomentum, TakeHitLocation, HitDamageType);
	bDeadVehicle = True;
	bStayUpright = False;

	if (StayUprightConstraintInstance != None)
		StayUprightConstraintInstance.TermConstraint();

	// Iterate over wheels, turning off those we want
	for (i = 0; i < Wheels.length; i++)
	{
		if (UDKVehicleWheel(Wheels[i]) != None && UDKVehicleWheel(Wheels[i]).bDisableWheelOnDeath)
		{
			SetWheelCollision(i, False);
		}
	}

	CustomGravityScaling = 1.0;
	if (UDKVehicleSimHover(SimObj) != None)
		UDKVehicleSimHover(SimObj).bDisableWheelsWhenOff = True;
}

/**
 * @extends
 */
simulated event NotifyTeamChanged()
{
	Super.NotifyTeamChanged();

	if (Role == ROLE_Authority && bIsCommandVehicle)
	{
		FTeamInfo(WorldInfo.Game.GameReplicationInfo.Teams[GetTeamNum()]).Commander = Self;
	}
}

/**
 * @extends
 */
event OnPropertyChange(name PropName)
{
	local int i;

	Super.OnPropertyChange(PropName);

	for (i = 0; i < Seats.Length; i++)
	{
		if (Seats[i].bSeatVisible)
		{
			Seats[i].StoragePawn.SetRelativeLocation(Seats[i].SeatOffset);
			Seats[i].StoragePawn.SetRelativeRotation(Seats[i].SeatRotation);
		}
	}
}

/**
 * @extends
 */
function bool TryToDrive(Pawn P)
{
	if (!bIsDisabled && (Team == class'FTeamGame'.const.TEAM_NONE || !bTeamLocked || !WorldInfo.Game.bTeamGame || WorldInfo.GRI.OnSameTeam(Self, P)))
	{
		return Super.TryToDrive(P);
	}

	return False;
}

/**
 * Updates the SeatMask.
 */
function SetSeatStoragePawn(int SeatIndex, Pawn PawnToSit)
{
	local int Mask;

	Seats[SeatIndex].StoragePawn = PawnToSit;

	if (Role == ROLE_Authority)
	{
		PassengerPRIs[SeatIndex] = PawnToSit == None ? None : Seats[SeatIndex].SeatPawn.PlayerReplicationInfo;
	}

	Mask = 1 << SeatIndex;

	if (PawnToSit != none)
	{
		SeatMask = SeatMask | Mask;
	}
	else
	{
		if ((SeatMask & Mask) > 0)
		{
			SeatMask = SeatMask ^ Mask;
		}
	}

}

/**
 * Caches the turret controllers.
 */
simulated function InitializeTurrets()
{
	local UDKSkelControl_Rotate RotateController;
	local int i;

	for (i = 0; i < TurretControls.Length; i++)
	{
		RotateController = UDKSkelControl_Rotate(Mesh.FindSkelControl(TurretControls[i].RotateControl));

		if (RotateController != None)
			TurretControls[i].RotateController = RotateController;
		else
			`Warn(Self @ "failed to setup turret controller" @ i);
	}
}

/**
 * Constrains the rotation of the given turret controller.
 */
simulated function ApplyTurretConstraints(TurretControl TC)
{
	local TurretConstraint C;

	foreach TC.TurretConstraints(C)
	{
		if (C.RotationConstraint == RC_Pitch)
			TC.RotateController.DesiredBoneRotation.Pitch = Clamp(TC.RotateController.DesiredBoneRotation.Pitch, C.MinAngle * DegToUnrRot, C.MaxAngle * DegToUnrRot);
		else if (C.RotationConstraint == RC_Yaw)
			TC.RotateController.DesiredBoneRotation.Yaw = Clamp(TC.RotateController.DesiredBoneRotation.Yaw, C.MinAngle * DegToUnrRot, C.MaxAngle * DegToUnrRot);
		else if (C.RotationConstraint == RC_Roll)
			TC.RotateController.DesiredBoneRotation.Roll = Clamp(TC.RotateController.DesiredBoneRotation.Roll, C.MinAngle * DegToUnrRot, C.MaxAngle * DegToUnrRot);
	}
}

/**
 * Rotates the turret by the given amount.
 */
simulated function RotateTurret(int SeatIndex, Rotator RotationAmount)
{
	local int i;
	local TurretControl TC;
	
	foreach TurretControls(TC, i)
	{
		if (TC.SeatIndex == SeatIndex)
		{
			// Only update rotation if there is any rotation amount
			if (RotationAmount.Pitch != 0 || RotationAmount.Roll != 0 || RotationAmount.Yaw != 0)
			{
				TC.RotateController.DesiredBoneRotation += RotationAmount;
				ApplyTurretConstraints(TC);
				TurretRotations[i] = TC.RotateController.DesiredBoneRotation;

				if (Role < ROLE_Authority)
					ServerSetTurretRotation(i, TC.RotateController.DesiredBoneRotation);
			}
		}
	}
}

/**
 * Sets the weapon rotation on the server.
 */
unreliable server function ServerSetTurretRotation(int ControlIndex, Rotator NewTurretRotation)
{
	TurretControls[ControlIndex].RotateController.DesiredBoneRotation = NewTurretRotation;
	TurretRotations[ControlIndex] = TurretControls[ControlIndex].RotateController.DesiredBoneRotation;
}

/**
 * Updates all the turret bone rotations to the turret rotations array.
 * 
 * Used in multiplayer to update turret rotation on remote clients.
 */
simulated function TurretRotationChanged()
{
	local int i;
	local TurretControl TC;
	
	foreach TurretControls(TC, i)
		TC.RotateController.DesiredBoneRotation = TurretRotations[i];
}

/**
 * Returns the world position of the gun barrel for the given seat.
 */
simulated function GetBarrelLocationAndRotation(int WeaponIndex, out Vector SocketLocation, optional out Rotator SocketRotation)
{
	if (VehicleWeaponAttachments[WeaponIndex].SocketName != '')
	{
		Mesh.GetSocketWorldLocationAndRotation(VehicleWeaponAttachments[WeaponIndex].SocketName, SocketLocation, SocketRotation);
	}
	else
	{
		SocketLocation = Location;
		SocketRotation = Rotation;
	}
}

/**
 * Create the vehicle weapons.
 */
function InitializeSeats()
{
	local int i;

	if (Seats.Length == 0)
	{
		`warn("Vehicle (" $ Self $ ") has no seats! Deleting!");
		Destroy();
		return;
	}

	for (i = 0; i < Seats.Length; i++)
	{
		if (i > 0)
		{
			Seats[i].SeatPawn = Spawn(class'FWeaponPawn');
			Seats[i].SeatPawn.SetBase(Self);
			Seats[i].SeatPawn.EyeHeight = Seats[i].SeatPawn.BaseEyeheight;
			UDKWeaponPawn(Seats[i].SeatPawn).MyVehicle = Self;
			UDKWeaponPawn(Seats[i].SeatPawn).MySeatIndex = i;

			if (Seats[i].ViewPitchMin != 0.0)
				UDKWeaponPawn(Seats[i].SeatPawn).ViewPitchMin = Seats[i].ViewPitchMin;
			else
				UDKWeaponPawn(Seats[i].SeatPawn).ViewPitchMin = ViewPitchMin;


			if (Seats[i].ViewPitchMax != 0.0)
				UDKWeaponPawn(Seats[i].SeatPawn).ViewPitchMax = Seats[i].ViewPitchMax;
			else
				UDKWeaponPawn(Seats[i].SeatPawn).ViewPitchMax = ViewPitchMax;
		}
		// Driver's seat doesn't get a weapon pawn
		else
		{
			Seats[i].SeatPawn = Self;
		}

		Seats[i].SeatPawn.DriverDamageMult = Seats[i].DriverDamageMult;
		Seats[i].SeatPawn.bDriverIsVisible = Seats[i].bSeatVisible;
	}
}

/**
 * Returns the vehicle seat index of the specified controller.
 */
simulated function int GetSeatIndexForController(Controller ControllerToMove)
{
	local int i;

	for (i = 0; i < Seats.Length; i++)
	{
		if (Seats[i].SeatPawn.Controller != None && Seats[i].SeatPawn.Controller == ControllerToMove)
		{
			return i;
		}
	}

	return INDEX_NONE;
}

/**
 * Returns the controller for the given vehicle seat index.
 */
function Controller GetControllerForSeatIndex(int SeatIndex)
{
	return Seats[SeatIndex].SeatPawn.Controller;
}

/**
 * Returns true if the seat of the specified seat index is empty.
 */
function bool SeatAvailable(int SeatIndex)
{
	return Seats[SeatIndex].SeatPawn == None || Seats[SeatIndex].SeatPawn.Controller == None;
}

/**
 * @extends
 */
simulated function bool CalcCamera(float DeltaTime, out Vector out_CamLoc, out Rotator out_CamRot, out float out_FOV)
{
	VehicleCalcCamera(DeltaTime, 0, out_CamLoc, out_CamRot, out_FOV);
	return True;
}

/**
 * Calculates the camera for the specified seat.
 */
simulated function VehicleCalcCamera(float fDeltaTime, int SeatIndex, out Vector out_CamLoc, out Rotator out_CamRot, out float out_FOV)
{
	if (Seats[SeatIndex].CameraTag != '')
	{
		Mesh.GetSocketWorldLocationAndRotation(Seats[SeatIndex].CameraTag, out_CamLoc, out_CamRot);
		if (SeatIndex < SeatCameras.Length)
		{
			if (SeatCameras[SeatIndex] == SC_Free)
			{
				out_CamRot.Pitch = GetViewRotation().Pitch;
				out_CamRot.Yaw = GetViewRotation().Yaw;
			}
			else if (SeatCameras[SeatIndex] == SC_Follow_Mesh_Free)
			{
				out_CamRot.Pitch = Mesh.GetRotation().Pitch + GetViewRotation().Pitch;
				out_CamRot.Yaw = Mesh.GetRotation().Yaw + GetViewRotation().Yaw;
			}
		}
	}
	else
	{
		Super.CalcCamera(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
	}
}

/**
 * Sets the team of the vehicle.
 */
function SetTeamNum(byte T)
{
	if (T != Team)
	{
		Team = T;
	}
}

/**
 * @extends
 */
simulated function GetSVehicleDebug(out Array<String> DebugInfo)
{
	local int i;

	Super.GetSVehicleDebug(DebugInfo);

	DebugInfo[DebugInfo.Length] = "";
	DebugInfo[DebugInfo.Length] = "----Seats----: ";
	for (i = 0; i < Seats.Length; i++)
	{
		DebugInfo[DebugInfo.Length] = "Seat" @ i @ "Rotation" @ SeatWeaponRotation(i,, true) @ "FiringMode" @ SeatFiringMode(i,, true) @ "Barrel" @ Seats[i].BarrelIndex;
	}
}

/**
 * @extends
 */
function bool DriverEnter(Pawn P)
{
	P.StopFiring();

	Instigator = Self;

	if (!Super.DriverEnter(P))
		return False;

	SetSeatStoragePawn(0, P);

	StuckCount = 0;
	ResetTime = WorldInfo.TimeSeconds - 1;

	return True;
}

/**
 * @extends
 */
event bool DriverLeave(bool bForceLeave)
{
	local bool bResult;
	local Pawn OldDriver;

	if (!bForceLeave && !bAllowedExit)
	{
		return False;
	}

	OldDriver = Driver;
	bResult = Super.DriverLeave(bForceLeave);
	if (bResult)
	{
		SetSeatStoragePawn(0, None);
		Instigator = OldDriver;
	}

	return bResult;
}

/**
 * @extends
 */
function DriverLeft()
{
	local FVehicleWeapon VehicleWeapon;
	local int i;

	Super.DriverLeft();

	for (i = 0; i < MAX_VEHICLE_WEAPONS; i++)
	{
		VehicleWeapon = VehicleWeapons[i];
		if (VehicleWeapon != None)
			VehicleWeapon.StopFire(VehicleWeapon.CurrentFireMode);
	}
}

/**
 * Adds a passenger to the vehicle.
 */
function bool PassengerEnter(Pawn P, int SeatIndex)
{
	// Passenger must be on the same team in team games
	if (WorldInfo.Game.bTeamGame && !WorldInfo.GRI.OnSameTeam(P, Self))
	{
		return False;
	}

	// Seat index must be valid
	if (SeatIndex <= 0 || SeatIndex >= Seats.Length)
	{
		`warn("Attempted to add a passenger to unavailable passenger seat" @ SeatIndex);
		return False;
	}

	// Place the passenger in the seat
	if (!Seats[SeatIndex].SeatPawn.DriverEnter(P))
	{
		return False;
	}

	SetSeatStoragePawn(SeatIndex, P);

	return True;
}

/**
 * Updates the storage pawn after a passenger leaves.
 */
function PassengerLeave(int SeatIndex)
{
	SetSeatStoragePawn(SeatIndex, None);
}

/**
 * @extends
 */
reliable server function ServerChangeSeat(int RequestedSeat)
{
	if (RequestedSeat == INDEX_NONE)
	{
		DriverLeave(False);
	}
	else
	{
		ChangeSeat(Controller, RequestedSeat);
	}
}

/**
 * Changes seat to the given seat index.
 */
function bool ChangeSeat(Controller ControllerToMove, int RequestedSeat)
{
	local int OldSeatIndex;
	local Pawn OldPawn;

	if ((RequestedSeat >= Seats.Length) || (RequestedSeat < 0))
	{
		return False;
	}

	OldSeatIndex = GetSeatIndexForController(ControllerToMove);

	if (OldSeatIndex == INDEX_NONE)
	{
		`Warn("[Vehicles] Attempted to switch" @ ControllerToMove @ "to a seat in" @ Self @ " when they are not already in the vehicle!");
		return False;
	}

	if (!SeatAvailable(RequestedSeat))
	{
		return False;
	}

	OldPawn = Seats[OldSeatIndex].StoragePawn;

	Seats[OldSeatIndex].SeatPawn.DriverLeave(True);

	if (RequestedSeat == 0)
	{
		DriverEnter(OldPawn);
	}
	else
	{
		PassengerEnter(OldPawn, RequestedSeat);
	}

	return True;
}

/**
 * Spawns a vehicle weapon for the given seat.
 */
function SetWeapon(int WeaponSlot, FVehicleWeapon WeaponArchetype)
{
	local FVehicleWeapon VehicleWeapon;
	local VehicleHardpoint Hardpoint;
	local int Index;

	VehicleWeapon = Spawn(WeaponArchetype.Class, InvManager.Owner,,,, WeaponArchetype);

	if (InvManager.AddInventory(VehicleWeapon))
	{
		// Remove old weapon
		InvManager.RemoveFromInventory(VehicleWeapons[WeaponSlot]);

		VehicleWeapon.WeaponIndex = WeaponSlot;
		VehicleWeapon.MyVehicle = Self;
		VehicleWeapon.SetBase(Self);
		VehicleWeapon.ClientWeaponSet(False);

		VehicleWeapons[WeaponSlot] = VehicleWeapon;

		foreach VehicleHardpoints(Hardpoint, Index)
			VehicleWeaponAttachments[Index].SocketName = Hardpoint.SocketName;
	}
}

/**
 * @extends
 */
simulated function StartFire(byte FireModeNum)
{
	if (bNoWeaponFiring)
		return;

	if (VehicleWeapons[FireModeNum] != None)
	{
		VehicleWeapons[FireModeNum].StartFire(FireModeNum);
	}
}

/**
 * @extends
 */
simulated function StopFire(byte FireModeNum)
{
	if (VehicleWeapons[FireModeNum] != None)
	{
		VehicleWeapons[FireModeNum].StopFire(FireModeNum);
	}
}

/**
 * @extends
 */
simulated function SetFlashLocation(Weapon InWeapon, byte InFiringMode, Vector NewLoc)
{
	// Ensure effect is replicated
	if (NewLoc == WeaponEffect.EndLocation || NewLoc == vect(0,0,0))
	{
		NewLoc += vect(0,0,1);
	}

	WeaponEffect.WeaponIndex = FVehicleWeapon(InWeapon).WeaponIndex;
	WeaponEffect.EndLocation = NewLoc;

	bForceNetUpdate = True;
	WeaponEffectLocationUpdated(False);
}

/**
 * Called when the weapon effect location has been updated.
 */
simulated function WeaponEffectLocationUpdated(bool bViaReplication)
{
	if (!IsZero(WeaponEffect.EndLocation))
	{
		VehicleWeaponFired(bViaReplication);
	}
	else
	{
		VehicleWeaponStoppedFiring(bViaReplication);
	}
}

/**
 * Plays weapon firing effects.
 */
simulated function VehicleWeaponFired(bool bViaReplication)
{
	local Vector StartLocation;
	local ParticleSystemComponent E;

	if (WorldInfo.NetMode != NM_DedicatedServer && (Role == ROLE_Authority || bViaReplication))
	{
		GetBarrelLocationAndRotation(WeaponEffect.WeaponIndex, StartLocation);
		E = WorldInfo.MyEmitterPool.SpawnEmitter(VehicleWeaponAttachments[WeaponEffect.WeaponIndex].EffectParticleSystem, StartLocation);
		E.SetVectorParameter('ShockBeamEnd', WeaponEffect.EndLocation);
	}
}

/**
 * Plays effects when the weapon stops firing.
 */
simulated function VehicleWeaponStoppedFiring(bool bViaReplication);

/**
 * @extends
 */
simulated event Vector GetWeaponStartTraceLocation(optional Weapon CurrentWeapon)
{
	local Vector SocketLocation;

	if (CurrentWeapon != None && FVehicleWeapon(CurrentWeapon) != None)
		GetBarrelLocationAndRotation(FVehicleWeapon(CurrentWeapon).WeaponIndex, SocketLocation);
	else
		return Super.GetWeaponStartTraceLocation(CurrentWeapon);

	return SocketLocation;
}

/**
 * @extends
 */
simulated function Rotator GetAdjustedAimFor(Weapon W, Vector StartFireLoc)
{
	local Vector SocketLocation;
	local Rotator SocketRotation;

	if (FVehicleWeapon(W) != None)
		GetBarrelLocationAndRotation(FVehicleWeapon(W).WeaponIndex, SocketLocation, SocketRotation);
	else
		return Super.GetAdjustedAimFor(W, StartFireLoc);

	return SocketRotation;
}

simulated state DyingVehicle
{
	ignores Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, FellOutOfWorld;

	simulated function PlayWeaponSwitch(Weapon OldWeapon, Weapon NewWeapon);
	simulated function PlayNextAnimation();
	singular event BaseChange();
	event Landed(vector HitNormal, Actor FloorActor);
	function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation);
	simulated event PostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir);
	simulated function BlowupVehicle();

	/**
	 * @extends
	 */
	simulated function BeginState(name PreviousStateName)
	{
		local int i;

		// Fully destroy all morph targets
		for (i = 0; i < DamageMorphTargets.length; i++)
		{
			DamageMorphTargets[i].Health = 0;
			if (DamageMorphTargets[i].MorphNode != None)
			{
				DamageMorphTargets[i].MorphNode.SetNodeWeight(1.0);
			}
		}

		UpdateDamageMaterial();

		DoVehicleExplosion();

		for (i = 0; i < DamageSkelControls.length; i++)
		{
			DamageSkelControls[i].HealthPerc = 0.0;
		}

		SetDestroyedMaterial();

		if (Controller != None)
		{
			if (Controller.bIsPlayer)
			{
				DetachFromController();
			}
			else
			{
				Controller.Destroy();
			}
		}

		for (i = 0; i < Attached.length; i++)
		{
			if (Attached[i] != None)
			{
				Attached[i].PawnBaseDied();
			}
		}
	}

	/**
	 * Applies the destroyed material to the vehicle.
	 */
	simulated function SetDestroyedMaterial()
	{
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			Mesh.SetMaterial(0, Material'Factions_Assets.Materials.UnitDestroyedMaterial');
		}
	}

	/**
	 * Plays vehicle destruction effects.
	 */
	simulated function DoVehicleExplosion(optional bool bDoingSecondaryExplosion = False)
	{
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			if (!bDoingSecondaryExplosion)
			{
				PlayVehicleExplosionEffect(BigExplosionTemplates[0].Template);
			}
			else
			{
				PlayVehicleExplosionEffect(SecondaryExplosion, !bDoingSecondaryExplosion);
			}
		}

		if (ExplosionSound != None)
		{
			PlaySound(ExplosionSound, true);
		}
		
		HurtRadius(ExplosionDamage, ExplosionRadius, class'UTDmgType_VehicleExplosion', ExplosionMomentum, Location,, GetCollisionDamageInstigator());
		AddVelocity((ExplosionMomentum / Mass) * Vect(0,0,1), Location, class'UTDmgType_VehicleExplosion');


		// If in air, add some anglar spin.
		if (Role == ROLE_Authority && !bVehicleOnGround)
		{
			Mesh.SetRBAngularVelocity(VRand() * ExplosionInAirAngVel, True);
		}
	}

	/**
	 * Spawns the explosion particle system.
	 */
	simulated function PlayVehicleExplosionEffect(ParticleSystem TheExplosionTemplate, optional bool bSpawnLight = True)
	{
		local UDKExplosionLight L;
		
		if (TheExplosionTemplate != None)
		{
			DeathExplosion = Spawn(class'UTEmitter', Self);
			DeathExplosion.LifeSpan = 3.0;
			DeathExplosion.SetDrawScale(3.0);
			DeathExplosion.ParticleSystemComponent.bAutoActivate = false;
			if (BigExplosionSocket != 'None')
			{
				DeathExplosion.SetBase(Self,, Mesh, BigExplosionSocket);
			}
			
			DeathExplosion.SetTemplate(TheExplosionTemplate, True);
			DeathExplosion.ParticleSystemComponent.SetFloatParameter('Velocity', VSize(Velocity) / GroundSpeed);

			if (bSpawnLight && ExplosionLightClass != None && !WorldInfo.bDropDetail)
			{
				L = new(DeathExplosion) ExplosionLightClass;
				DeathExplosion.AttachComponent(L);
			}
			DeathExplosion.ParticleSystemComponent.ActivateSystem();
		}
	}
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=LightEnvironment0
	End Object
	Components.Add(LightEnvironment0)

	Begin Object Class=AudioComponent Name=EngineSound0
	End Object
	EngineSound=EngineSound0
	Components.Add(EngineSound0)

	Begin Object Class=AudioComponent Name=TireSound0
		SoundCue=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue'
	End Object
	TireAudioComp=TireSound0
	Components.Add(TireSound0);

	Begin Object Name=CollisionCylinder
		BlockNonZeroExtent=False
		BlockZeroExtent=False
		BlockActors=False
		BlockRigidBody=False
		CollideActors=False
	End Object

	Begin Object Name=SVehicleMesh
		LightEnvironment=LightEnvironment0
		CastShadow=True
		bCastDynamicShadow=True
		bOverrideAttachmentOwnerVisibility=True
		bAcceptsDynamicDecals=False
		bPerBoneMotionBlur=True
	End Object

	InventoryManagerClass=class'FVehicleInventoryManager'

	// Explosions
	ExplosionDamage=100.0
	ExplosionRadius=600.0
	ExplosionMomentum=60000.0
	ExplosionInAirAngVel=1.5
	ExplosionLightClass=class'UTGame.UTRocketExplosionLight'
	ExplosionTemplate=ParticleSystem'FX_VehicleExplosions.Effects.P_FX_GeneralExplosion'
	BigExplosionTemplates[0]=(Template=ParticleSystem'Factions_Assets.FStandardExp')
	SecondaryExplosion=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_Dust_Secondary'
	
	// Default vehicle sounds
	Begin Object Class=AudioComponent Name=SquealSound0
		SoundCue=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_Slide'
	End Object
	SquealSound=SquealSound0
	Components.Add(SquealSound0);

	CollisionSound=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_Collide'
	EnterVehicleSound=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_Start'
	ExitVehicleSound=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_Stop'
	ExplosionSound=SoundCue'Factions_Assets.FStandardExpSFX_SoundCue'

	// Tire effects
	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Dust_Effects.P_Scorpion_Wheel_Dust')
	WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'VH_Scorpion.Effects.PS_Wheel_Rocks')
	WheelParticleEffects[2]=(MaterialType=Water,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_Scorpion_Water_Splash')
	WheelParticleEffects[3]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Snow_Effects.P_Scorpion_Wheel_Snow')
	TireSoundList(0)=(MaterialType=Dirt, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue')
	TireSoundList(1)=(MaterialType=Foliage, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireFoliage01Cue')
	TireSoundList(2)=(MaterialType=Grass, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireGrass01Cue')
	TireSoundList(3)=(MaterialType=Metal, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMetal01Cue')
	TireSoundList(4)=(MaterialType=Mud, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMud01Cue')
	TireSoundList(5)=(MaterialType=Snow, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireSnow01Cue')
	TireSoundList(6)=(MaterialType=Stone, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireStone01Cue')
	TireSoundList(7)=(MaterialType=Wood, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWood01Cue')
	TireSoundList(8)=(MaterialType=Water, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWater01Cue')

	// Seats
	Seats(0)={()}

	InitialTeam=255 // class'FTeamGame'.const.TEAM_NONE
	DestroyOnPenetrationThreshold=50.0
	DestroyOnPenetrationDuration=1.0
	bAlwaysRelevant=True
	bTeamLocked=True
}
