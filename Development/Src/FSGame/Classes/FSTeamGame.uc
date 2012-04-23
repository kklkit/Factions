class FSTeamGame extends GameInfo;

const NumTeams=2;

var FSTeamInfo Teams[NumTeams];

function PreBeginPlay()
{
	local int i;

	Super.PreBeginPlay();

	for (i = 0; i < NumTeams; i++)
		CreateTeam(i);

	if (WorldInfo.GetMapInfo() == none)
		WorldInfo.SetMapInfo(new class'FSGame.FSMapInfo');
}

function CreateTeam(int TeamIndex)
{
	local FSTeamInfo Team;
	Team = spawn(class'FSGame.FSTeamInfo');

	Team.TeamIndex = TeamIndex;
	GameReplicationInfo.SetTeam(TeamIndex, Team);
	Teams[TeamIndex] = Team;
}

function byte PickTeam(byte Current, Controller C)
{
	super.PickTeam(Current, C);

	if (Teams[0].Size <= Teams[1].Size)
		return 0;
	else
		return 1;
}

function bool ChangeTeam(Controller Other, int N, bool bNewTeam)
{
	local bool bChangedTeam;
	local PlayerController PC;

	super.ChangeTeam(Other, N, bNewTeam);

	PC = PlayerController(Other);

	if (N >= 0 && N < NumTeams)
	{
		Teams[N].AddToTeam(Other);
		bChangedTeam = true;
	}
	else
		bChangedTeam = false;

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