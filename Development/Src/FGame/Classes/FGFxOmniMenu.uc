/**
 * Updates the omnimenu GUI.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FGFxOmniMenu extends FGFxMoviePlayer
	dependson(FVehicleWeapon)
	config(Presets);

struct InfantryPreset {
	var string Name;
	var string InfantryClass;
	var array<string> Weapons;
};

var config array<InfantryPreset> InfantryPresets;

// A list of elements that need to be invalidated the next time the movie clip is open.
var array<string> PendingInvalidates;

var FVehicle SelectedVehicleArchetype;
var FInfantryClass SelectedInfantryClassArchetype;

/**
 * @extends
 */
event OnClose()
{
	InternalOnClose();

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
		TeamIndex = class'FTeamGame'.const.TEAM_NONE;

	// Send the team change request to the server.
	if (TeamIndex != GetPC().GetTeamNum())
		GetPC().ServerChangeTeam(TeamIndex);
}

/**
 * Select the player's infantry preset.
 */
function SelectInfantryPreset(string PresetName)
{
	local int i;
	local InfantryPreset Preset;

	i = PresetName == "" ? 0 : InfantryPresets.Find('Name', PresetName);

	if (i != INDEX_NONE)
	{
		Preset = InfantryPresets[i];
		SelectInfantryClass(Preset.InfantryClass);
		SelectInfantryLoadout(Preset.Weapons);
	}
}

/**
 * Select the player's class.
 */
function SelectInfantryClass(string ClassName)
{
	local FInfantryClass InfantryClassArchetype;

	foreach FMapInfo(GetPC().WorldInfo.GetMapInfo()).InfantryClasses(InfantryClassArchetype)
		if (InfantryClassArchetype.MenuName == ClassName)
			SelectedInfantryClassArchetype = InfantryClassArchetype;

	Invalidate("infantry class selection");
	Invalidate("infantry equipment labels");
	Invalidate("infantry equipment selection");
}

/**
 * Select the player's loadout.
 */
function SelectInfantryLoadout(array<string> EquipmentNames)
{
	local FMapInfo MapInfo;
	local FWeapon WeaponArchetype;
	local FWeapon WeaponArchetypes[4];
	local string WeaponName;
	local int i;

	MapInfo = FMapInfo(GetPC().WorldInfo.GetMapInfo());

	foreach EquipmentNames(WeaponName, i)
		if (WeaponName != "")
			foreach MapInfo.Weapons(WeaponArchetype)
				if (WeaponArchetype.ItemName == WeaponName)
					WeaponArchetypes[i] = WeaponArchetype;

	FPlayerController(GetPC()).ServerSetLoadout(SelectedInfantryClassArchetype, WeaponArchetypes[0], WeaponArchetypes[1], WeaponArchetypes[2], WeaponArchetypes[3]);

	Invalidate("infantry equipment selection");
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
	local FVehicleWeapon VehicleWeaponArchetypes[2]; // class'FVehicle'.const.NumVehicleWeapons
	local string WeaponName;
	local int i;

	MapInfo = FMapInfo(GetPC().WorldInfo.GetMapInfo());

	foreach WeaponNames(WeaponName, i)
		foreach MapInfo.VehicleWeapons(VehicleWeaponArchetype)
			if (VehicleWeaponArchetype.ItemName == WeaponName)
				VehicleWeaponArchetypes[i] = VehicleWeaponArchetype;

	FPlayerController(GetPC()).ServerSpawnVehicle(SelectedVehicleArchetype, VehicleWeaponArchetypes[0], VehicleWeaponArchetypes[1]);
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
 * Returns the name of the player's class;
 */
function array<string> InfantryClass()
{
	local array<string> Data;

	if (SelectedInfantryClassArchetype != None)
	{
		Data.AddItem(SelectedInfantryClassArchetype.MenuName);
	}
	else
	{
		Data.AddItem("");
	}

	return Data;
}

/**
 * Returns a list of the names of the player's selected infantry equipment.
 */
function array<string> InfantryEquipment()
{
	local array<string> Data;
	local int WeaponIndex;
	local FPlayerController PlayerController;

	PlayerController = FPlayerController(GetPC());

	Data.Length = class'FPlayerController'.const.MaxLoadoutSlots;
	for (WeaponIndex = 0; WeaponIndex < class'FPlayerController'.const.MaxLoadoutSlots; WeaponIndex++)
	{
		if (PlayerController.CurrentWeaponArchetypes[WeaponIndex] != None)
		{
			Data.InsertItem(WeaponIndex, PlayerController.CurrentWeaponArchetypes[WeaponIndex].ItemName);
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
	local InfantryPreset Preset;

	foreach InfantryPresets(Preset)
	{
		Data.AddItem(Preset.Name);
	}

	return Data;
}

function array<string> InfantryClassNames()
{
	local array<string> Data;
	local FInfantryClass InfantryClass;

	foreach FMapInfo(GetPC().WorldInfo.GetMapInfo()).InfantryClasses(InfantryClass)
	{
		Data.AddItem(InfantryClass.MenuName);
	}

	return Data;
}

/**
 * Returns a list of the available equipment slot names.
 */
function array<string> InfantryEquipmentLabels()
{
	local array<string> Data;
	local FWeaponClass WeaponClassArchetype;

	if (SelectedInfantryClassArchetype != None)
	{
		foreach SelectedInfantryClassArchetype.LoadoutSlots(WeaponClassArchetype)
		{
			Data.AddItem(WeaponClassArchetype.MenuName);
		}
	}

	return Data;
}

/**
 * Returns a list of the equipment names for the given slot.
 */
function array<string> InfantryEquipmentNames(int Slot)
{
	local FWeapon WeaponArchetype;
	local array<string> Data;

	if (SelectedInfantryClassArchetype != None && Slot < SelectedInfantryClassArchetype.LoadoutSlots.Length)
	{
		foreach FMapInfo(GetPC().WorldInfo.GetMapInfo()).Weapons(WeaponArchetype)
		{
			if (WeaponArchetype.WeaponClassArchetype == SelectedInfantryClassArchetype.LoadoutSlots[Slot])
				Data.AddItem(WeaponArchetype.ItemName);
		}
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

	if (SelectedVehicleArchetype != None && HardpointIndex >= 0 && HardpointIndex < SelectedVehicleArchetype.VehicleHardpoints.Length)
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

function InternalOnClose()
{
	if (bMovieIsOpen)
		ActionScriptVoid("_root.onClose");
}

defaultproperties
{
	MovieInfo=SwfMovie'Factions_UI.factions_omnimenu'
	bCaptureMouseInput=True
	bDisplayMouseCursor=True
}