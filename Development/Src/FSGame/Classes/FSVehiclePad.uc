/**
 * Creates vehicles.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSVehiclePad extends Actor //@todo this should extend an FS class
	Implements(FSActorInterface)
	Placeable
	AutoExpandCategories(Factions);

var(Factions) int VehicleHealth;
var(Factions) class<UDKVehicle> VehicleClass;

event PostBeginPlay()
{
	super.PostBeginPlay();

	SetCollision(true, true);
}

event Bump(Actor Other, PrimitiveComponent OtherComp, Object.Vector HitNormal)
{
	local UDKVehicle SpawnedVehicle;

	super.Bump(Other, OtherComp, HitNormal);

	if (FSPawn(Other) != none)
	{
		SpawnedVehicle = Spawn(VehicleClass, , , Location + vect(500, 500, 200));
		SpawnedVehicle.HealthMax = VehicleHealth;
		SpawnedVehicle.Health = VehicleHealth;
	}
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=StructureStaticMesh
		StaticMesh=StaticMesh'FSAssets.Structures.VehiclePad'
	End Object
	Components.Add(StructureStaticMesh)
	
	bCanStepUpOn=true
	bCollideComplex=true

	VehicleHealth=100
	VehicleClass=class'UTVehicle_Scorpion_Content'

	RemoteRole=ROLE_SimulatedProxy
}