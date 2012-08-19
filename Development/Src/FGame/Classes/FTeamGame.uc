/**
 * Manages the gameplay for team-based games.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FTeamGame extends FGame;

var float FriendlyFireScale;
var float TeammateBoost;

const TEAM_NONE=255;

// Enumeration of all the available teams
enum ETeams
{
	TEAM_RED,
	TEAM_BLUE
};

/**
 * @extends
 */
event PreBeginPlay()
{
	local byte TeamIndex;

	Super.PreBeginPlay();

	// Create all the teams
	for (TeamIndex = 0; TeamIndex < ETeams.EnumCount; TeamIndex++)
		CreateTeam(TeamIndex);
}

/**
 * @extends
 */
event PlayerController Login(string Portal, string Options, const UniqueNetID UniqueID, out string ErrorMessage)
{
	local PlayerController PC;

	PC = Super.Login(Portal, Options, UniqueID, ErrorMessage);

	// Move the player to spectator if not on a team
	if (PC.PlayerReplicationInfo.Team == None)
	{
		PC.GotoState('Spectating');
		PC.PlayerReplicationInfo.bIsSpectator = True;
	}

	return PC;
}

/**
 * @extends
 */
event PostLogin(PlayerController NewPlayer)
{
	Super.PostLogin(NewPlayer);

	if (NewPlayer.PlayerReplicationInfo.bIsSpectator)
	{
		// Update player counts
		NumSpectators++;
		NumPlayers--;

		// Move the client to spectator state
		NewPlayer.ClientGotoState('Spectating');
	}

	NotifyTeamCountChanged();
}

/**
 * @extends
 */
function Logout(Controller Exiting)
{
	local PlayerController PC;

	PC = PlayerController(Exiting);
	if (PC != None)
	{
		if (PC.PlayerReplicationInfo.bIsSpectator)
		{
			// Update player counts
			NumSpectators--;
			NumPlayers++;
		}
	}

	NotifyTeamCountChanged();

	Super.Logout(Exiting);
}

/**
 * @extends
 */
function bool ChangeTeam(Controller Other, int N, bool bNewTeam)
{
	// Ensure given team index is valid
	if (N >= 0 && N < ETeams.EnumCount)
	{
		SetTeam(Other, GameReplicationInfo.Teams[N], bNewTeam);
		return True;
	}

	// Handle joining spectator
	if (N == TEAM_NONE)
	{
		SetTeam(Other, None, bNewTeam);
		return True;
	}

	return False;
}

/**
 * Sets the team of the given player controller.
 */
function SetTeam(Controller Other, TeamInfo NewTeam, bool bNewTeam)
{
	local GameInfo Game;
	local Actor A;

	if (Other.PlayerReplicationInfo == None)
		return;

	Game = WorldInfo.Game;

	// Remove old spawn location
	if (!ShouldSpawnAtStartSpot(Other))
		Other.StartSpot = None;

	// Remove player from their old team
	if (Other.PlayerReplicationInfo.Team != None)
	{
		Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);
		Other.PlayerReplicationInfo.Team = None;
	}

	// Handle joining spectator
	if (NewTeam == None)
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
		
		// Broadcast that the player has joined spectator
		BroadcastLocalizedMessage(GameMessageClass, 14, Other.PlayerReplicationInfo);
	}
	// Handle joining a team
	else if (NewTeam.AddToTeam(Other))
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

		// Broadcast that the player has changed team
		BroadcastLocalizedMessage(GameMessageClass, 3, Other.PlayerReplicationInfo, , NewTeam);
	}

	// Notify actors when playing in single player
	if ((PlayerController(Other) != None) && (LocalPlayer(PlayerController(Other).Player) != None))
		foreach AllActors(class'Actor', A)
			A.NotifyLocalPlayerTeamReceived();

	NotifyTeamCountChanged();
}

/**
 * @extends
 */
function byte PickTeam(byte Current, Controller C)
{
	if (C == None)
		return Current;

	// Return the team with fewer players
	return GameReplicationInfo.Teams[TEAM_RED].Size <= GameReplicationInfo.Teams[TEAM_BLUE].Size ? TEAM_RED : TEAM_BLUE;
}

