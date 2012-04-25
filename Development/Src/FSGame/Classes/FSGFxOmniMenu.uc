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

function SelectClass(int ClassIndex)
{
	`log("Selected class" @ ClassIndex);
}

function SelectEquipment(string EquipmentName)
{
	`log("Selected equipment" @ EquipmentName);
}

/*********************************************************************************************
 Functions calling ActionScript
**********************************************************************************************/

function UpdateTeam(int TeamIndex)
{
	if (bMovieIsOpen)
	{
		ActionScriptVoid("_root.UpdateTeam");
	}
}

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_omnimenu'
	bAutoPlay=false
	bCaptureMouseInput=true
}