class EmpTeamGame extends GameInfo;

var EmpTeamInfo Teams[2];

function PreBeginPlay()
{
	Super.PreBeginPlay();

	Teams[0] = spawn(class'EmpGame.EmpTeamInfo');
	GameReplicationInfo.SetTeam(0, Teams[0]);

	Teams[1] = spawn(class'EmpGame.EmpTeamInfo');
	GameReplicationInfo.SetTeam(1, Teams[1]);
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