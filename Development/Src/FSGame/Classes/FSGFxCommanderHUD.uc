/**
 * Displays the commander HUD.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSGFxCommanderHUD extends GFxMoviePlayer;

/**
 * @extends
 */
event bool Start(optional bool StartPaused)
{
	super.Start(StartPaused);

	GetGameViewportClient().bDisplayHardwareMouseCursor = true;

	return true;
}

/**
 * @extends
 */
event OnClose()
{
	super.OnClose();

	GetGameViewportClient().bDisplayHardwareMouseCursor = false;
}

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_commander_hud'
	bAutoPlay=false
	bCaptureMouseInput=true
}
