/**
 * Provides an infantry spawn point.
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
	local FSTeamPlayerStart BarracksPlayerStart;

	super.PostBeginPlay();

	SpawnLocation.X = Location.X + 200;
	SpawnLocation.Y = Location.Y + 1000;
	SpawnLocation.Z = Location.Z + 75;

	Spawn(class'FSWeaponPickupFactory', self, , SpawnLocation, , , );

	SpawnLocation.X = Location.X + 200;
	SpawnLocation.Y = Location.Y + 200;
	SpawnLocation.Z = Location.Z + 125;

	BarracksPlayerStart = Spawn(class'FSTeamPlayerStart', self, , SpawnLocation, , , );

	if (BarracksPlayerStart != none)
	{
		BarracksPlayerStart.TeamNumber = self.GetTeamNum();
		BarracksPlayerStart.TeamIndex = self.GetTeamNum();
	}
}

defaultproperties
{
	begin object name=StaticMeshComponent0
		StaticMesh=StaticMesh'FSAssets.Structures.Barracks'
	end object
}
