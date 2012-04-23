/**
 * In-game menu for choosing team, selecting infantry loadouts, customizing vehicles, etc.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSGFxOmniMenu extends GFxMoviePlayer;

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
	Super.OnClose();

	GetGameViewportClient().bDisplayHardwareMouseCursor = false;
}

/*********************************************************************************************
 Functions called from ActionScript
**********************************************************************************************/

function CloseOmniMenu(string FrameLabelOnClose)
{
	Close(false);
}

function SelectTeam(int TeamIndex)
{
	GetPC().ServerChangeTeam(TeamIndex);
}

/*********************************************************************************************
 Functions calling ActionScript
**********************************************************************************************/

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