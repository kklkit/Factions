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

	FSPawn(GetPC().Pawn).ResetEquipment();
}

/*********************************************************************************************
 Functions called from ActionScript
**********************************************************************************************/

function CloseOmniMenu(string FrameLabelOnClose)
{
	Close(false);
}

function SelectTeam(byte TeamIndex)
{
	GetPC().ServerChangeTeam(TeamIndex);
}

function SelectClass(byte ClassIndex)
{
	FSPawn(GetPC().Pawn).ChangeClass(ClassIndex);
}

function SelectEquipment(byte Slot, string EquipmentName)
{
	FSInventoryManager(FSPawn(GetPC().Pawn).InvManager).SelectEquipment(Slot, EquipmentName);
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

function UpdateClassSelection(byte ClassIndex)
{
	ActionScriptVoid("_root.UpdateClassSelection");
}

function UpdateEquipmentSelection(byte Slot, string EquipmentName)
{
	ActionScriptVoid("_root.UpdateEquipmentSelection");
}

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_omnimenu'
	bAutoPlay=true
	bCaptureMouseInput=true
	NewTeamIndex=-110
}