/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSGFxHUD extends FSGFxMoviePlayer;

function TickHud()
{
	local FSPawn FSP;
	local FSWeapon FSW;
	local FSMagazine Magazine;
	local int MagazineCount;

	if (!bMovieIsOpen)
		return;

	FSP = GetPlayerPawn();

	if (FSP != None)
	{
		UpdateHealth(FSP.Health, FSP.HealthMax);

		if (FSP.PlayerReplicationInfo != None && FSP.PlayerReplicationInfo.Team != None)
			UpdateResources(FSTeamInfo(FSP.PlayerReplicationInfo.Team).Resources);

		FSW = FSWeapon(FSP.Weapon);
		if (FSW != None && FSW.Magazine != None)
			UpdateAmmo(FSW.AmmoCount, FSW.Magazine.AmmoCountMax);
		else
			UpdateAmmo(0, 1);

		if (GetPC().Pawn.InvManager != None)
			foreach GetPC().Pawn.InvManager.InventoryActors(class'FSMagazine', Magazine)
				if (Magazine.AmmoType == FSW.AmmoType)
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
	MovieInfo=SwfMovie'FSFlashAssets.factions_hud'
	bDisplayWithHudOff=False
}
