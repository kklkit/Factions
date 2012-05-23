/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FStructure_Barracks extends FStructure;

var() array<name> PlayerStartSockets;

event PostBeginPlay()
{
	local name PlayerStartSocketName;
	local Vector PlayerStartLocation;
	local FTeamPlayerStart BarracksPlayerStart;

	Super.PostBeginPlay();

	foreach PlayerStartSockets(PlayerStartSocketName)
	{
		Mesh.GetSocketWorldLocationAndRotation(PlayerStartSocketName, PlayerStartLocation);
		BarracksPlayerStart = Spawn(class'FTeamPlayerStart', Self,, PlayerStartLocation,,,);
		if (BarracksPlayerStart != None)
		{
			BarracksPlayerStart.TeamNumber = Team;
			BarracksPlayerStart.TeamIndex = Team;
		}
	}
}

defaultproperties
{
}
