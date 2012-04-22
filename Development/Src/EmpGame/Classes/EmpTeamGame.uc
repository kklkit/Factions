class EmpTeamGame extends GameInfo;

var EmpTeamInfo Teams[2];

function PreBeginPlay()
{
	Super.PreBeginPlay();

	Teams[0] = spawn(class'EmpGame.EmpTeamInfo');
	Teams[0].TeamIndex = 1;
	GameReplicationInfo.SetTeam(0, Teams[0]);

	Teams[1] = spawn(class'EmpGame.EmpTeamInfo');
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
	PlayerControllerClass=class'EmpGame.EmpPlayerController'
	DefaultPawnClass=class'EmpGame.EmpPawn'
	HUDType=class'EmpGame.EmpHUD'
	GameReplicationInfoClass=class'EmpGame.EmpGameReplicationInfo'
	PlayerReplicationInfoClass=class'EmpGame.EmpPlayerReplicationInfo'

	bTeamGame=true
	bDelayedStart=false
	bRestartLevel=false
}