/**
 * Displays health, ammo, squad members, and other persistent HUD information.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSGFxHUD extends GFxMoviePlayer;

var GFxObject TopLeftHUD;
var GFxObject TopRightHUD;
var GFxObject BottomLeftHUD;
var GFxObject BottomRightHUD;

var float LastHealth;
var float LastHealthMax;
var float LastAmmo;
var float LastAmmoMax;

/**
 * @extends
 */
function Init(optional LocalPlayer LocPlay)
{
	Super.Init(LocPlay);

	// Get object references for the HUD anchors
	TopLeftHUD = GetVariableObject("_root.topLeftHUD");
	TopRightHUD = GetVariableObject("_root.topRightHUD");
	BottomLeftHUD = GetVariableObject("_root.bottomLeftHUD");
	BottomRightHUD = GetVariableObject("_root.bottomRightHUD");

	// Resize the HUD to the current resolution
	ResizeHUD();
}

/**
 * Updates the HUD elements.
 */
function TickHud()
{
	local PlayerController PC;
	local FSPawn FSP;
	local FSWeapon FSW;
	local UDKVehicle FSV; //@todo change to FSVehicle
	local UDKWeaponPawn FWP; //@todo change to FSWeaponPawn

	PC = GetPC();

	FSP = FSPawn(GetPC().Pawn);

	// Set the pawn if driving a vehicle or mounted weapon
	if (FSP == None)
	{
		FSV = UDKVehicle(PC.Pawn);

		if (FSV == None)
		{
			FWP = UDKWeaponPawn(PC.Pawn);
			if ( FWP != None )
			{
				FSV = FWP.MyVehicle;
				FSP = FSPawn(FWP.Driver);
			}
		}
		else
			FSP = FSPawn(FSV.Driver);

		if (FSV == None)
			return;
	}

	if (FSP != None)
		UpdateHealth(FSP.Health, FSP.HealthMax);
	else
		UpdateHealth(0, 1);

	FSW = FSWeapon(FSP.Weapon);
	if (FSW != None)
		UpdateAmmo(FSW.AmmoCount, FSW.AmmoCountMax);
	else
		UpdateAmmo(0, 1);
}

/*********************************************************************************************
 Functions called from ActionScript
**********************************************************************************************/

/**
 * Places the top-level movie clips at their respective corners of the screen.
 */
function ResizeHUD()
{
	local float Left, Top, Right, Bottom;
	local ASDisplayInfo DI;

	GetVisibleFrameRect(Left, Top, Right, Bottom);

	DI.hasY = true;
	DI.Y = Bottom;
	BottomLeftHUD.SetDisplayInfo(DI);
	BottomRightHUD.SetDisplayInfo(DI);
	DI.hasY = false;

	DI.hasX = true;
	DI.X = Right;
	TopRightHUD.SetDisplayInfo(DI);
	BottomRightHUD.SetDisplayInfo(DI);
}

/*********************************************************************************************
 Functions calling ActionScript
**********************************************************************************************/

function UpdateHealth(int Health, int HealthMax)
{
	if (Health != LastHealth || HealthMax != LastHealthMax)
	{
		ActionScriptVoid("_root.UpdateHealth");
		LastHealth = Health;
		LastHealthMax = HealthMax;
	}
}

function UpdateAmmo(int Ammo, int AmmoMax)
{
	if (Ammo != LastAmmo || AmmoMax != LastAmmoMax)
	{
		ActionScriptVoid("_root.UpdateAmmo");
		LastAmmo = Ammo;
		LastAmmoMax = AmmoMax; 
	}
}

function UpdateResources(int Resources)
{
	ActionScriptVoid("_root.UpdateResources");
}

function UpdateIsAlive(bool IsAlive)
{
	ActionScriptVoid("_root.UpdateIsAlive");
}

function UpdateCommStatus(string CommName, int Health, int HealthMax)
{
	ActionScriptVoid("_root.UpdateCommStatus");
}

function UpdateCurrentResearch(string ResearchName, int SecsLeft)
{
	ActionScriptVoid("_root.UpdateCurrentResearch");
}

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_hud'
	bDisplayWithHudOff=false
	bAutoPlay=true
	LastHealth=-110
	LastHealthMax=-110
	LastAmmo=-110
	LastAmmoMax=-110
}
