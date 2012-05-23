/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSStruct_VehicleFactory extends FSStructure
	dependson(FSVehicleInfo);

function BuildVehicle(name ChassisName, Pawn Builder)
{
	local FSTeamInfo PlayerTeam;
	local FSVehicle Vehicle;
	local VehicleInfo VehicleInfo;

	PlayerTeam = FSTeamInfo(Builder.PlayerReplicationInfo.Team);
	VehicleInfo = class'FSVehicleInfo'.default.Vehicles[class'FSVehicleInfo'.default.Vehicles.Find('Name', ChassisName)];
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