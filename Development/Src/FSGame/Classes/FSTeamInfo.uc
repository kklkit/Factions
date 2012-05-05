/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSTeamInfo extends TeamInfo;

var int Resources;
var localized string TeamNames[ETeams];

replication
{
	if (bNetDirty)
		Resources;
}

simulated function string GetHumanReadableName()
{
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
