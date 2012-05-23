/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSStruct_Barracks extends FSStructure;

event PostBeginPlay()
{
	local Vector PlayerStartLocation;
	local FSTeamPlayerStart BarracksPlayerStart;

	Super.PostBeginPlay();

	Mesh.GetSocketWorldLocationAndRotation('Spawn_Point', PlayerStartLocation);
	BarracksPlayerStart = Spawn(class'FSTeamPlayerStart', Self,, PlayerStartLocation,,,);
	if (BarracksPlayerStart != None)
	{
		BarracksPlayerStart.TeamNumber = Team;
		BarracksPlayerStart.TeamIndex = Team;
	}
}

defaultproperties
{
}
