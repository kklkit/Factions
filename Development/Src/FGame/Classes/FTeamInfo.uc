/**
 * Replicated information about each team.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FTeamInfo extends TeamInfo;

var int Resources;
var int Reinforcements;
var localized string TeamNames[ETeams];
var Pawn Commander; // Command vehicle

replication
{
	if (bNetDirty)
		Resources, Reinforcements, Commander;
}

/**
 * @extends
 */
event PostBeginPlay()
{
	Super.PostBeginPlay();

	Resources = FMapInfo(WorldInfo.GetMapInfo()).StartingResources;
}

/**
 * @extends
 */
simulated function string GetHumanReadableName()
{
	// Return the localized team name
	if (TeamName == Default.TeamName)
	{
		if (TeamIndex < ArrayCount(TeamNames))
			return TeamNames[TeamIndex];
		return TeamName @ TeamIndex;
	}
	return TeamName;
}

defaultproperties
{
	Reinforcements=100
}
