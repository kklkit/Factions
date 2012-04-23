/**
 * In-game menu for choosing team, selecting infantry loadouts, customizing vehicles, etc.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSGFxOmniMenu extends GFxMoviePlayer;

/**
 * @extends
 */
function bool Start(optional bool StartPaused)
{
	super.Start(StartPaused);

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

function CloseOmniMenu(string FrameLabelOnClose)
{
	Close(false);
}

function SelectTeam(int TeamIndex)
{
	GetPC().ServerChangeTeam(TeamIndex);
}

function UpdateTeam(int TeamIndex)
{
	ActionScriptVoid("_root.UpdateTeam");
}

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_omnimenu'
	bAutoPlay=true
	bCaptureMouseInput=true
}