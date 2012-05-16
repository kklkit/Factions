/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSStruct_VehicleFactory extends FSStructure;

function BuildVehicle(Pawn Builder)
{
	local FSTeamInfo Team;
	local FSVehicle V;

	Team = FSTeamInfo(Builder.PlayerReplicationInfo.Team);

	if (Team != None && Team.Resources >= 100)
	{
		Team.Resources -= 100;
		V = Spawn(class'FSVehicle_Jeep', Builder,, Location + vect(600, 600, 100));
		V.Team = Builder.PlayerReplicationInfo.Team.TeamIndex;
	}
}

defaultproperties
{
	Begin Object Name=StructureMeshComponent
		StaticMesh=StaticMesh'FSAssets.Structures.VehiclePad'
	End Object
}