/**
 * Contains game information specific to the current map.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FMapInfo extends UDKMapInfo;

// Minimap
var() Vector MapOrigin;
var() float MapLength;

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
	var() FWeapon Archetype;
};
var() array<FWeaponInfo> Weapons;

defaultproperties
{
	MapOrigin=(X=0,Y=0,Z=1900000)
	MapLength=40000.0

	// Each item below will be spawnable in-game

	Structures(0)=(Archetype=FStructure_Barracks'ST_Barracks.Archetypes.ST_Barracks')
	Structures(1)=(Archetype=FStructure_VehicleFactory'ST_VehicleFactory.Archetypes.ST_VehicleFactory')
	Structures(2)=(Archetype=FStructure'ST_Wall.Archetypes.ST_Wall')
	Structures(3)=(Archetype=FStructure'ST_Armory.Archetypes.ST_Armory')

	Vehicles(0)=(Archetype=FVehicle_Car'VH_Jeep.Archetypes.VH_Jeep')
	Vehicles(1)=(Archetype=FVehicle_Tank'VH_Tank.Archetypes.VH_Tank')
	Vehicles(2)=(Archetype=FVehicle_Aircraft'VH_Gunship.Archetypes.VH_Gunship')
	Vehicles(3)=(Archetype=FVehicle_Car8'VH_APC.Archetype.APC')

	Weapons(0)=(Archetype=FWeapon_Firearm'WP_Pistol.Archetypes.WP_Pistol')
	Weapons(1)=(Archetype=FWeapon_Firearm'WP_Rifle.Archetypes.WP_Rifle')
	Weapons(2)=(Archetype=FWeapon_Healer'WP_RepairTool.Archetypes.WP_RepairTool')
}
