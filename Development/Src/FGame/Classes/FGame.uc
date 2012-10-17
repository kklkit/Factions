/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FGame extends UDKGame
	config(Server);

var float EndTime;
var globalconfig float EndTimeDelay;
var globalconfig int RestartWait;

/**
 * @extends
 */
event PreBeginPlay()
{
	Super.PreBeginPlay();

	// Set the map info if none exists
	if (WorldInfo.GetMapInfo() == None)
	{
		`log("Factions: MapInfo not set!");
		WorldInfo.SetMapInfo(new class'FMapInfo');
	}
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
function EndGame(PlayerReplicationInfo Winner, string Reason)
{
	Super.EndGame(Winner, Reason);

	if (bGameEnded)
	{
		GotoState('MatchOver');
	}
}

/**
 * @extends
 */
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	if (CheckModifiedEndGame(Winner, Reason))
		return False;

	EndTime = WorldInfo.TimeSeconds + EndTimeDelay;
	GameReplicationInfo.Winner = Winner;

	SetEndGameFocus(Winner);
	return True;
}

/**
 * Calls GameHasEnded on all controllers with the end game focus.
 */
function SetEndGameFocus(PlayerReplicationInfo Winner)
{
	local Controller P;

	foreach WorldInfo.AllControllers(class'Controller', P)
	{
		P.GameHasEnded();
	}
}

/**
 * @extends
 */
function string GetNextMap()
{
	return "TestMap";
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

state MatchOver
{
	function RestartPlayer(Controller aPlayer);
	function ScoreKill(Controller Killer, Controller Other);

	/**
	 * @extends
	 */
	function BeginState(Name PreviousStateName)
	{
		Global.BeginState(PreviousStateName);

		GameReplicationInfo.bStopCountDown = true;
	}

	/**
	 * @extends
	 */
	function Timer()
	{
		Global.Timer();

		if (!bGameRestarted && (WorldInfo.TimeSeconds > EndTime + RestartWait))
		{
			RestartGame();
		}
	}
}

defaultproperties
{
	PlayerControllerClass=class'FPlayerController'
	DefaultPawnClass=class'FPawn'
	HUDType=class'FHUD'
	GameReplicationInfoClass=class'FGameReplicationInfo'
	PlayerReplicationInfoClass=class'FPlayerReplicationInfo'

	bDelayedStart=False
	bRestartLevel=False
	bPauseable=False
}
