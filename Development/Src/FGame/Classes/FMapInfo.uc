/**
 * Contains game information specific to the current map.
 * 
 * Each map can define its own set of structures, vehicles, and weapons to use.
 * The default set is defined in the UDKMapInfo.ini configuration file. This
 * can be overridden in a map by using the MyMapInfo property under
 * World Properties in UDK Editor.
 * 
 * A structure, vehicle, or weapon in the game is defined using an archetype
 * instead of instantiating from a class. An archetype is an instance of a
 * class with properties that have been set using the property editor in
 * UDK Editor. This allows unit property values to be changed without having to
 * recompile the code.
 * 
 * Each unit info structure is a mapping between a name and an archetype. The
 * name is used internally in the UnrealScript code to identify different
 * units. The getter functions can be used to get the unit info for a given
 * name. The archetype can then be obtained from the unit info to spawn an
 * instance of the unit in the world.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FMapInfo extends UDKMapInfo
	config(MapInfo);

// Minimap
var() Vector2D MapCenter;
var() float MapRadius;

struct FStructureInfo
{
	var() name Name;
	var() FStructure Archetype;
};
var() config array<FStructureInfo> Structures;

struct FVehicleInfo
{
	var() name Name;
	var() FVehicle Archetype;
};
var() array<FVehicleInfo> Vehicles;

struct FWeaponInfo
{
	var() name Name;
	var() FWeapon Archetype;
	var() FWeaponAttachment AttachmentArchetype;
};
var() array<FWeaponInfo> Weapons;

/**
 * Returns the structure info for the given structure name.
 */
function FStructureInfo GetStructureInfo(name StructureName)
{
	return Structures[Structures.Find('Name', StructureName)];
}

/**
 * Returns the vehicle info for the given vehicle name.
 */
function FVehicleInfo GetVehicleInfo(name VehicleName)
{
	return Vehicles[Vehicles.Find('Name', VehicleName)];
}

/**
 * Returns the weapon info for the given weapon name.
 */
function FWeaponInfo GetWeaponInfo(name WeaponName)
{
	return Weapons[Weapons.Find('Name', WeaponName)];
}

defaultproperties
{
	MapCenter=(X=0,Y=0)
	MapRadius=20000.0

	// TODO: These should be in the config file, but are causing errors when loading the game.
	Vehicles(0)=(Name=Jeep, Archetype=FVehicle_Car'VH_Jeep.Archetypes.VH_Jeep')
	Vehicles(1)=(Name=Tank, Archetype=FVehicle_Tank'VH_Tank.Archetypes.VH_Tank')
	Vehicles(2)=(Name=Gunship, Archetype=FVehicle_Aircraft'VH_Gunship.Archetypes.VH_Gunship')

	Weapons(0)=(Name=Pistol, Archetype=FWeapon_Firearm'WP_Pistol.Archetypes.WP_Pistol', AttachmentArchetype=FWeaponAttachment_Firearm'WP_Pistol.Archetypes.WP_Pistol_Attachment')
	Weapons(1)=(Name="Heavy Rifle", Archetype=FWeapon_Firearm'WP_Rifle.Archetypes.WP_Rifle', AttachmentArchetype=FWeaponAttachment_Firearm'WP_Rifle.Archetypes.WP_Rifle_Attachment')
}
