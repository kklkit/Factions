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
		local int i;
		local Vector VehicleSpawnLocation;
		local FTeamInfo PlayerTeam;
		local FVehicleInfo VehicleInfo;
		local FVehicle SpawnedVehicle;

		Mesh.GetSocketWorldLocationAndRotation(VehicleSpawnSocket, VehicleSpawnLocation);
		PlayerTeam = FTeamInfo(Builder.PlayerReplicationInfo.Team);
		VehicleInfo = FMapInfo(WorldInfo.GetMapInfo()).Vehicles[VehicleIndex];
		if (PlayerTeam != None && PlayerTeam.Resources >= VehicleInfo.Archetype.ResourceCost)
		{
			PlayerTeam.Resources -= VehicleInfo.Archetype.ResourceCost;
			SpawnedVehicle = Spawn(VehicleInfo.Archetype.Class,,, VehicleSpawnLocation,, VehicleInfo.Archetype);
			SpawnedVehicle.SetTeamNum(Team);
			SpawnedVehicle.Mesh.WakeRigidBody();

			for (i = 0; i < SpawnedVehicle.Seats.Length; i++)
				SpawnedVehicle.ForceWeaponRotation(i, SpawnedVehicle.Rotation);
		}
	}
}

defaultproperties
{
}