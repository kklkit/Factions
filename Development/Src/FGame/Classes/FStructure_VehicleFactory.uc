/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FStructure_VehicleFactory extends FStructure
	dependson(FMapInfo);

var() name VehicleSpawnSocket;

function BuildVehicle(name VehicleName, Pawn Builder)
{
	local Vector VehicleSpawnLocation;
	local FTeamInfo PlayerTeam;
	local FVehicleInfo VehicleInfo;
	local FVehicle Vehicle;

	Mesh.GetSocketWorldLocationAndRotation(VehicleSpawnSocket, VehicleSpawnLocation);
	PlayerTeam = FTeamInfo(Builder.PlayerReplicationInfo.Team);
	VehicleInfo = FMapInfo(WorldInfo.GetMapInfo()).GetVehicleInfo(VehicleName);
	if (PlayerTeam != None && PlayerTeam.Resources >= 100)
	{
		PlayerTeam.Resources -= 100;
		Vehicle = Spawn(VehicleInfo.Archetype.Class, Builder,, VehicleSpawnLocation,, VehicleInfo.Archetype);
		Vehicle.Team = Builder.GetTeamNum();
		Vehicle.TryToDrive(Builder);
		Vehicle.bFinishedConstructing = True;
	}
}

defaultproperties
{
}