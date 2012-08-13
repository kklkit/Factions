/**
 * Handles updating the game info HUD (resources, commander, etc.)
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FGFxMainHUD extends FGFxMoviePlayer;

/**
 * @extends
 */
function Init(optional LocalPlayer LocPlay)
{
	Super.Init(LocPlay);

	SetPriority(30);
}

/**
 * Updates the interface elements in Flash.
 */
function TickHud()
{
	local FPawn PlayerPawn;
	local FTeamInfo PlayerTeam;

	// Calling functions in Flash while the movie is closed can cause a crash.
	if (!bMovieIsOpen)
		return;

	UpdateRoundTimer(GetPC().WorldInfo.GRI.ElapsedTime);

	// Get the actual player pawn (infantry pawn).
	PlayerPawn = GetPlayerPawn();

	// Update each HUD element.
	if (PlayerPawn != None)
	{
		PlayerTeam = FTeamInfo(PlayerPawn.GetTeam());

		if (PlayerTeam != None)
		{
			UpdateResources(PlayerTeam.Resources);

			if (PlayerTeam.Commander != None)
			{
				if (PlayerTeam.Commander.PlayerReplicationInfo != None)
					UpdateCommStatus(PlayerTeam.Commander.PlayerReplicationInfo.GetHumanReadableName(), PlayerTeam.Commander.Health, PlayerTeam.Commander.HealthMax);
				else
					UpdateCommStatus("", PlayerTeam.Commander.Health, PlayerTeam.Commander.HealthMax);
			}
		}
	}
}

/*********************************************************************************************
 Functions called from ActionScript
**********************************************************************************************/

/**
 * Calls the update resolution function with the current screen size.
 */
function ResizeHUD()
{
	local float x0, y0, x1, y1;

	GetVisibleFrameRect(x0, y0, x1, y1);

	UpdateResolution(x0, y0, x1, y1);
}

/*********************************************************************************************
 Functions calling ActionScript
 
 These functions simply forwards the call with its parameters to Flash.
 
 Always check to make sure the movie is open before calling Flash. The game will crash if a
 function is called while the movie is closed.
**********************************************************************************************/

function UpdateResolution(float x0, float y0, float x1, float y1)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateResolution");
}

function UpdateCommStatus(string CommName, int Health, int HealthMax)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateCommStatus");
}

function UpdateCurrentResearch(string ResearchName, int SecsLeft)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateCurrentResearch");
}

function UpdateResources(int Resources)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateResources");
}

function UpdateRoundTimer(int SecsElapsed)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateRoundTimer");
}

defaultproperties
{
	MovieInfo=SwfMovie'Factions_UI.factions_main_hud'
	bDisplayWithHudOff=False
	bAllowFocus=False
	bAllowInput=False
}
