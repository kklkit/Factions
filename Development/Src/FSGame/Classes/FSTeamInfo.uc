/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSTeamInfo extends TeamInfo;

var int Resources;
var localized string TeamColorNames[4];

replication
{
	if (bNetDirty)
		Resources;
}

simulated function string GetHumanReadableName()
{
	if (TeamName == Default.TeamName)
	{
		if (TeamIndex < 4)
			return TeamColorNames[TeamIndex];
		return TeamName@TeamIndex;
	}
	return TeamName;
}

defaultproperties
{
	Resources=400
}
