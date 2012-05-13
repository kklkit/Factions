/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSVehicle extends UDKVehicle
	abstract
	notplaceable;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	Mesh.WakeRigidBody();
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object Name=SVehicleMesh
		LightEnvironment=MyLightEnvironment
	End Object

	DestroyOnPenetrationThreshold=50.0
	DestroyOnPenetrationDuration=1.0
}
