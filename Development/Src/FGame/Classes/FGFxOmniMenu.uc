/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FGFxOmniMenu extends FGFxMoviePlayer;

var array<string> PendingInvalidates;

event OnClose()
{
	if (FPawn(GetPC().Pawn) != None)
		FPawn(GetPC().Pawn).ResetEquipment();

	Super.OnClose();
}

function TickHUD()
{
	local string PendingInvalidate;

	if (!bMovieIsOpen)
		return;

	foreach PendingInvalidates(PendingInvalidate)
		Invalidate(PendingInvalidate);

	PendingInvalidates.Length = 0;
}

/*********************************************************************************************
 Functions called from ActionScript
**********************************************************************************************/

function CloseMenu(string FrameLabelOnClose)
{
	Close(False);
}

function SelectTeam(string TeamName)
{
	local int TeamIndex;

	if (TeamName ~= "red")
		TeamIndex = TEAM_RED;
	else if (TeamName ~= "blue")
		TeamIndex = TEAM_BLUE;
	else if (TeamName ~= "spectator")
		TeamIndex = class'FTeamGame'.const.PSEUDO_TEAM_SPECTATOR;

	GetPC().ServerChangeTeam(TeamIndex);
}

function SelectInfantryEquipment(byte Slot, string EquipmentName)
{
	if (GetPC().Pawn != None)
		FInventoryManager(FPawn(GetPC().Pawn).InvManager).SelectEquipment(Slot, name(EquipmentName));
}

function BuildVehicle(string ChassisName)
{
	FPlayerController(GetPC()).BuildVehicle(name(ChassisName));
}

function array<string> PlayerTeam()
{
	local array<string> Data;

	if (GetPC().PlayerReplicationInfo.Team != None)
		Data.AddItem(FTeamInfo(GetPC().PlayerReplicationInfo.Team).GetHumanReadableName());
	else
		Data.AddItem("Spectator");

	return Data;
}

function array<string> PlayerNames(string TeamName)
{
	local array<string> Data;
	local PlayerReplicationInfo PRI;
	local byte TeamIndex;

	if (TeamName ~= "red")
		TeamIndex = TEAM_RED;
	else if (TeamName ~= "blue")
		TeamIndex = TEAM_BLUE;

	foreach GetPC().WorldInfo.GRI.PRIArray(PRI)
	{
		if (TeamName ~= "spectator")
		{
			if (PRI.Team == None) 
				Data.AddItem(PRI.PlayerName);
		}
		else if (PRI.Team != None && PRI.Team.TeamIndex == TeamIndex)
			Data.AddItem(PRI.PlayerName);
	}

	return Data;
}

function array<string> InfantryEquipment()
{
	local array<string> Data;
	local int EquipmentIndex;
	local FInventoryManager PlayerInventory;

	PlayerInventory = FInventoryManager(GetPC().Pawn.InvManager);

	for (EquipmentIndex = 0; EquipmentIndex < class'FInventoryManager'.const.EquipmentSlots; EquipmentIndex++)
		Data.InsertItem(EquipmentIndex, string(PlayerInventory.RequestedEquipment[EquipmentIndex].Name));

	return Data;
}

function array<string> InfantryPresetNames()
{
	local array<string> Data;

	Data.AddItem("Engineer");
	Data.AddItem("Grenadier");
	Data.AddItem("Rifleman");
	Data.AddItem("Scout");
	Data.AddItem("Preset 5");
	Data.AddItem("Preset 6");
	Data.AddItem("Preset 7");
	Data.AddItem("Preset 8");
	Data.AddItem("Preset 9");
	Data.AddItem("Preset 10");

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
		Data.AddItem("RPG");
		break;
	case 1:
		Data.AddItem("None");
		break;
	case 2:
		Data.AddItem("Pistol");
		Data.AddItem("Repair Tool");
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
	Data.AddItem("Tank");
	Data.AddItem("Gunship");

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
	if (bMovieIsOpen)
		ActionScriptVoid("_root.invalidate");
	else
		PendingInvalidates.AddItem(Item);
}

function GotoPanel(string Panel)
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.gotoAndStop");
}

defaultproperties
{
	MovieInfo=SwfMovie'Factions_UI.factions_omnimenu'
	bCaptureMouseInput=True
	bDisplayMouseCursor=True
}