/**
 * @extends
 */
function float RatePlayerStart(PlayerStart P, byte Team, Controller Player)
{
	// Return a value for the initial player spawn
	if (Player == None || (Player.PlayerReplicationInfo.Team == None && P.bPrimaryStart))
		return 1.0;

	// Return closest team spawn point
	if (UDKTeamPlayerStart(P) != None && Team == UDKTeamPlayerStart(P).TeamNumber)
	{
		if (Player.Pawn != None)
			return FMapInfo(WorldInfo.GetMapInfo()).MapLength - VSize(Player.Pawn.Location - P.Location);
		else
			return 1.0;
	}

	return -1.0;
}

/**
 * @extends
 */
function RestartPlayer(Controller NewPlayer)
{
	if (!NewPlayer.PlayerReplicationInfo.bIsSpectator)
		Super.RestartPlayer(NewPlayer);
}

/**
 * @extends
 */
function ReduceDamage(out int Damage, pawn injured, Controller instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser)
{
	local int InjuredTeam, InstigatorTeam;

	if (instigatedBy != None)
	{
		InjuredTeam = Injured.GetTeamNum();
		InstigatorTeam = instigatedBy.GetTeamNum();

		// Scale friendly fire damage
		if (instigatedBy != injured.Controller && (Injured.DrivenVehicle == None || InstigatedBy.Pawn != Injured.DrivenVehicle) &&
			InjuredTeam != TEAM_NONE && InstigatorTeam != TEAM_NONE && InjuredTeam == InstigatorTeam)
		{
			Momentum *= TeammateBoost;
			Damage *= FriendlyFireScale;
		}
	}

	Super.ReduceDamage(Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType, DamageCauser);
}

/**
 * Creates the team info for the given team index.
 */
function CreateTeam(int TeamIndex)
{
	local FTeamInfo Team;

	Team = Spawn(class'FTeamInfo');
	Team.TeamIndex = TeamIndex;

	GameReplicationInfo.SetTeam(TeamIndex, Team);
}

/**
 * Notifies all players that the team count has changed.
 */
function NotifyTeamCountChanged()
{
	local FPlayerController PC;

	foreach WorldInfo.AllControllers(class'FPlayerController', PC)
		PC.ClientNotifyTeamCountChanged();
}

/**
 * Called when a spawn point is destroyed or a player dies.
 */
function PlayerStatusChanged()
{
	local FStructure_Barracks Barracks;
	local FPawn P;
	local bool bRedTeamHasStartLocation, bBlueTeamHasStartLocation, bRedTeamHasAlivePlayer, bBlueTeamHasAlivePlayer;

	foreach AllActors(class'FStructure_Barracks', Barracks)
	{
		if (Barracks.Health > 0)
		{
			if (Barracks.GetTeamNum() == TEAM_RED)
			{
				bRedTeamHasStartLocation = True;
			}
			else if (Barracks.GetTeamNum() == TEAM_BLUE)
			{
				bBlueTeamHasStartLocation = True;
			}
		}
	}

	foreach AllActors(class'FPawn', P)
	{
		if (P.IsAliveAndWell())
		{
			if (P.GetTeamNum() == TEAM_RED)
			{
				bRedTeamHasAlivePlayer = True;
			}
			else if (P.GetTeamNum() == TEAM_BLUE)
			{
				bBlueTeamHasAlivePlayer = True;
			}
		}
	}

	if ((!bRedTeamHasStartLocation && !bRedTeamHasAlivePlayer) || (!bBlueTeamHasStartLocation && bBlueTeamHasAlivePlayer))
	{
		EndGame(None, "NoAlivePlayers");
	}
}

/**
 * Sets the friendly fire scale.
 */
exec function SetFriendlyFireScale(float Scale)
{
	FriendlyFireScale = Scale;
}

defaultproperties
{
	bTeamGame=True
	FriendlyFireScale=1.0
	TeammateBoost=1.0
}