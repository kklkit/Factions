/**
 * Spawns players and weapons.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSBarracks extends FSStructure;

/**
 * @extends
 */
event PostBeginPlay()
{
	local Vector SpawnLocation;
	local FSTeamPlayerStart TPS;

	super.PostBeginPlay();

	SpawnLocation.X = Location.X + 200;
	SpawnLocation.Y = Location.Y + 1000;
	SpawnLocation.Z = Location.Z + 75;

	Spawn(class'FSWeaponPickupFactory', self, , SpawnLocation, , , );

	SpawnLocation.X = Location.X + 200;
	SpawnLocation.Y = Location.Y + 200;
	SpawnLocation.Z = Location.Z + 125;

	TPS = Spawn(class'FSTeamPlayerStart', self, , SpawnLocation, , , );

	if (TPS != None)
	{
		TPS.TeamNumber = self.GetTeamNum();
		TPS.TeamIndex = self.GetTeamNum();
	}
}

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'FSAssets.Structures.Barracks'
	End Object
}
