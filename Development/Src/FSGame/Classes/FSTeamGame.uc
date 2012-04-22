class FSTeamGame extends GameInfo;

var FSTeamInfo Teams[2];

function PreBeginPlay()
{
	Super.PreBeginPlay();

	Teams[0] = spawn(class'FSGame.FSTeamInfo');
	Teams[0].TeamIndex = 1;
	GameReplicationInfo.SetTeam(0, Teams[0]);

	Teams[1] = spawn(class'FSGame.FSTeamInfo');
	Teams[1].TeamIndex = 2;
	GameReplicationInfo.SetTeam(1, Teams[1]);
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