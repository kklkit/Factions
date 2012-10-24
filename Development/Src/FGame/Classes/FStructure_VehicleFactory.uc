class FStructure_VehicleFactory extends FStructure;

// Socket name for positioning the built vehicle in the world
var() name VehicleSpawnSocket;

/**
 * Builds a vehicle in the vehicle factory.
 */
function BuildVehicle(PlayerController Player, FVehicle VehicleArchetype, array<FVehicleWeapon> VehicleWeaponArchetypes)
{
	`log("Vehicle factory not active! Unable to build vehicle for" @ Player.GetHumanReadableName());
}

state Active
{

	/**
	 * @extends
	 */
	function BuildVehicle(PlayerController Player, FVehicle VehicleArchetype, array<FVehicleWeapon> VehicleWeaponArchetypes)
	{
		local int i;
		local Vector VehicleSpawnLocation;
		local FTeamInfo PlayerTeam;
		local FVehicle SpawnedVehicle;
		local FVehicleWeapon VehicleWeaponArchetype;

		if (!WorldInfo.GRI.OnSameTeam(Self, Player))
		{
			`log(Self @ "aborting vehicle creation:" @ Player.GetHumanReadableName() @ "on other team.");
			return;
		}

		Mesh.GetSocketWorldLocationAndRotation(VehicleSpawnSocket, VehicleSpawnLocation);
		VehicleSpawnLocation.Z -= VehicleArchetype.COMOffset.Z;
		PlayerTeam = FTeamInfo(Player.PlayerReplicationInfo.Team);
		if (PlayerTeam != None && PlayerTeam.Resources >= VehicleArchetype.ResourceCost)
		{
			PlayerTeam.Resources -= VehicleArchetype.ResourceCost;
			SpawnedVehicle = Spawn(VehicleArchetype.Class,,, VehicleSpawnLocation,, VehicleArchetype);
			SpawnedVehicle.SetTeamNum(Team);
			SpawnedVehicle.Mesh.WakeRigidBody();

			foreach VehicleWeaponArchetypes(VehicleWeaponArchetype, i)
				if (VehicleWeaponArchetype != None)
					SpawnedVehicle.SetWeapon(i, VehicleWeaponArchetype);

			SpawnedVehicle.TryToDrive(Player.Pawn);
		}
	}
}

defaultproperties
{
}