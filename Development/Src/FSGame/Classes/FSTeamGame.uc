/**
 * Base class for Factions game modes.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSTeamGame extends GameInfo;

const NumTeams=2; //@todo test to make sure increasing the number of teams actually works

var FSTeamInfo Teams[NumTeams];

/**
 * @extends
 */
event PreBeginPlay()
{
	local int i;

	super.PreBeginPlay();

	// Set the map info if the mapper didn't do it
	if (WorldInfo.GetMapInfo() == none)
	{
		`log("MAPINFO NOT SET!!!");
		WorldInfo.SetMapInfo(new class'FSGame.FSMapInfo');
	}

	// Create the teams
	for (i = 0; i < NumTeams; i++)
		CreateTeam(i);
}

/**
 * @extends
 */
function bool ChangeTeam(Controller Other, int N, bool bNewTeam)
{
	local bool bChangedTeam;
	local PlayerController PC;

	super.ChangeTeam(Other, N, bNewTeam);

	// Ensure the given team index is valid
	if (N >= 0 && N < NumTeams)
	{
		Teams[N].AddToTeam(Other);
		bChangedTeam = true;
	}
	else
		bChangedTeam = false;

	// Broadcast join message
	PC = PlayerController(Other);
	if (PC != none)
	{
		if (bChangedTeam)
			BroadcastHandler.Broadcast(self, Other.GetHumanReadableName() @ "joined team" @ N);
		else
			PC.ClientMessage("Failed to change to team" @ N);
	}

	return bChangedTeam;
}

/**
 * Override to return the team index for the team with fewest players.
 * 
 * @extends
 */
function byte PickTeam(byte Current, Controller C)
{
	//@todo make this work for more than 2 teams
	if (Teams[0].Size <= Teams[1].Size)
		return 0;
	else
		return 1;
}

/**
 * Creates a new team given the team index.
 */
function CreateTeam(int TeamIndex)
{
	local FSTeamInfo Team;
	Team = spawn(class'FSGame.FSTeamInfo');

	Team.TeamIndex = TeamIndex;
	GameReplicationInfo.SetTeam(TeamIndex, Team);
	Teams[TeamIndex] = Team;
}

defaultproperties
{
	PlayerControllerClass=class'FSGame.FSPlayerController'
	DefaultPawnClass=class'FSGame.FSPawn'
	HUDType=class'FSGame.FSHUD'
	GameReplicationInfoClass=class'FSGame.FSGameReplicationInfo'
	PlayerReplicationInfoClass=class'FSGame.FSPlayerReplicationInfo'

	bTeamGame=true
	bDelayedStart=false
	bRestartLevel=false
}