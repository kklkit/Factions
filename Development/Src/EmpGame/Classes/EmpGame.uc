class EmpGame extends UDKGame;

var EmpTeamInfo Teams[2];

function PreBeginPlay()
{
	Super.PreBeginPlay();

	Teams[0] = spawn(class'EmpGame.EmpTeamInfo');
	Teams[1] = spawn(class'EmpGame.EmpTeamInfo');
}

defaultproperties
{
	PlayerControllerClass=class'EmpGame.EmpPlayerController'
	DefaultPawnClass=class'EmpGame.EmpPawn'
	HUDType=class'EmpGame.EmpHUD'
	GameReplicationInfoClass=class'EmpGame.EmpGameReplicationInfo'

	bTeamGame=true
}