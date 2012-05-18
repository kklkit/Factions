/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSStruct_VehicleFactory extends FSStructure
	dependson(FSVehicleInfo);

function BuildVehicle(name ChassisName, Pawn Builder)
{
	local FSTeamInfo Team;
	local FSVehicle V;
	local VehicleInfo VI;

	Team = FSTeamInfo(Builder.PlayerReplicationInfo.Team);

	VI = class'FSVehicleInfo'.default.Vehicles[class'FSVehicleInfo'.default.Vehicles.Find('Name', ChassisName)];

	if (Team != None && Team.Resources >= 100)
	{
		Team.Resources -= 100;
		V = Spawn(VI.Class,,, Location + vect(600, 600, 100));
		V.Team = Builder.PlayerReplicationInfo.Team.TeamIndex;
	}
}

defaultproperties
{
	Begin Object Name=StructureMeshComponent
		StaticMesh=StaticMesh'FSAssets.Structures.VehiclePad'
	End Object
}