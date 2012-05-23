/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FStructure_VehicleFactory extends FStructure
	dependson(FVehicleInfo);

function BuildVehicle(name ChassisName, Pawn Builder)
{
	local FTeamInfo PlayerTeam;
	local FVehicle Vehicle;
	local VehicleInfo VehicleInfo;

	PlayerTeam = FTeamInfo(Builder.PlayerReplicationInfo.Team);
	VehicleInfo = class'FVehicleInfo'.default.Vehicles[class'FVehicleInfo'.default.Vehicles.Find('Name', ChassisName)];
	if (PlayerTeam != None && PlayerTeam.Resources >= 100)
	{
		PlayerTeam.Resources -= 100;
		Vehicle = Spawn(VehicleInfo.Class,,, Location + vect(150, 0, 100));
		Vehicle.Team = Builder.GetTeamNum();
		Vehicle.TryToDrive(Builder);
	}
}

defaultproperties
{
}