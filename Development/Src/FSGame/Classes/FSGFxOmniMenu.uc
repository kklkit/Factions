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

function SelectTeam(string TeamName)
{
	local int TeamIndex;

	if (TeamName ~= "red")
		TeamIndex = TEAM_RED;
	else if (TeamName ~= "blue")
		TeamIndex = TEAM_BLUE;
	else if (TeamName ~= "spectator")
		TeamIndex = 255;

	PC.ServerChangeTeam(TeamIndex);
}

function SelectInfantryEquipment(byte Slot, string EquipmentName)
{
	if (PC.Pawn != None)
		FSInventoryManager(FSPawn(PC.Pawn).InvManager).SelectEquipment(Slot, EquipmentName);
}

function array<string> PlayerTeam()
{
	local array<string> Data;

	if (GetPC().PlayerReplicationInfo.Team != None)
		Data.AddItem(FSTeamInfo(GetPC().PlayerReplicationInfo.Team).GetHumanReadableName());
	else
		Data.AddItem("Spectator");

	return Data;
}

function array<string> PlayerNames(string TeamName)
{
	local array<string> Data;
	local FSPlayerController FSPC;
	local byte TeamIndex;

	if (TeamName ~= "red")
		TeamIndex = TEAM_RED;
	else if (TeamName ~= "blue")
		TeamIndex = TEAM_BLUE;

	foreach GetPC().WorldInfo.AllControllers(class'FSPlayerController', FSPC)
	{
		if ((TeamName ~= "spectator" && FSPC.PlayerReplicationInfo.Team == None) || (FSPC.PlayerReplicationInfo.Team != None && FSPC.PlayerReplicationInfo.Team.TeamIndex == TeamIndex))
			Data.AddItem(FSPC.PlayerReplicationInfo.PlayerName);
	}

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
		Data.AddItem("Assault Rifle");
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

	Data.AddItem("Armor Skill");
	Data.AddItem("Weapon Skill");
	Data.AddItem("HUD Skill");
	Data.AddItem("Leadership Skill");

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

	Data.AddItem("Jeep");
	Data.AddItem("Attack Buggy");
	Data.AddItem("APC");
	Data.AddItem("Light Tank");
	Data.AddItem("Missile Tank");
	Data.AddItem("Heavy Tank");
	Data.AddItem("Attack Gunship");
	Data.AddItem("Heavy Gunship");
	Data.AddItem("Dropship");

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

defaultproperties
{
	MovieInfo=SwfMovie'FSFlashAssets.factions_omnimenu'
	bAutoPlay=true
	bCaptureMouseInput=true
	bDisplayMouseCursor=true
}