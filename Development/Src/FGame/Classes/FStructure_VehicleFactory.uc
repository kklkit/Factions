/**
 * Class for structures that can build vehicles.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FStructure_VehicleFactory extends FStructure;

// Socket name for positioning the built vehicle in the world
var() name VehicleSpawnSocket;

/**
 * Builds a vehicle in the vehicle factory.
 */
function BuildVehicle(Pawn Builder, int VehicleIndex, int WeaponIndex)
{
	`log("Structure not active: Unable to build vehicle with index" @ VehicleIndex @ "for" @ Builder);
}

state Active
{

	/**
	 * @extends
	 */
	function BuildVehicle(Pawn Builder, int VehicleIndex, int WeaponIndex)
	{
		local int i;
		local Vector VehicleSpawnLocation;
		local FTeamInfo PlayerTeam;
		local FVehicle VehicleArchetype;
		local FVehicle SpawnedVehicle;

		Mesh.GetSocketWorldLocationAndRotation(VehicleSpawnSocket, VehicleSpawnLocation);
		PlayerTeam = FTeamInfo(Builder.PlayerReplicationInfo.Team);
		VehicleArchetype = FMapInfo(WorldInfo.GetMapInfo()).Vehicles[VehicleIndex];
		if (PlayerTeam != None && PlayerTeam.Resources >= VehicleArchetype.ResourceCost)
		{
			PlayerTeam.Resources -= VehicleArchetype.ResourceCost;
			SpawnedVehicle = Spawn(VehicleArchetype.Class,,, VehicleSpawnLocation,, VehicleArchetype);
			SpawnedVehicle.SetTeamNum(Team);
			SpawnedVehicle.SetWeapon(0, FMapInfo(WorldInfo.GetMapInfo()).VehicleWeapons[WeaponIndex]);
			SpawnedVehicle.Mesh.WakeRigidBody();

			for (i = 0; i < SpawnedVehicle.Seats.Length; i++)
				SpawnedVehicle.ForceWeaponRotation(i, SpawnedVehicle.Rotation);
		}
	}
}

defaultproperties
{
}