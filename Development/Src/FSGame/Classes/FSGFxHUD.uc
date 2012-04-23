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
	local UDKVehicle FSV; //@todo change to FSVehicle
	local UDKWeaponPawn FWP; //@todo change to FSWeaponPawn

	PC = GetPC();

	FSP = FSPawn(GetPC().Pawn);

	// Set the pawn if driving a vehicle or mounted weapon
	if (FSP == None)
	{
		FSV = UDKVehicle(PC.Pawn);

		if ( FSV == None )
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

	UpdateHealth(FSP.Health, FSP.HealthMax);
}

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

/**
 * Update the displayed health if changed.
 */
function UpdateHealth(int Health, int HealthMax)
{
	if (Health != LastHealth || HealthMax != LastHealthMax)
	{
		ActionScriptVoid("_root.UpdateHealth");
		LastHealth = Health;
		HealthMax = LastHealthMax;
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

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_hud'
	bDisplayWithHudOff=false
	bAutoPlay=true
	LastHealth=-110
	LastHealthMax=-110
}
