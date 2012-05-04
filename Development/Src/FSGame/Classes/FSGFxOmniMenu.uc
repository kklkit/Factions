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

function UpdateTeam(int TeamIndex)
{
	local string TeamName;

	if (TeamIndex == -1)
		TeamName = "spectator";
	else if (TeamIndex == 0)
		TeamName = "red";
	else if (TeamIndex == 1)
		TeamName = "blue";

	UpdateTeamSelection(TeamName);
}

/*********************************************************************************************
 Functions called from ActionScript
**********************************************************************************************/

function CloseMenu(string FrameLabelOnClose)
{
	Close(false);
}

function SelectTeam(string TeamName)
{
	local byte TeamIndex;

	if (TeamName ~= "red")
		TeamIndex = 0;
	else if (TeamName ~= "blue")
		TeamIndex = 1;
	else if (TeamName ~= "spectator")
		TeamIndex = 0;

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

	TeamIndex = TeamName ~= "red" ? 0 : 1;

	foreach GetPC().WorldInfo.AllControllers(class'FSPlayerController', FSPC)
		if (FSPC.PlayerReplicationInfo.Team.TeamIndex == TeamIndex)
			Data.AddItem(FSPC.PlayerReplicationInfo.PlayerName);

	return Data;
}

/*********************************************************************************************
 Functions calling ActionScript
**********************************************************************************************/

function UpdateTeamSelection(string TeamName)
{
	ActionScriptVoid("_root.updateTeamSelection");
}

function UpdateClassSelection(byte ClassIndex)
{
	ActionScriptVoid("_root.updateClassSelection");
}

function UpdateEquipmentSelection(byte Slot, string EquipmentName)
{
	ActionScriptVoid("_root.updateEquipmentSelection");
}

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_omnimenu'
	bAutoPlay=true
	bCaptureMouseInput=true
	bDisplayMouseCursor=true
}