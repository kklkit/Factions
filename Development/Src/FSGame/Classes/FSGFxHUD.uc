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
	ActionScriptVoid("_root.updateResolution");
}

function UpdateHealth(int Health, int HealthMax)
{
	ActionScriptVoid("_root.updateHealth");
}

function UpdateAmmo(int Ammo, int AmmoMax)
{
	ActionScriptVoid("_root.updateAmmo");
}

function UpdateMagazineCount(int MagazineCount)
{
	ActionScriptVoid("_root.updateMagazineCount");
}

function UpdateResources(int Resources)
{
	ActionScriptVoid("_root.updateResources");
}

function UpdateIsAlive(bool IsAlive)
{
	ActionScriptVoid("_root.updateIsAlive");
}

function UpdateCommStatus(string CommName, int Health, int HealthMax)
{
	ActionScriptVoid("_root.updateCommStatus");
}

function UpdateCurrentResearch(string ResearchName, int SecsLeft)
{
	ActionScriptVoid("_root.updateCurrentResearch");
}

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_hud'
	bDisplayWithHudOff=False
}
