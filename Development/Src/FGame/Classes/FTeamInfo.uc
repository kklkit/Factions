/**
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
	local FMapInfo MI;

	Super.PostBeginPlay();

	MI = FMapInfo(WorldInfo.GetMapInfo());

	Resources = MI.StartingResources;
	Reinforcements = MI.StartingReinforcements;
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

function DeductReinforcements(int Amount = 1)
{
	Reinforcements -= Amount;
}

defaultproperties
{
}
