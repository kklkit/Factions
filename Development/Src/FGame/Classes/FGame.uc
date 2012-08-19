/**
 * Manages the gameplay.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FGame extends UDKGame;

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
