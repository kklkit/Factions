/**
 * The objective of the game is to destroy the enemy command vehicle while protecting your own.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FCommanderGame extends FTeamGame;

/**
 * @extends
 */
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	if (CheckModifiedEndGame(Winner, Reason))
		return False;

	SetEndGameFocus(Winner);
	return True;
}

/**
 * Calls GameHasEnded on all controllers with the end game focus.
 */
function SetEndGameFocus(PlayerReplicationInfo Winner)
{
	local Controller P;
	local Actor EndGameFocus;

	if (Winner != None)
		EndGameFocus = Controller(Winner.Owner).Pawn;

	if (EndGameFocus != None)
		EndGameFocus.bAlwaysRelevant = True;

	foreach WorldInfo.AllControllers(class'Controller', P)
	{
		P.GameHasEnded(EndGameFocus, (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == GameReplicationInfo.Winner));
	}
}

/**
 * Called when a command vehicle is destroyed.
 */
function CommandVehicleDestroyed(Controller Killer)
{
	EndGame(Killer.PlayerReplicationInfo, "CommandVehicleDestroyed");
}

defaultproperties
{
}
