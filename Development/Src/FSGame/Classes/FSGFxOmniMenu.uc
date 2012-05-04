/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSGFxOmniMenu extends FSGFxMoviePlayer;

function bool Start(optional bool StartPaused)
{
	Super.Start(StartPaused);

	return true;
}

function OnClose()
{
	Super.OnClose();

	if (PC.Pawn != None)
		FSPawn(PC.Pawn).ResetEquipment();
}

/*********************************************************************************************
 Functions called from ActionScript
**********************************************************************************************/

function CloseMenu(string FrameLabelOnClose)
{
	Close(false);
}

function SelectTeam(byte TeamIndex)
{
	PC.ServerChangeTeam(TeamIndex);
}

function SelectClass(byte ClassIndex)
{
	FSPawn(PC.Pawn).ChangeClass(ClassIndex);
}

function SelectEquipment(byte Slot, string EquipmentName)
{
	if (PC.Pawn != None)
		FSInventoryManager(FSPawn(PC.Pawn).InvManager).SelectEquipment(Slot, EquipmentName);
}

function array<string> PlayerNames(string TeamName)
{
	local array<string> Data;
	local FSPlayerController FSPC;
	local byte TeamIndex;

	TeamIndex = TeamName ~= "Red" ? 0 : 1;

	foreach GetPC().WorldInfo.AllControllers(class'FSPlayerController', FSPC)
		if (FSPC.PlayerReplicationInfo.Team.TeamIndex == TeamIndex)
			Data.AddItem(FSPC.PlayerReplicationInfo.PlayerName);

	return Data;
}

/*********************************************************************************************
 Functions calling ActionScript
**********************************************************************************************/

function UpdateTeam(int TeamIndex)
{
	ActionScriptVoid("_root.UpdateTeam");
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
	bDisplayMouseCursor=true
}