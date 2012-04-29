/**
 * Provides an infantry spawn point.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSStruct_Barracks extends FSStructure;

/**
 * @extends
 */
function PostBeginPlay()
{
	local Vector SpawnLocation;
	local FSTeamPlayerStart BarracksPlayerStart;

	Super.PostBeginPlay();

	SpawnLocation.X = Location.X + 200;
	SpawnLocation.Y = Location.Y + 1000;
	SpawnLocation.Z = Location.Z + 75;

	Spawn(class'FSWeaponPickupFactory', self, , SpawnLocation, , , );

	SpawnLocation.X = Location.X + 200;
	SpawnLocation.Y = Location.Y + 200;
	SpawnLocation.Z = Location.Z + 125;

	BarracksPlayerStart = Spawn(class'FSTeamPlayerStart', self, , SpawnLocation, , , );

	if (BarracksPlayerStart != None)
	{
		BarracksPlayerStart.TeamNumber = self.GetTeamNum();
		BarracksPlayerStart.TeamIndex = self.GetTeamNum();
	}
}

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'FSAssets.Structures.Barracks'
	End Object
}