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

function UpdateHealth(int Health, int MaxHealth)
{
	ActionScriptVoid("_root.UpdateHealth");
}

function UpdateResources(int Resources)
{
	ActionScriptVoid("_root.UpdateResources");
}

function UpdateIsAlive(bool IsAlive)
{
	ActionScriptVoid("_root.UpdateIsAlive");
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

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_hud'
	bDisplayWithHudOff=false
	bAutoPlay=true
}
