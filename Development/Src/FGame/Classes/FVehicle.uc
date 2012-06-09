/**
 * Base class for all vehicles.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicle extends UDKVehicle
	notplaceable;

// True when the vehicle has been fully constructed and the builder is in the vehicle
var bool bFinishedConstructing;

/**
 * @extends
 */
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	AirSpeed=MaxSpeed;
	Mesh.WakeRigidBody();
}

/**
 * @extends
 */
function PancakeOther(Pawn Other)
{
	// Don't kill vehicle builder while building the vehicle
	if (Other == Owner && !bFinishedConstructing)
		return;

	Super.PancakeOther(Other);
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

	TireSoundList(0)=(MaterialType=Dirt,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue')
	TireSoundList(1)=(MaterialType=Foliage,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireFoliage01Cue')
	TireSoundList(2)=(MaterialType=Grass,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireGrass01Cue')
	TireSoundList(3)=(MaterialType=Metal,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMetal01Cue')
	TireSoundList(4)=(MaterialType=Mud,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMud01Cue')
	TireSoundList(5)=(MaterialType=Snow,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireSnow01Cue')
	TireSoundList(6)=(MaterialType=Stone,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireStone01Cue')
	TireSoundList(7)=(MaterialType=Wood,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWood01Cue')
	TireSoundList(8)=(MaterialType=Water,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWater01Cue')

	Seats(0)={()}

	DestroyOnPenetrationThreshold=50.0
	DestroyOnPenetrationDuration=1.0
	bFinishedConstructing=False
}
