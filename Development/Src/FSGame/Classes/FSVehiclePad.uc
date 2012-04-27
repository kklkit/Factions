/**
 * Creates vehicles.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSVehiclePad extends FSStructure
	Implements(FSActorInterface)
	Placeable
	AutoExpandCategories(Factions);

var() class<UDKVehicle> VehicleClass;
var() int VehicleCost;

function BuildVehicle(FSPawn Builder)
{
	local FSTeamInfo Team;

	Team = FSTeamInfo(Builder.PlayerReplicationInfo.Team);

	if (Team != None && Team.Resources >= VehicleCost)
	{
		Team.Resources -= VehicleCost;
		Spawn(VehicleClass, Builder, , Location + vect(600, 600, 100));
	}
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=StructureStaticMesh
		StaticMesh=StaticMesh'FSAssets.Structures.VehiclePad'
	End Object
	Components.Add(StructureStaticMesh)

	VehicleClass=class'UTVehicle_Scorpion_Content'
	VehicleCost=100
}