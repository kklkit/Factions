/**
 * Updates the omnimenu GUI.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FGFxOmniMenu extends FGFxMoviePlayer
	dependson(FVehicleWeapon);

// A list of elements that need to be invalidated the next time the movie clip is open.
var array<string> PendingInvalidates;

var FVehicle SelectedVehicleArchetype;

/**
 * @extends
 */
event OnClose()
{
	// Set the player's loadout when the menu is closed. The called function is responsible for checking if the player is in a barracks/armory.
	if (FPawn(GetPC().Pawn) != None)
		FPawn(GetPC().Pawn).ResetEquipment();

	Super.OnClose();
}

/**
 * Updates the interface elements in Flash.
 */
function TickHUD()
{
	local string PendingInvalidate;

	// Calling functions in Flash while the movie is closed can cause a crash.
	if (!bMovieIsOpen)
		return;

	// Invalidate any HUD elements that were changed while the menu was closed.
	foreach PendingInvalidates(PendingInvalidate)
		Invalidate(PendingInvalidate);

	// All changed HUD elements should have been invalidated.
	PendingInvalidates.Length = 0;
}

/*********************************************************************************************
 Functions called from ActionScript
**********************************************************************************************/

/**
 * Closes the omnimenu.
 */
function CloseMenu(string FrameLabelOnClose)
{
	Close(False);
}

/**
 * Select what team the player is on.
 */
function SelectTeam(string TeamName)
{
	local int TeamIndex;

	// Get the team index for the given team name.
	if (TeamName ~= "red")
		TeamIndex = TEAM_RED;
	else if (TeamName ~= "blue")
		TeamIndex = TEAM_BLUE;
	else if (TeamName ~= "spectator")
		TeamIndex = class'FTeamGame'.const.PSEUDO_TEAM_SPECTATOR;

	// Send the team change request to the server.
	GetPC().ServerChangeTeam(TeamIndex);
}

/**
 * Select the player's equipment for the given slot.
 */
function SelectInfantryEquipment(byte Slot, int EquipmentIndex)
{
	if (GetPC().Pawn != None)
		FInventoryManager(FPawn(GetPC().Pawn).InvManager).SelectEquipment(Slot, EquipmentIndex);
}

/**
 * Select a vehicle chassis.
 */
function SelectVehicleChassis(string ChassisName)
{
	local FVehicle VehicleArchetype;

	foreach FMapInfo(GetPC().WorldInfo.GetMapInfo()).Vehicles(VehicleArchetype)
		if (VehicleArchetype.MenuName == ChassisName)
			SelectedVehicleArchetype = VehicleArchetype;

	Invalidate("vehicle equipment");
}

/**
 * Build a vehicle for the player.
 */
function BuildVehicle(string ChassisName, array<string> WeaponNames)
{
	local FMapInfo MapInfo;
	local FVehicleWeapon VehicleWeaponArchetype;
	local array<FVehicleWeapon> VehicleWeaponArchetypes;
	local string WeaponName;

	MapInfo = FMapInfo(GetPC().WorldInfo.GetMapInfo());

	foreach WeaponNames(WeaponName)
		foreach MapInfo.VehicleWeapons(VehicleWeaponArchetype)
			if (VehicleWeaponArchetype.ItemName == WeaponName)
				VehicleWeaponArchetypes.AddItem(VehicleWeaponArchetype);

	FPlayerController(GetPC()).ServerSpawnVehicle(SelectedVehicleArchetype, VehicleWeaponArchetypes);
}

/*********************************************************************************************
 Data providers
**********************************************************************************************/

/**
 * Returns the team name of the team the player is on.
 */
function array<string> PlayerTeam()
{
	local array<string> Data;

	if (GetPC().PlayerReplicationInfo.Team != None)
		Data.AddItem(FTeamInfo(GetPC().PlayerReplicationInfo.Team).GetHumanReadableName());
	else
		Data.AddItem("Spectator");

	return Data;
}

/**
 * Returns a list of the player names on the given team.
 */
function array<string> PlayerNames(string TeamName)
{
	local array<string> Data;
	local PlayerReplicationInfo PlayerReplicationInfo;
	local byte TeamIndex;

	if (TeamName ~= "red")
		TeamIndex = TEAM_RED;
	else if (TeamName ~= "blue")
		TeamIndex = TEAM_BLUE;

	foreach GetPC().WorldInfo.GRI.PRIArray(PlayerReplicationInfo)
	{
		if (TeamName ~= "spectator")
		{
			if (PlayerReplicationInfo.Team == None)
			{
				Data.AddItem(PlayerReplicationInfo.PlayerName);
			}
		}
		else if (PlayerReplicationInfo.Team != None && PlayerReplicationInfo.Team.TeamIndex == TeamIndex)
		{
			Data.AddItem(PlayerReplicationInfo.PlayerName);
		}
	}

	return Data;
}

