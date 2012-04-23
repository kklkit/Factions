class FSTeamGame extends GameInfo;

const NumTeams=2;

var FSTeamInfo Teams[NumTeams];

/**
 * Sets up the game environment.
 * 
 * @extends
 */
function PreBeginPlay()
{
	local int i;

	Super.PreBeginPlay();

	if (WorldInfo.GetMapInfo() == none)
		WorldInfo.SetMapInfo(new class'FSGame.FSMapInfo');

	for (i = 0; i < NumTeams; i++)
		CreateTeam(i);
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

/**
 * Returns the team index with the fewest players.
 * 
 * @extends
 * 
 * @return team index
 */
function byte PickTeam(byte Current, Controller C)
{
	super.PickTeam(Current, C);

	//@todo make this work for more than 2 teams
	if (Teams[0].Size <= Teams[1].Size)
		return 0;
	else
		return 1;
}

/**
 * Places the controller on the given team if valid.
 * 
 * @extends
 * 
 * @return if the player changed team
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