/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSStruct_Barracks extends FSStructure;

function PostBeginPlay()
{
	local Vector SpawnLocation;
	local FSTeamPlayerStart BarracksPlayerStart;

	Super.PostBeginPlay();

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
	Begin Object Name=StructureMeshComponent
		StaticMesh=StaticMesh'FSAssets.Structures.Barracks'
	End Object
}
