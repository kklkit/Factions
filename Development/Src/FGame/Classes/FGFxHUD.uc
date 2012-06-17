/**
 * Updates the infantry and vehicle HUD.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FGFxHUD extends FGFxMoviePlayer;

/**
 * Updates the interface elements in Flash.
 */
function TickHud()
{
	local FPawn PlayerPawn;
	local FWeapon PlayerWeapon;
	local FMagazine Magazine;
	local int MagazineCount;

	// Calling functions in Flash while the movie is closed can cause a crash.
	if (!bMovieIsOpen)
		return;

	// Get the actual player pawn (infantry pawn).
	PlayerPawn = GetPlayerPawn();

	// Update each HUD element.
	if (PlayerPawn != None)
	{
		UpdateHealth(PlayerPawn.Health, PlayerPawn.HealthMax);

		PlayerWeapon = FWeapon(PlayerPawn.Weapon);

		if (PlayerWeapon != None && PlayerWeapon.Magazine != None)
			UpdateAmmo(PlayerWeapon.Magazine.AmmoCount, PlayerWeapon.Magazine.AmmoCountMax);
		else
			UpdateAmmo(0, 1);

		if (PlayerPawn.InvManager != None)
			foreach PlayerPawn.InvManager.InventoryActors(class'FMagazine', Magazine)
				if (Magazine.AmmoFor == PlayerWeapon.Name)
					MagazineCount++;

		UpdateMagazineCount(MagazineCount);

		if (GetPC().PlayerReplicationInfo != None && GetPC().PlayerReplicationInfo.Team != None)
			UpdateResources(FTeamInfo(GetPC().PlayerReplicationInfo.Team).Resources);
	}
	else
	{
		UpdateHealth(0, 1);
		UpdateAmmo(0, 1);
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

function UpdateHealth(int Health, int HealthMax)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateHealth");
}

function UpdateAmmo(int Ammo, int AmmoMax)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateAmmo");
}

function UpdateMagazineCount(int MagazineCount)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateMagazineCount");
}

function UpdateResources(int Resources)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateResources");
}

function UpdateIsAlive(bool IsAlive)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateIsAlive");
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

defaultproperties
{
	MovieInfo=SwfMovie'Factions_UI.factions_hud'
	bDisplayWithHudOff=False
}
