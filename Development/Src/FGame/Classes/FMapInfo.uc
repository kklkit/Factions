/**
 * Contains game information specific to the current map.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FMapInfo extends UDKMapInfo;

// Minimap
var() Vector2D MapCenter;
var() float MapRadius;

struct FStructureInfo
{
	var() FStructure Archetype;
};
var() array<FStructureInfo> Structures;

struct FVehicleInfo
{
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
	Structures(0)=(Archetype=FStructure_Barracks'ST_Barracks.Archetypes.ST_Barracks')
	Structures(1)=(Archetype=FStructure_VehicleFactory'ST_VehicleFactory.Archetypes.ST_VehicleFactory')
	Structures(2)=(Archetype=FStructure'ST_Wall.Archetypes.ST_Wall')
	Structures(3)=(Archetype=FStructure_Refinery'ST_Refinery.Archetypes.Refinery')

	Vehicles(0)=(Archetype=FVehicle_Car'VH_Jeep.Archetypes.VH_Jeep')
	Vehicles(1)=(Archetype=FVehicle_Tank'VH_Tank.Archetypes.VH_Tank')
	Vehicles(2)=(Archetype=FVehicle_Aircraft'VH_Gunship.Archetypes.VH_Gunship')

	Weapons(0)=(Name=Pistol, Archetype=FWeapon_Firearm'WP_Pistol.Archetypes.WP_Pistol', AttachmentArchetype=FWeaponAttachment_Firearm'WP_Pistol.Archetypes.WP_Pistol_Attachment')
	Weapons(1)=(Name="Heavy Rifle", Archetype=FWeapon_Firearm'WP_Rifle.Archetypes.WP_Rifle', AttachmentArchetype=FWeaponAttachment_Firearm'WP_Rifle.Archetypes.WP_Rifle_Attachment')
}
