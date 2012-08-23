/**
 * Updates the infantry and vehicle HUD.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FGFxHUD extends FGFxMoviePlayer;

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
	local FVehicle PlayerVehicle;
	local FWeapon PlayerWeapon;
	local FMagazine Magazine;
	local int MagazineCount;
	local int TargetHealth, TargetHealthMax;

	// Calling functions in Flash while the movie is closed can cause a crash.
	if (!bMovieIsOpen)
		return;

	// Update each HUD element.
	if (FPlayerController(GetPC()).GetTargetStatus(TargetHealth, TargetHealthMax))
	{
		UpdateTargetHealth(TargetHealth, TargetHealthMax);
		ShowTargetHealth(True);
	}
	else
	{
		ShowTargetHealth(False);
	}

	// Get the actual player pawn (infantry pawn).
	PlayerPawn = GetPlayerPawn();

	if (PlayerPawn != None)
	{
		UpdateHealth(PlayerPawn.Health, PlayerPawn.HealthMax);

		UpdateStamina(PlayerPawn.Stamina, PlayerPawn.StaminaMax);

		PlayerWeapon = FWeapon(PlayerPawn.Weapon);

		if (FVehicle(GetPC().Pawn) != None)
		{
			PlayerVehicle = FVehicle(GetPC().Pawn);
			UpdateVehicleWeaponNames(PlayerVehicle);
		}
		else
		{
			UpdateInfantryWeaponNames(PlayerPawn);
		}

		if (PlayerWeapon != None)
			UpdateAmmo(PlayerWeapon.AmmoCount, PlayerWeapon.MaxAmmoCount);
		else
			UpdateAmmo(0, 1);

		if (PlayerPawn.InvManager != None)
			foreach PlayerPawn.InvManager.InventoryActors(class'FMagazine', Magazine)
				if (Magazine.AmmoFor == PlayerWeapon.GetHumanReadableName())
					MagazineCount++;

		UpdateMagazineCount(MagazineCount);

		if (PlayerVehicle != None)
		{
			ShowVehicleHUD(True);
			UpdateVehicleHealth(PlayerVehicle.Health, PlayerVehicle.HealthMax);
			UpdateVehicleRotation(-(PlayerVehicle.TurretRotations[0].Yaw * UnrRotToDeg));
		}
		else
		{
			ShowVehicleHUD(False);
		}
	}
	else
	{
		UpdateHealth(0, 1);
		UpdateAmmo(0, 1);
	}
}

function UpdateVehicleWeaponNames(FVehicle PlayerVehicle)
{
	if (PlayerVehicle.VehicleWeapons[0] != None)
		UpdateWeaponName(0, PlayerVehicle.VehicleWeapons[0].ItemName, True);
	else
		UpdateWeaponName(0, "");

	if (PlayerVehicle.VehicleWeapons[1] != None)
		UpdateWeaponName(1, PlayerVehicle.VehicleWeapons[1].ItemName, True);
	else
		UpdateWeaponName(1, "");

	UpdateWeaponName(2, "");
	UpdateWeaponName(3, "");
}

function UpdateInfantryWeaponNames(Pawn PlayerPawn)
{
	local int i;
	local FPlayerController PC;
	local FWeapon WeaponArchetype;

	PC = FPlayerController(GetPC());

	for (i = 0; i < class'FPlayerController'.const.MaxLoadoutSlots; i++)
	{
		WeaponArchetype = PC.CurrentWeaponArchetypes[i];

		if (WeaponArchetype != None)
		{
			UpdateWeaponName(i, WeaponArchetype.ItemName, WeaponArchetype.ItemName == PlayerPawn.Weapon.ItemName);
		}
		else
		{
			UpdateWeaponName(i, "");
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

function UpdateTargetHealth(int Health, int HealthMax)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateTargetHealth");
}

function ShowTargetHealth(bool Show)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.showTargetHealth");
}

function UpdateHealth(int Health, int HealthMax)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateHealth");
}

function UpdateStamina(int Stamina, int StaminaMax)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateStamina");
}

function UpdateWeaponName(int Slot, string WeaponName, bool bActive = false)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateWeaponName");
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

function UpdateIsAlive(bool IsAlive)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.updateIsAlive");
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

defaultproperties
{
	MovieInfo=SwfMovie'Factions_UI.factions_hud'
	bDisplayWithHudOff=False
	bAllowFocus=False
	bAllowInput=False
}
