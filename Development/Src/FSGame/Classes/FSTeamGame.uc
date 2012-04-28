/**
 * Base class for Factions game modes.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSTeamGame extends UDKGame
	config(GameFS);

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
 * Override.
 * 
 * @extends
 */
function bool ShouldRespawn(PickupFactory Other)
{
	return true;
}

/**
 * @extends
 */
function bool ChangeTeam(Controller Other, int N, bool bNewTeam)
{
	super.ChangeTeam(Other, N, bNewTeam);

	if (N >= 0 && N < NumTeams)
	{
		SetTeam(Other, Teams[N], bNewTeam);
		return true;
	}
	else
		return false;
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
 * @extends
 */
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
	{
		return VSize(Player.Pawn.Location - P.Location);
	}

	return Super.RatePlayerStart(P, Team, Player);
}

/**
 * Sets the controller's team to the given team index.
 */
function SetTeam(Controller Other, FSTeamInfo NewTeam, bool bNewTeam)
{
	local Actor A;

	if (Other.PlayerReplicationInfo == None)
		return;

	// Clear old spawn point
	if (Other.PlayerReplicationInfo.Team != None || !ShouldSpawnAtStartSpot(Other))
		Other.StartSpot = None;

	// Remove controller from old team
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
		{
			A.NotifyLocalPlayerTeamReceived();
		}
	}
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

reliable server function PlaceStructure(Vector StructureLocation)
{
	Spawn(class'FSVehiclePad', , , StructureLocation, , , );
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