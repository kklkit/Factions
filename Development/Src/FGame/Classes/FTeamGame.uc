/**
 * Manages the gameplay.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FTeamGame extends UDKGame;

const TEAM_NONE=255;

// Enumeration of all the available teams
enum ETeams
{
	TEAM_RED,
	TEAM_BLUE
};

var float FriendlyFireScale;
var float TeammateBoost;

/**
 * @extends
 */
event PreBeginPlay()
{
	local byte TeamIndex;

	Super.PreBeginPlay();

	// Set the map info if none exists
	if (WorldInfo.GetMapInfo() == None)
	{
		`log("Factions: MapInfo not set!");
		WorldInfo.SetMapInfo(new class'FMapInfo');
	}

	// Create all the teams
	for (TeamIndex = 0; TeamIndex < ETeams.EnumCount; TeamIndex++)
		CreateTeam(TeamIndex);
}

/**
 * @extends
 */
function StartMatch()
{
	Super.StartMatch();

	GotoState('MatchInProgress');
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

	// Remove player from their old team
	if (Other.PlayerReplicationInfo.Team != None)
	{
		if (!ShouldSpawnAtStartSpot(Other))
			Other.StartSpot = None;

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
 * @extends
 */
function DriverEnteredVehicle(Vehicle Vehicle, Pawn Pawn)
{
	local FPlayerController PlayerController;

	Super.DriverEnteredVehicle(Vehicle, Pawn);

	// Update the view target for spectators
	foreach WorldInfo.AllControllers(class'FPlayerController', PlayerController)
		if (PlayerController.ViewTarget == Pawn)
			PlayerController.SetViewTarget(Vehicle);
}

/**
 * @extends
 */
function DriverLeftVehicle(Vehicle Vehicle, Pawn Pawn)
{
	local FPlayerController PlayerController;

	Super.DriverLeftVehicle(Vehicle, Pawn);

	// Update the view target for spectators
	foreach WorldInfo.AllControllers(class'FPlayerController', PlayerController)
		if (PlayerController.ViewTarget == Vehicle)
			PlayerController.SetViewTarget(Pawn);
}

/**
 * @extends
 */
function ReduceDamage(out int Damage, pawn injured, Controller instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser)
{
	local int InjuredTeam, InstigatorTeam;

	InjuredTeam = Injured.GetTeamNum();
	InstigatorTeam = instigatedBy.GetTeamNum();

	// Scale friendly fire damage
	if (instigatedBy != None && instigatedBy != injured.Controller && (Injured.DrivenVehicle == None || InstigatedBy.Pawn != Injured.DrivenVehicle) &&
		InjuredTeam != TEAM_NONE && InstigatorTeam != TEAM_NONE && InjuredTeam == InstigatorTeam)
	{
		Momentum *= TeammateBoost;
		Damage *= FriendlyFireScale;
	}

	Super.ReduceDamage(Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType, DamageCauser);
}

/**
 * Sets the friendly fire scale.
 */
exec function SetFriendlyFireScale(float Scale)
{
	FriendlyFireScale = Scale;
}

state MatchInProgress
{
	/**
	 * @extends
	 */
	function bool MatchIsInProgress()
	{
		return True;
	}
}

defaultproperties
{
	PlayerControllerClass=class'FPlayerController'
	DefaultPawnClass=class'FPawn'
	HUDType=class'FHUD'
	GameReplicationInfoClass=class'FGameReplicationInfo'
	PlayerReplicationInfoClass=class'FPlayerReplicationInfo'

	bTeamGame=True
	bDelayedStart=False
	bRestartLevel=False
}