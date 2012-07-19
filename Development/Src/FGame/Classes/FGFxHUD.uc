/**
 * Updates the infantry and vehicle HUD.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FGFxHUD extends FGFxMoviePlayer;

/**
 * Add Enter key to ignore list to avoid being captured as a chat input
 */
function Init(optional LocalPlayer player)
{
	Super.Init(player);
	AddFocusIgnoreKey('Enter');
}

/**
 * Updates the interface elements in Flash.
 */
function TickHud()
{
	local FPawn PlayerPawn;
	local FVehicle PlayerVehicle;
	local FWeapon PlayerWeapon;
	local FMagazine Magazine;
	local FTeamInfo PlayerTeam;
	local int MagazineCount;

	// Calling functions in Flash while the movie is closed can cause a crash.
	if (!bMovieIsOpen)
		return;

	UpdateRoundTimer(GetPC().WorldInfo.GRI.ElapsedTime);

	// Get the actual player pawn (infantry pawn).
	PlayerPawn = GetPlayerPawn();

	// Update each HUD element.
	if (PlayerPawn != None)
	{
		UpdateHealth(PlayerPawn.Health, PlayerPawn.HealthMax);

		PlayerWeapon = FWeapon(PlayerPawn.Weapon);

		if (PlayerWeapon != None)
			UpdateAmmo(PlayerWeapon.AmmoCount, PlayerWeapon.MaxAmmoCount);
		else
			UpdateAmmo(0, 1);

		if (PlayerPawn.InvManager != None)
			foreach PlayerPawn.InvManager.InventoryActors(class'FMagazine', Magazine)
				if (Magazine.AmmoFor == PlayerWeapon.Name)
					MagazineCount++;

		UpdateMagazineCount(MagazineCount);

		if (FVehicle(GetPC().Pawn) != None)
		{
			ShowVehicleHUD(True);
			PlayerVehicle = FVehicle(GetPC().Pawn);
			UpdateVehicleHealth(PlayerVehicle.Health, PlayerVehicle.HealthMax);
			UpdateVehicleRotation(-(PlayerVehicle.TurretRotations[0].Yaw * UnrRotToDeg));
		}
		else
		{
			ShowVehicleHUD(False);
		}

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

function EndChatting()
{
	StopUsingChatInputBox();
	bCaptureInput = false;
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

function ShowVehicleHUD(bool ShowHUD)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.showVehicleHUD");
}

function UpdateVehicleHealth(int Health, int HealthMax)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateVehicleHealth");
}

function UpdateVehicleRotation(int Rotation)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateVehicleRotation");
}

function UpdateRoundTimer(int SecsElapsed)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateRoundTimer");
}

function StartUsingChatInputBox()
{
	if (bMovieIsOpen)
	{
		bCaptureInput = true;		
		ActionScriptVoid("_root.focusChatInputBox");
	}	
}

function StopUsingChatInputBox()
{
	bCaptureInput = false;		
	FocusChatLogBox();
}

function String GetChatInputBoxText()
{
	if (bMovieIsOpen)
		return ActionScriptString("_root.getChatInputBoxText");
	else
		return "ERROR: GFxMoviePlayer is not initialized";

}

function SetChatLogBoxText(String setText)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.setChatInputBoxText");
}

function FocusChatLogBox()
{
	if (bMovieIsOpen)
	{
		ActionScriptVoid("_root.focusChatLogBox");
	}

}

function ChatLogBoxAddNewChatLine(String chatLine, int preferedColor)
{
	if (bMovieIsOpen)
	{
		ActionScriptVoid("_root.addNewChatLine");
	}
}

defaultproperties
{
	MovieInfo=SwfMovie'Factions_UI.factions_hud'
	bDisplayWithHudOff=False
}
