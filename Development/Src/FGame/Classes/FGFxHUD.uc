/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FGFxHUD extends FGFxMoviePlayer;

function TickHud()
{
	local FPawn PlayerPawn;
	local FWeapon PlayerWeapon;
	local FMagazine Magazine;
	local int MagazineCount;

	if (!bMovieIsOpen)
		return;

	PlayerPawn = GetPlayerPawn();

	if (PlayerPawn != None)
	{
		UpdateHealth(PlayerPawn.Health, PlayerPawn.HealthMax);

		if (PlayerPawn.PlayerReplicationInfo != None && PlayerPawn.PlayerReplicationInfo.Team != None)
			UpdateResources(FTeamInfo(PlayerPawn.PlayerReplicationInfo.Team).Resources);

		PlayerWeapon = FWeapon(PlayerPawn.Weapon);
		if (PlayerWeapon != None && PlayerWeapon.Magazine != None)
			UpdateAmmo(PlayerWeapon.AmmoCount, PlayerWeapon.Magazine.AmmoCountMax);
		else
			UpdateAmmo(0, 1);

		if (PlayerPawn.InvManager != None)
			foreach PlayerPawn.InvManager.InventoryActors(class'FMagazine', Magazine)
				if (Magazine.AmmoFor == PlayerWeapon.Name)
					MagazineCount++;

		UpdateMagazineCount(MagazineCount);
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

function ResizeHUD()
{
	local float x0, y0, x1, y1;

	GetVisibleFrameRect(x0, y0, x1, y1);

	UpdateResolution(x0, y0, x1, y1);
}

/*********************************************************************************************
 Functions calling ActionScript
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
