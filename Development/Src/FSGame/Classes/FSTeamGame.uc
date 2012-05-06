/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSTeamGame extends UDKGame
	config(GameFS);

enum ETeams
{
	TEAM_SPECTATOR,
	TEAM_RED,
	TEAM_BLUE
};

function PreBeginPlay()
{
	local byte i;

	Super.PreBeginPlay();

	if (WorldInfo.GetMapInfo() == None)
	{
		`log("Factions: MapInfo not set!");
		WorldInfo.SetMapInfo(new class'FSMapInfo');
	}

	for (i = 0; i < ETeams.EnumCount; ++i)
		CreateTeam(i);
}

function bool ChangeTeam(Controller Other, int N, bool bNewTeam)
{
	// Ensure team number is valid
	if (N >= 0 && N < ETeams.EnumCount)
	{
		SetTeam(Other, GameReplicationInfo.Teams[N], bNewTeam);
		return true;
	}
	else
		return false;
}

function byte PickTeam(byte Current, Controller C)
{
	// Return the team with fewer players
	return GameReplicationInfo.Teams[TEAM_RED].Size <= GameReplicationInfo.Teams[TEAM_BLUE].Size ? TEAM_RED : TEAM_BLUE;
}

function float RatePlayerStart(PlayerStart P, byte Team, Controller Player)
{
	// Use only team spawn points
	if (UDKTeamPlayerStart(P) != None && Team == UDKTeamPlayerStart(P).TeamNumber)
		return (FSMapInfo(WorldInfo.GetMapInfo()).MapRadius * 2) - VSize(Player.Pawn.Location - P.Location);

	return -1.f;
}

function SetTeam(Controller Other, TeamInfo NewTeam, bool bNewTeam)
{
	local Actor A;

	if (Other.PlayerReplicationInfo == None)
		return;

	if (Other.PlayerReplicationInfo.Team != None)
	{
		if (!ShouldSpawnAtStartSpot(Other))
			Other.StartSpot = None;

		Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);
		Other.PlayerReplicationInfo.Team = None;
	}
	
	if (NewTeam != None && NewTeam.AddToTeam(Other))
	{
		BroadcastLocalizedMessage(GameMessageClass, 3, Other.PlayerReplicationInfo, None, NewTeam);

		if ((PlayerController(Other) != None) && (LocalPlayer(PlayerController(Other).Player) != None))
			foreach AllActors(class'Actor', A)
				A.NotifyLocalPlayerTeamReceived();
	}
}

function CreateTeam(int TeamIndex)
{
	local FSTeamInfo Team;

	Team = Spawn(class'FSTeamInfo');
	Team.TeamIndex = TeamIndex;

	GameReplicationInfo.SetTeam(TeamIndex, Team);
}

defaultproperties
{
	PlayerControllerClass=class'FSPlayerController'
	DefaultPawnClass=class'FSPawn'
	HUDType=class'FSHUD'
	GameReplicationInfoClass=class'FSGameReplicationInfo'
	PlayerReplicationInfoClass=class'FSPlayerReplicationInfo'

	bTeamGame=true
	bDelayedStart=false
	bRestartLevel=false
}