/**
 * Contains game information specific to the current map.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FMapInfo extends UDKMapInfo;

// Minimap
var(Map) Vector MapOrigin;
var(Map) float MapLength;

var() int StartingResources;

var(Game) array<FInfantryClass> InfantryClasses;
var(Game) array<FStructure> Structures;
var(Game) array<FVehicle> Vehicles;
var(Game) array<FWeapon> Weapons;
var(Game) array<FVehicleWeapon> VehicleWeapons;

defaultproperties
{
	MapOrigin=(X=0,Y=0,Z=1900000)
	MapLength=40000.0

	StartingResources=400

	// Each item below will be spawnable in-game

	InfantryClasses(0)=FInfantryClass'IC_Commando.Archetypes.IC_Commando'
	InfantryClasses(1)=FInfantryClass'IC_Assault.Archetypes.IC_Assault'
	InfantryClasses(2)=FInfantryClass'IC_Soldier.Archetypes.IC_Soldier'
	InfantryClasses(3)=FInfantryClass'IC_Engineer.Archetypes.IC_Engineer'
	InfantryClasses(4)=FInfantryClass'IC_Specialist.Archetypes.IC_Specialist'

	Structures(0)=FStructure_Barracks'ST_Barracks.Archetypes.ST_Barracks'
	Structures(1)=FStructure_VehicleFactory'ST_VehicleFactory.Archetypes.ST_VehicleFactory'
	Structures(2)=FStructure'ST_Wall.Archetypes.ST_Wall'
	Structures(3)=FStructure'ST_Armory.Archetypes.ST_Armory'

	Vehicles(0)=FVehicle_Car'VH_Jeep.Archetypes.VH_Jeep'
	Vehicles(1)=FVehicle_Tank'VH_Tank.Archetypes.VH_Tank'
	Vehicles(2)=FVehicle_Aircraft'VH_Gunship.Archetypes.VH_Gunship'
	Vehicles(3)=FVehicle_Car8'VH_APC.Archetype.VH_APC'
	Vehicles(4)=FVehicle_Tank'VH_SuperTank.Archetypes.VH_SuperTank'

	Weapons(0)=FWeapon_Firearm'WP_Pistol.Archetypes.WP_Pistol'
	Weapons(1)=FWeapon_Firearm'WP_Rifle.Archetypes.WP_Rifle'
	Weapons(2)=FWeapon_Healer'WP_RepairTool.Archetypes.WP_RepairTool'
	Weapons(3)=FWeapon_RocketLauncher'WP_RPG.Archetypes.WP_RPG'

	VehicleWeapons(0)=FVehicleWeapon_Projectile'VWP_RangedCannon.Archetypes.VWP_RangedCannon'
	VehicleWeapons(1)=FVehicleWeapon_Instant'VWP_MG.Archetypes.VWP_MG'
}
