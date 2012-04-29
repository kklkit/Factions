/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSGFxOmniMenu extends GFxMoviePlayer;

var int NewTeamIndex;

function bool Start(optional bool StartPaused)
{
	Super.Start(StartPaused);

	GetGameViewportClient().bDisplayHardwareMouseCursor = true;

	if (NewTeamIndex != -110)
		UpdateTeam(NewTeamIndex);

	return true;
}

function OnClose()
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
	if (bMovieIsOpen) // Game will crash if ActionScript is called before the movie is loaded
	{
		NewTeamIndex = -110;
		ActionScriptVoid("_root.UpdateTeam");
	}
	else
		NewTeamIndex = TeamIndex;
}

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_omnimenu'
	bAutoPlay=false
	bCaptureMouseInput=true
	NewTeamIndex=-110
}