/**
 * Returns a list of the names of the player's selected infantry equipment.
 */
function array<string> InfantryEquipment()
{
	local array<string> Data;
	local int EquipmentIndex;
	local FInventoryManager PlayerInventory;

	PlayerInventory = FInventoryManager(GetPC().Pawn.InvManager);

	for (EquipmentIndex = 0; EquipmentIndex < class'FInventoryManager'.const.EquipmentSlots; EquipmentIndex++)
	{
		if (PlayerInventory.RequestedEquipment[EquipmentIndex] != None)
		{
			Data.InsertItem(EquipmentIndex, PlayerInventory.RequestedEquipment[EquipmentIndex].ItemName);
		}
	}

	return Data;
}

/**
 * Returns a list of the names of the player's equipment presets.
 */
function array<string> InfantryPresetNames()
{
	local array<string> Data;

	Data.AddItem("Preset 1");
	Data.AddItem("Preset 2");
	Data.AddItem("Preset 3");
	Data.AddItem("Preset 4");
	Data.AddItem("Preset 5");
	Data.AddItem("Preset 6");
	Data.AddItem("Preset 7");
	Data.AddItem("Preset 8");
	Data.AddItem("Preset 9");
	Data.AddItem("Preset 10");

	return Data;
}

/**
 * Returns a list of the available equipment slot names.
 */
function array<string> InfantryEquipmentLabels()
{
	local array<string> Data;

	Data.AddItem("Large Equipment");
	Data.AddItem("Medium Equipment");
	Data.AddItem("Small Equipment");
	Data.AddItem("Tiny Equipment");

	return Data;
}

/**
 * Returns a list of the equipment names for the given slot.
 */
function array<string> InfantryEquipmentNames(int Slot)
{
	local FWeapon WeaponArchetype;
	local array<string> Data;

	foreach FMapInfo(GetPC().WorldInfo.GetMapInfo()).Weapons(WeaponArchetype)
	{
		Data.AddItem(WeaponArchetype.ItemName);
	}

	return Data;
}

/**
 * Returns a list of the available skill slot names.
 */
function array<string> InfantrySkillLabels()
{
	local array<string> Data;

	Data.AddItem("Armor Skill");
	Data.AddItem("Weapon Skill");
	Data.AddItem("HUD Skill");
	Data.AddItem("Leadership Skill");

	return Data;
}

/**
 * Returns a list of the skill names for the given skill slot.
 */
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

/**
 * Returns a list of the available vehicle chassis.
 */
function array<string> VehicleChassisNames()
{
	local FVehicle VehicleArchetype;
	local array<string> Data;

	foreach FMapInfo(GetPC().WorldInfo.GetMapInfo()).Vehicles(VehicleArchetype)
	{
		Data.AddItem(VehicleArchetype.MenuName);
	}

	return Data;
}

/**
 * Returns a list of the available vehicle armor names.
 */
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

/**
 * Returns a list of the available vehicle weapons.
 */
function array<string> VehicleWeaponNames(int HardpointIndex)
{
	local FMapInfo MapInfo;
	local FVehicleWeapon VehicleWeaponArchetype;
	local EHardpointTypes HardpointType;
	local array<string> Data;

	MapInfo =  FMapInfo(GetPC().WorldInfo.GetMapInfo());

	if (HardpointIndex >= 0 && HardpointIndex < SelectedVehicleArchetype.VehicleHardpoints.Length)
	{
		HardpointType = SelectedVehicleArchetype.VehicleHardpoints[HardpointIndex].HardpointType;
		foreach MapInfo.VehicleWeapons(VehicleWeaponArchetype)
		{
			if (VehicleWeaponArchetype.HardpointType == HardpointType)
			{
				Data.AddItem(VehicleWeaponArchetype.ItemName);
			}
		}
	}
	else
	{
		Data.AddItem("None");
	}

	return Data;
}

/*********************************************************************************************
 Functions calling ActionScript
 
 These functions simply forwards the call with its parameters to Flash.
 
 Always check to make sure the movie is open before calling Flash. The game will crash if a
 function is called while the movie is closed.
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