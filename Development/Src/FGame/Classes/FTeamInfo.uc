/**
 * Replicated information about each team.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FTeamInfo extends TeamInfo;

var int Resources;
var localized string TeamNames[ETeams];
var Pawn Commander;

replication
{
	if (bNetDirty)
		Resources, Commander;
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
	Resources=400
}
