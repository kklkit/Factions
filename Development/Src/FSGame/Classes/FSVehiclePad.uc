/**
 * Creates vehicles.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSVehiclePad extends FSStructure;

var() class<UDKVehicle> VehicleClass;
var() int VehicleCost;

function BuildVehicle(FSPawn Builder)
{
	local FSTeamInfo Team;

	if (Builder.Base == self)
	{
		Team = FSTeamInfo(Builder.PlayerReplicationInfo.Team);

		if (Team != None && Team.Resources >= VehicleCost)
		{
			Team.Resources -= VehicleCost;
			Spawn(VehicleClass, Builder, , Location + vect(600, 600, 100));
		}
	}
}

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'FSAssets.Structures.VehiclePad'
	End Object

	VehicleClass=class'UTVehicle_Scorpion_Content'
	VehicleCost=100
}