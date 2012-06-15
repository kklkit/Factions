/**
 * Extracts resources from a resource point.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FStructure_Refinery extends FStructure;

/**
 * @extends
 */
event PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(1.0, True, nameof(ExtractResources));
}

/**
 * Transfers resources from the resource point to the team.
 */
function ExtractResources()
{
	FTeamInfo(WorldInfo.Game.GameReplicationInfo.Teams[Team]).Resources++;
}

defaultproperties
{
}
