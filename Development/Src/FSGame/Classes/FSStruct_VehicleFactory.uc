/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSStruct_VehicleFactory extends FSStructure;

var() class<FSVehicle> VehicleClass;
var() int VehicleCost;

function BuildVehicle(FSPawn Builder)
{
	local FSTeamInfo Team;
	local FSVehicle V;

	Team = FSTeamInfo(Builder.PlayerReplicationInfo.Team);

	if (Team != None && Team.Resources >= VehicleCost)
	{
		Team.Resources -= VehicleCost;
		V = Spawn(VehicleClass, , , Location + vect(600, 600, 100));
		V.Team = Builder.PlayerReplicationInfo.Team.TeamIndex;
	}
}

defaultproperties
{
	Begin Object Name=StructureMeshComponent
		StaticMesh=StaticMesh'FSAssets.Structures.VehiclePad'
	End Object

	VehicleClass=class'FSVehicle_Gunship'
	VehicleCost=100
}