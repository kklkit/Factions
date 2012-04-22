class FSTeamGame extends GameInfo;

var FSTeamInfo Teams[2];

function PreBeginPlay()
{
	Super.PreBeginPlay();

	CreateTeam(0);
	CreateTeam(1);
}

function CreateTeam(int TeamIndex)
{
	local FSTeamInfo Team;

	Team = spawn(class'FSGame.FSTeamInfo');
	Team.TeamIndex = TeamIndex;
	GameReplicationInfo.SetTeam(TeamIndex, Team);
	Teams[TeamIndex] = Team;
}

function bool ChangeTeam(Controller Other, int N, bool bNewTeam)
{
	Teams[N].AddToTeam(Other);
	return true;
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