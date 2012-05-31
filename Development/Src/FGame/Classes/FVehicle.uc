/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicle extends UDKVehicle
	notplaceable;

// True when the vehicle has been fully constructed and the builder is in the vehicle
var bool bFinishedConstructing;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	AirSpeed=MaxSpeed;
	Mesh.WakeRigidBody();
}

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

	Begin Object Name=SVehicleMesh
		LightEnvironment=LightEnvironment0
	End Object

	Seats(0)={()}

	DestroyOnPenetrationThreshold=50.0
	DestroyOnPenetrationDuration=1.0
	bFinishedConstructing=False
}
