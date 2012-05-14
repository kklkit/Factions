/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSTeamGame extends UDKGame
	config(GameFS);

const PSEUDO_TEAM_SPECTATOR=255;

enum ETeams
{
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

	for (i = 0; i < ETeams.EnumCount; i++)
		CreateTeam(i);
}

function PlayerController Login(string Portal, string Options, const UniqueNetID UniqueID, out string ErrorMessage)
{
	local PlayerController PC;

	PC = Super.Login(Portal, Options, UniqueID, ErrorMessage);

	if (PC.PlayerReplicationInfo.Team == None)
	{
		PC.GotoState('Spectating');
		PC.PlayerReplicationInfo.bIsSpectator = True;
	}

	return PC;
}

function PostLogin(PlayerController NewPlayer)
{
	Super.PostLogin(NewPlayer);

	if (NewPlayer.PlayerReplicationInfo.bIsSpectator)
	{
		NumSpectators++;
		NumPlayers--;
		NewPlayer.ClientGotoState('Spectating');
	}
}

function Logout(Controller Exiting)
{
	local PlayerController PC;

	PC = PlayerController(Exiting);
	if (PC != None)
	{
		if (PC.PlayerReplicationInfo.bIsSpectator)
		{
			NumSpectators--;
			NumPlayers++;
		}
	}

	Super.Logout(Exiting);
}

function bool ChangeTeam(Controller Other, int N, bool bNewTeam)
{
	if (N >= 0 && N < ETeams.EnumCount)
	{
		SetTeam(Other, GameReplicationInfo.Teams[N], bNewTeam);
		return True;
	}

	if (N == PSEUDO_TEAM_SPECTATOR)
	{
		SetTeam(Other, None, bNewTeam);
		return True;
	}

	return False;
}

function SetTeam(Controller Other, TeamInfo NewTeam, bool bNewTeam)
{
	local GameInfo Game;
	local Actor A;

	if (Other.PlayerReplicationInfo == None)
		return;

	Game = WorldInfo.Game;

	// Remove player from their old team
	if (Other.PlayerReplicationInfo.Team != None)
	{
		if (!ShouldSpawnAtStartSpot(Other))
			Other.StartSpot = None;

		Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);
		Other.PlayerReplicationInfo.Team = None;
	}

	if (NewTeam == None) // Becoming spectator
	{
		if (!Other.PlayerReplicationInfo.bIsSpectator)
		{
			Other.PlayerReplicationInfo.bIsSpectator = True;
			Game.NumSpectators++;
			Game.NumPlayers--;
			Other.GotoState('Spectating');
			if (PlayerController(Other) != None)
				PlayerController(Other).ClientGotoState('Spectating');
		}
		
		BroadcastLocalizedMessage(GameMessageClass, 14, Other.PlayerReplicationInfo);
	}
	else if (NewTeam.AddToTeam(Other)) // Joining a team
	{
		if (Other.PlayerReplicationInfo.bIsSpectator)
		{
			Other.PlayerReplicationInfo.bIsSpectator = False;
			Game.NumSpectators--;
			Game.NumPlayers++;

			if (!Game.bDelayedStart)
			{
				Game.bRestartLevel = False;
				if (Game.bWaitingToStartMatch)
					Game.StartMatch();
				else
					Game.RestartPlayer(Other);
				Game.bRestartLevel = Game.Default.bRestartLevel;
			}
			else
			{
				Other.GotoState('PlayerWaiting');
				if (PlayerController(Other) != None)
					PlayerController(Other).ClientGotoState('PlayerWaiting');
			}
		}

		BroadcastLocalizedMessage(GameMessageClass, 3, Other.PlayerReplicationInfo, , NewTeam);
	}

	if ((PlayerController(Other) != None) && (LocalPlayer(PlayerController(Other).Player) != None))
		foreach AllActors(class'Actor', A)
			A.NotifyLocalPlayerTeamReceived();
}

function byte PickTeam(byte Current, Controller C)
{
	if (C == None)
		return Current;

	// Return the team with fewer players
	return GameReplicationInfo.Teams[TEAM_RED].Size <= GameReplicationInfo.Teams[TEAM_BLUE].Size ? TEAM_RED : TEAM_BLUE;
}

function float RatePlayerStart(PlayerStart P, byte Team, Controller Player)
{
	if (Player == None || (Player.PlayerReplicationInfo.Team == None && P.bPrimaryStart))
		return 1.f;

	if (UDKTeamPlayerStart(P) != None && Team == UDKTeamPlayerStart(P).TeamNumber)
	{
		if (Player.Pawn != None)
			return (FSMapInfo(WorldInfo.GetMapInfo()).MapRadius * 2) - VSize(Player.Pawn.Location - P.Location);
		else
			return 1.f;
	}

	return -1.f;
}

function RestartPlayer(Controller NewPlayer)
{
	if (!NewPlayer.PlayerReplicationInfo.bIsSpectator)
		Super.RestartPlayer(NewPlayer);
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

	bTeamGame=True
	bDelayedStart=False
	bRestartLevel=False
}