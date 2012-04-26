/**
 * Creates vehicles.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSVehiclePad extends Actor //@todo this should extend an FS class
	Implements(FSActorInterface)
	Placeable
	AutoExpandCategories(Factions);

var(Factions) class<UDKVehicle> VehicleClass;

event PostBeginPlay()
{
	super.PostBeginPlay();

	SetCollision(true, true);
}

function BuildVehicle()
{
	Spawn(VehicleClass, , , Location + vect(500, 500, 200));
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=StructureStaticMesh
		StaticMesh=StaticMesh'FSAssets.Structures.VehiclePad'
	End Object
	Components.Add(StructureStaticMesh)
	
	bCanStepUpOn=true
	bCollideComplex=true

	VehicleClass=class'UTVehicle_Scorpion_Content'

	RemoteRole=ROLE_SimulatedProxy
}