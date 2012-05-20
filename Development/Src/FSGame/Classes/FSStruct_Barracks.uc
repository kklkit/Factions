/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSStruct_Barracks extends FSStructure;

event PostBeginPlay()
{
	local Vector PlayerStartLocation;
	local FSTeamPlayerStart BarracksPlayerStart;

	Super.PostBeginPlay();

	PlayerStartLocation.X = Location.X + 200;
	PlayerStartLocation.Y = Location.Y + 200;
	PlayerStartLocation.Z = Location.Z + 125;

	BarracksPlayerStart = Spawn(class'FSTeamPlayerStart', self,, PlayerStartLocation,,,);

	if (BarracksPlayerStart != None)
	{
		BarracksPlayerStart.TeamNumber = self.GetTeamNum();
		BarracksPlayerStart.TeamIndex = self.GetTeamNum();
	}
}

defaultproperties
{
	Begin Object Name=StructureMeshComponent
		StaticMesh=StaticMesh'ST_BarracksMash.Mesh.S_ST_BarracksMash'
	End Object

	DrawScale=1.2
}
