/**
 * Base class for all vehicles.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicle extends UDKVehicle
	perobjectlocalized
	notplaceable;

const FVEHICLE_UNSET_TEAM=255;

var() byte InitialTeam;
var() int ResourceCost;

/**
 * @extends
 */
simulated event ReplicatedEvent(name VarName)
{
	local string VarString;
	local int SeatIndex;

	VarString = "" $ VarName;
	if (Right(VarString, 14) ~= "weaponrotation")
	{
		SeatIndex = GetSeatIndexFromPrefix(Left(VarString, Len(VarString) - 14));
		if (SeatIndex >= 0)
		{
			WeaponRotationChanged(SeatIndex);
		}
	}

	Super.ReplicatedEvent(VarName);
}

/**
 * @extends
 */
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	if (InitialTeam != FVEHICLE_UNSET_TEAM)
		Team = InitialTeam;

	if (Role == ROLE_Authority)
		InitializeSeats();
	else if (Seats.Length > 0)
		Seats[0].SeatPawn = Self;

	PreCacheSeatNames();
	InitializeTurrets();

	AirSpeed = MaxSpeed;
	Mesh.WakeRigidBody();
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
 * Updates the weapon rotation for the given seat.
 */
simulated function WeaponRotationChanged(int SeatIndex)
{
	local int i;

	if (SeatIndex >= 0)
	{
		for (i = 0; i < Seats[SeatIndex].TurretControllers.Length; i++)
		{
			Seats[SeatIndex].TurretControllers[i].DesiredBoneRotation = SeatWeaponRotation(SeatIndex,, True);
		}
	}
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
			if (Seats[i].GunClass != None)
			{
				Seats[i].Gun = FVehicleWeapon(Seats[i].SeatPawn.InvManager.CreateInventory(Seats[i].GunClass));
				Seats[i].Gun.SetBase(Self);
			}
			Seats[i].SeatPawn.EyeHeight = Seats[i].SeatPawn.BaseEyeheight;
			UDKWeaponPawn(Seats[i].SeatPawn).MyVehicleWeapon = FVehicleWeapon(Seats[i].Gun);
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
			if (Seats[i].GunClass != None)
			{
				Seats[i].Gun = FVehicleWeapon(InvManager.CreateInventory(Seats[i].GunClass));
				Seats[i].Gun.SetBase(Self);
			}
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
 * Sets up turret skeletal controllers.
 */
simulated function InitializeTurrets()
{
	local int Seat, TurretControl;
	local UDKSkelControl_TurretConstrained Turret;
	local Vector PivotLoc, MuzzleLoc;

	for (Seat = 0; Seat < Seats.Length; Seat++)
	{
		for (TurretControl = 0; TurretControl < Seats[Seat].TurretControls.Length; TurretControl++)
		{
			Turret = UDKSkelControl_TurretConstrained(Mesh.FindSkelControl(Seats[Seat].TurretControls[TurretControl]));
			if (Turret != None)
			{
				Turret.AssociatedSeatIndex = Seat;
				Seats[Seat].TurretControllers[TurretControl] = Turret;
				Turret.InitTurret(Rotation, Mesh);
			}
			else
			{
				`log("Failed to set up turret control" @ TurretControl);
			}
		}

		if (Role == ROLE_Authority)
			SeatWeaponRotation(Seat, Rotation, False);

		PivotLoc = GetSeatPivotPoint(Seat);
		GetBarrelLocationAndRotation(Seat, MuzzleLoc);

		Seats[Seat].PivotFireOffsetZ = MuzzleLoc.Z - PivotLoc.Z;
	}
}

/**
 * @extends
 */
function PossessedBy(Controller C, bool bVehicleTransition)
{
	Super.PossessedBy(C, bVehicleTransition);

	if (Seats[0].Gun != None)
		Seats[0].Gun.ClientWeaponSet(False);
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
		DebugInfo[DebugInfo.Length] = "Seat" @ i $ ":" @Seats[i].Gun @ "Rotation" @ SeatWeaponRotation(i,, true) @ "FiringMode" @ SeatFiringMode(i,, true) @ "Barrel" @ Seats[i].BarrelIndex;
		if (Seats[i].Gun != None)
			DebugInfo[DebugInfo.length - 1] @= "IsAimCorrect" @ Seats[i].Gun.IsAimCorrect();
	}
}

/**
 * @extends
 */
function bool DriverEnter(Pawn P)
{
	P.StopFiring();

	if (Seats[0].Gun != None)
		InvManager.SetCurrentWeapon(Seats[0].Gun);

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

	InventoryManagerClass=class'FInventoryManager'

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
