/**
 * Contains game information specific to the current map.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FMapInfo extends UDKMapInfo;

// Minimap
var(Map) Vector MapOrigin;
var(Map) float MapLength;

var(Units) array<FStructure> Structures;
var(Units) array<FVehicle> Vehicles;
var(Units) array<FWeapon> Weapons;

defaultproperties
{
	MapOrigin=(X=0,Y=0,Z=1900000)
	MapLength=40000.0

	// Each item below will be spawnable in-game

	Structures(0)=FStructure_Barracks'ST_Barracks.Archetypes.ST_Barracks'
	Structures(1)=FStructure_VehicleFactory'ST_VehicleFactory.Archetypes.ST_VehicleFactory'
	Structures(2)=FStructure'ST_Wall.Archetypes.ST_Wall'
	Structures(3)=FStructure'ST_Armory.Archetypes.ST_Armory'

	Vehicles(0)=FVehicle_Car'VH_Jeep.Archetypes.VH_Jeep'
	Vehicles(1)=FVehicle_Tank'VH_Tank.Archetypes.VH_Tank'
	Vehicles(2)=FVehicle_Aircraft'VH_Gunship.Archetypes.VH_Gunship'
	Vehicles(3)=FVehicle_Car8'VH_APC.Archetype.APC'

	Weapons(0)=FWeapon_Firearm'WP_Pistol.Archetypes.WP_Pistol'
	Weapons(1)=FWeapon_Firearm'WP_Rifle.Archetypes.WP_Rifle'
	Weapons(2)=FWeapon_Healer'WP_RepairTool.Archetypes.WP_RepairTool'
}
