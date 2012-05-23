/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FStructure_Barracks extends FStructure;

event PostBeginPlay()
{
	local Vector PlayerStartLocation;
	local FTeamPlayerStart BarracksPlayerStart;

	Super.PostBeginPlay();

	Mesh.GetSocketWorldLocationAndRotation('Spawn_Point', PlayerStartLocation);
	BarracksPlayerStart = Spawn(class'FTeamPlayerStart', Self,, PlayerStartLocation,,,);
	if (BarracksPlayerStart != None)
	{
		BarracksPlayerStart.TeamNumber = Team;
		BarracksPlayerStart.TeamIndex = Team;
	}
}

defaultproperties
{
}
