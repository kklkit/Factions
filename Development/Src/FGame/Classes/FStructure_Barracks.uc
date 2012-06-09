/**
 * Class for structures that can spawn infantry.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FStructure_Barracks extends FStructure;

// List of socket names where players can spawn
var() array<name> PlayerStartSockets;

/**
 * @extends
 */
event PostBeginPlay()
{
	local name PlayerStartSocketName;
	local Vector PlayerStartLocation;
	local FTeamPlayerStart BarracksPlayerStart;

	Super.PostBeginPlay();

	// Create a start location at each socket
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
