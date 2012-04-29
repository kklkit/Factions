/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSStruct_VehicleFactory extends FSStructure;

var() class<UDKVehicle> VehicleClass;
var() int VehicleCost;

function BuildVehicle(FSPawn Builder)
{
	local FSTeamInfo Team;

	if (Builder.Base == self) //@todo move check to caller
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
	Begin Object Name=StructureMeshComponent
		StaticMesh=StaticMesh'FSAssets.Structures.VehiclePad'
	End Object

	VehicleClass=class'UTVehicle_Scorpion_Content'
	VehicleCost=100
}