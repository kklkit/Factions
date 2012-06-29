/**
 * Base class for all vehicles.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicle extends UDKVehicle
	perobjectlocalized
	notplaceable;

const FVEHICLE_UNSET_TEAM=255;

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

var(Factions) byte InitialTeam;
var(Factions) int ResourceCost;
var(Factions) bool bIsCommandVehicle;
var(Seats) array<TurretControl> TurretControls;

var repnotify Rotator TurretRotations[2];
var FVehicleWeapon VehicleWeapons[2];

replication
{
	if (bNetDirty && bNetOwner)
		VehicleWeapons;

	if (bNetDirty && !bNetOwner)
		TurretRotations;
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

		if (InitialTeam != FVEHICLE_UNSET_TEAM)
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
	PreCacheSeatNames();

	AirSpeed = MaxSpeed;
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
 * Updates the SeatMask.
 */
function SetSeatStoragePawn(int SeatIndex, Pawn PawnToSit)
{
	local int Mask;

	Seats[SeatIndex].StoragePawn = PawnToSit;

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
 * Returns the seat index for the given seat prefix.
 */
simulated function int GetSeatIndexFromPrefix(string Prefix)
{
	local int i;

	for (i = 0; i < Seats.Length; i++)
	{
		if (Seats[i].TurretVarPrefix ~= Prefix)
		{
			return i;
		}
	}

	return -1;
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

				if (Role < ROLE_Authority)
					ServerSetTurretRotation(i, TC.RotateController.DesiredBoneRotation);
			}
		}
	}
}

/**
 * Sets the weapon rotation on the server.
 */
unreliable server function ServerSetTurretRotation(int ControlIndex, Rotator TurretRotation)
{
	TurretControls[ControlIndex].RotateController.DesiredBoneRotation = TurretRotation;
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
simulated function GetBarrelLocationAndRotation(int SeatIndex, out Vector SocketLocation, optional out Rotator SocketRotation)
{
	if (Seats[SeatIndex].GunSocket.Length > 0)
	{
		Mesh.GetSocketWorldLocationAndRotation(Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)], SocketLocation, SocketRotation);
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
		`log("Vehicle (" $ Self $ ") has no seats! Deleting!");
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
 * Set seat names.
 */
simulated function PreCacheSeatNames()
{
	local int i;
	for (i = 0; i < Seats.Length; i++)
	{
		Seats[i].WeaponRotationName	= name(Seats[i].TurretVarPrefix $ "WeaponRotation");
		Seats[i].FlashLocationName = name(Seats[i].TurretVarPrefix $ "FlashLocation");
		Seats[i].FlashCountName = name(Seats[i].TurretVarPrefix $ "FlashCount");
		Seats[i].FiringModeName = name(Seats[i].TurretVarPrefix $ "FiringMode");
	}
}

/**
 * @extends
 */
simulated function bool CalcCamera(float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV)
{
	local int SeatIndex;

	SeatIndex = 0;

	if (Seats[SeatIndex].CameraTag != '')
	{
		Mesh.GetSocketWorldLocationAndRotation(Seats[0].CameraTag, out_CamLoc, out_CamRot);
	}
	else
	{
		return Super.CalcCamera(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
	}

	return True;
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
simulated function SetFiringMode(Weapon Weap, byte FiringModeNum)
{
	SeatFiringMode(0, FiringModeNum, false);
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
 * Adds a passenger to the vehicle.
 */
function bool PassengerEnter(Pawn P, int SeatIndex)
{
	if (WorldInfo.Game.bTeamGame && !WorldInfo.GRI.OnSameTeam(P, self))
	{
		return False;
	}

	if (SeatIndex <= 0 || SeatIndex >= Seats.Length)
	{
		`warn("Attempted to add a passenger to unavailable passenger seat" @ SeatIndex);
		return False;
	}

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
 * Spawns a vehicle weapon for the given seat.
 */
function SetWeapon(int WeaponSlot, FVehicleWeapon WeaponArchetype)
{
	local FVehicleWeapon VehicleWeapon;

	VehicleWeapon = Spawn(WeaponArchetype.Class, InvManager.Owner,,,, WeaponArchetype);

	if (InvManager.AddInventory(VehicleWeapon))
	{
		VehicleWeapon.SeatIndex = 0;
		VehicleWeapon.MyVehicle = Self;
		VehicleWeapon.SetBase(Self);
		VehicleWeapon.ClientWeaponSet(False);

		VehicleWeapons[WeaponSlot] = VehicleWeapon;
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
simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional Vector HitLocation)
{
	local ParticleSystemComponent E;

	if (WorldInfo.NetMode != NM_DedicatedServer && (Role == ROLE_Authority || bViaReplication))
	{
		E = WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_2ndPrim_Beam', GetWeaponStartTraceLocation(InWeapon));
		E.SetVectorParameter('ShockBeamEnd', HitLocation);
	}
}

/**
 * @extends
 */
simulated event Vector GetWeaponStartTraceLocation(optional Weapon CurrentWeapon)
{
	local Vector SocketLocation;

	if (FVehicleWeapon(CurrentWeapon) != None)
		GetBarrelLocationAndRotation(FVehicleWeapon(CurrentWeapon).SeatIndex, SocketLocation);
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
		GetBarrelLocationAndRotation(FVehicleWeapon(W).SeatIndex, SocketLocation, SocketRotation);
	else
		return Super.GetAdjustedAimFor(W, StartFireLoc);

	return SocketRotation;
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

	TireSoundList(0)=(MaterialType=Dirt, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue')
	TireSoundList(1)=(MaterialType=Foliage, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireFoliage01Cue')
	TireSoundList(2)=(MaterialType=Grass, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireGrass01Cue')
	TireSoundList(3)=(MaterialType=Metal, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMetal01Cue')
	TireSoundList(4)=(MaterialType=Mud, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMud01Cue')
	TireSoundList(5)=(MaterialType=Snow, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireSnow01Cue')
	TireSoundList(6)=(MaterialType=Stone, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireStone01Cue')
	TireSoundList(7)=(MaterialType=Wood, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWood01Cue')
	TireSoundList(8)=(MaterialType=Water, Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWater01Cue')

	Seats(0)={()}

	InitialTeam=FVEHICLE_UNSET_TEAM
	DestroyOnPenetrationThreshold=50.0
	DestroyOnPenetrationDuration=1.0
	bAlwaysRelevant=True
}
