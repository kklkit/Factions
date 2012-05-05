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

function array<string> PlayerTeam()
{
	local array<string> Data;

	Data.AddItem(FSTeamInfo(GetPC().PlayerReplicationInfo.Team).GetHumanReadableName());

	return Data;
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

function array<string> InfantryEquipmentLabels()
{
	local array<string> Data;

	Data.AddItem("Large Equipment");
	Data.AddItem("Medium Equipment");
	Data.AddItem("Small Equipment");
	Data.AddItem("Tiny Equipment");

	return Data;
}

function array<string> InfantryEquipmentNames(int Slot)
{
	local array<string> Data;

	switch (Slot)
	{
	case 0:
		Data.AddItem("Heavy Rifle");
		Data.AddItem("Battle Rifle");
		break;
	case 1:
		Data.AddItem("None");
		break;
	case 2:
		Data.AddItem("Heavy Pistol");
		break;
	case 3:
		Data.AddItem("None");
		break;
	}

	return Data;
}

function array<string> InfantrySkillLabels()
{
	local array<string> Data;

	Data.AddItem("Armor Skills");
	Data.AddItem("Weapon Skills");
	Data.AddItem("HUD Skills");
	Data.AddItem("Leadership Skills");

	return Data;
}

function array<string> InfantrySkillNames(int Slot)
{
	local array<string> Data;

	switch (Slot)
	{
	case 0:
		Data.AddItem("Lightweight Materials");
		Data.AddItem("Auto Repair");
		Data.AddItem("Buffer Repair");
		break;
	case 1:
		Data.AddItem("Weapon Zoom");
		Data.AddItem("Efficient Reload");
		Data.AddItem("Quick Reload");
		break;
	case 2:
		Data.AddItem("Armor Detection");
		Data.AddItem("Sniper Detection");
		Data.AddItem("Artillery Feedback");
		break;
	case 3:
		Data.AddItem("Charge");
		Data.AddItem("Stealth");
		Data.AddItem("Fight");
		break;
	}

	return Data;
}

function array<string> VehicleChassisNames()
{
	local array<string> Data;

	Data.AddItem("\"Harasser\" Jeep");
	Data.AddItem("\"Raider\" Buggy");
	Data.AddItem("\"Transporter\" APC");
	Data.AddItem("\"Skirmisher\" Tank");
	Data.AddItem("\"Archer\" Tank");
	Data.AddItem("\"Devastator\" Tank");
	Data.AddItem("\"Falcon\" Gunship");
	Data.AddItem("\"Vulture\" Gunship");
	Data.AddItem("\"Eagle\" Dropship");

	return Data;
}

function array<string> VehicleArmorNames()
{
	local array<string> Data;

	Data.AddItem("Plain");
	Data.AddItem("Regenerative");
	Data.AddItem("Absorbent");
	Data.AddItem("Reactive");
	Data.AddItem("Composite");
	Data.AddItem("Reflective");
	Data.AddItem("Compound");
	Data.AddItem("Ablative");

	return Data;
}

/*********************************************************************************************
 Functions calling ActionScript
**********************************************************************************************/

function Invalidate(string Item)
{
	ActionScriptVoid("_root.invalidate");
}

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