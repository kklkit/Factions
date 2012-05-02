/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSTeamGame extends UDKGame
	config(GameFS);

const NumTeams=2;

var FSTeamInfo Teams[NumTeams];

function PreBeginPlay()
{
	local byte i;

	Super.PreBeginPlay();

	if (WorldInfo.GetMapInfo() == None)
	{
		`log("MAPINFO NOT SET!!!");
		WorldInfo.SetMapInfo(new class'FSMapInfo');
	}

	for (i = 0; i < NumTeams; i++)
		CreateTeam(i);
}

function PlayerController Login(string Portal, string Options, const UniqueNetId UniqueId, out string ErrorMessage)
{
	Options $= "?SpectatorOnly=1"; //@todo only set spectator if new player

	return Super.Login(Portal, Options, UniqueId, ErrorMessage);
}

function bool ShouldRespawn(PickupFactory Other)
{
	return true;
}

function bool ChangeTeam(Controller Other, int N, bool bNewTeam)
{
	if (N >= 0 && N < NumTeams)
	{
		SetTeam(Other, Teams[N], bNewTeam);
		return true;
	}
	else
		return false;
}

function byte PickTeam(byte Current, Controller C)
{
	if (Teams[0].Size <= Teams[1].Size)
		return 0;
	else
		return 1;
}

function float RatePlayerStart(PlayerStart P, byte Team, Controller Player)
{
	if (FSTeamPlayerStart(P) == None)
	{
		`warn(P$" is not a team playerstart!");
		return -9;
	}

	if (Team != FSTeamPlayerStart(P).TeamNumber)
		return -9;

	if (Player != None && Player.Pawn != None)
		return (FSMapInfo(WorldInfo.GetMapInfo()).MapRadius * 2) - VSize(Player.Pawn.Location - P.Location);

	return Super.RatePlayerStart(P, Team, Player);
}

function SetTeam(Controller Other, FSTeamInfo NewTeam, bool bNewTeam)
{
	local Actor A;

	if (Other.PlayerReplicationInfo == None)
		return;

	if (Other.PlayerReplicationInfo.Team != None || !ShouldSpawnAtStartSpot(Other))
		Other.StartSpot = None;

	if (Other.PlayerReplicationInfo.Team != None)
	{
		Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);
		Other.PlayerReplicationInfo.Team = None;
	}
	
	if (NewTeam == None || (NewTeam != None && NewTeam.AddToTeam(Other)))
	{
		if ((NewTeam != None) && ((WorldInfo.NetMode != NM_Standalone) || (PlayerController(Other) == None) || (PlayerController(Other).Player != None)))
			BroadcastLocalizedMessage(GameMessageClass, 3, Other.PlayerReplicationInfo, None, NewTeam);
	}

	if ((PlayerController(Other) != None) && (LocalPlayer(PlayerController(Other).Player) != None))
	{
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
	Teams[TeamIndex] = Team;
}

//@todo move this somewhere else - dedicated bug
reliable server function PlaceStructure(byte StructureIndex, Vector StructureLocation)
{
	Spawn(class'FSStructure'.static.GetStructureClass(StructureIndex), , , StructureLocation, , , );
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