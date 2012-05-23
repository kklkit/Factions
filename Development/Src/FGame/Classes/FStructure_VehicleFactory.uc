/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FStructure_VehicleFactory extends FStructure
	dependson(FVehicleInfo);

var() name VehicleSpawnSocket;

function BuildVehicle(name ChassisName, Pawn Builder)
{
	local Vector VehicleSpawnLocation;
	local FTeamInfo PlayerTeam;
	local VehicleInfo VehicleInfo;
	local FVehicle Vehicle;

	Mesh.GetSocketWorldLocationAndRotation(VehicleSpawnSocket, VehicleSpawnLocation);
	PlayerTeam = FTeamInfo(Builder.PlayerReplicationInfo.Team);
	VehicleInfo = class'FVehicleInfo'.default.Vehicles[class'FVehicleInfo'.default.Vehicles.Find('Name', ChassisName)];
	if (PlayerTeam != None && PlayerTeam.Resources >= 100)
	{
		PlayerTeam.Resources -= 100;
		Vehicle = Spawn(VehicleInfo.Class,,, VehicleSpawnLocation);
		Vehicle.Team = Builder.GetTeamNum();
		Vehicle.TryToDrive(Builder);
	}
}

defaultproperties
{
}