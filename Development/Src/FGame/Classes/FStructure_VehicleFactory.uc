/**
 * Class for structures that can build vehicles.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FStructure_VehicleFactory extends FStructure
	dependson(FMapInfo);

// Socket name for positioning the built vehicle in the world
var() name VehicleSpawnSocket;

/**
 * Builds a vehicle in the vehicle factory.
 */
function BuildVehicle(int VehicleIndex, Pawn Builder)
{
	`log("Structure not active: Unable to build vehicle with index" @ VehicleIndex @ "for" @ Builder);
}

state Active
{

	/**
	 * @extends
	 */
	function BuildVehicle(int VehicleIndex, Pawn Builder)
	{
		local Vector VehicleSpawnLocation;
		local FTeamInfo PlayerTeam;
		local FVehicleInfo VehicleInfo;
		local FVehicle Vehicle;

		Mesh.GetSocketWorldLocationAndRotation(VehicleSpawnSocket, VehicleSpawnLocation);
		PlayerTeam = FTeamInfo(Builder.PlayerReplicationInfo.Team);
		VehicleInfo = FMapInfo(WorldInfo.GetMapInfo()).Vehicles[VehicleIndex];
		if (PlayerTeam != None && PlayerTeam.Resources >= 100)
		{
			PlayerTeam.Resources -= 100;
			Vehicle = Spawn(VehicleInfo.Archetype.Class, Builder.Controller,, VehicleSpawnLocation,, VehicleInfo.Archetype);
			Vehicle.Team = Builder.GetTeamNum();
			Vehicle.TryToDrive(Builder);
			Vehicle.bFinishedConstructing = True;
		}
	}
}

defaultproperties
{
}