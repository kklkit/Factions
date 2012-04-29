/**
 * Displays the commander HUD.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSGFxCommanderHUD extends GFxMoviePlayer;

/**
 * @extends
 */
function bool Start(optional bool StartPaused)
{
	Super.Start(StartPaused);

	GetGameViewportClient().bDisplayHardwareMouseCursor = true;

	return true;
}

/**
 * @extends
 */
function OnClose()
{
	Super.OnClose();

	GetGameViewportClient().bDisplayHardwareMouseCursor = false;
}

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_commander_hud'
	bAutoPlay=false
	bCaptureMouseInput=false
}
