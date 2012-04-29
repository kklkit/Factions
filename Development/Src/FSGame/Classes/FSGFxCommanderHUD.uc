/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSGFxCommanderHUD extends GFxMoviePlayer;

function bool Start(optional bool StartPaused)
{
	Super.Start(StartPaused);

	GetGameViewportClient().bDisplayHardwareMouseCursor = true;

	return true;
}

function OnClose()
{
	Super.OnClose();

	GetGameViewportClient().bDisplayHardwareMouseCursor = false;
}

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_commander_hud'
	bAutoPlay=false
}
