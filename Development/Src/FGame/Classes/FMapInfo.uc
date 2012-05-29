/**
 * Contains game information specific to the current map.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FMapInfo extends UDKMapInfo
	config(MapInfo);

// Minimap
var() Vector2D MapCenter;
var() float MapRadius;

// Structure types
struct FStructureInfo
{
	var() name Name;
	var() FStructure Archetype;
};
var() config array<FStructureInfo> Structures;

// Vehicle types
struct FVehicleInfo
{
	var() name Name;
	var() FVehicle Archetype;
};
var() array<FVehicleInfo> Vehicles;

/**
 * Returns the structure info for the given name.
 */
function FStructureInfo GetStructureInfo(name StructureName)
{
	return Structures[Structures.Find('Name', StructureName)];
}

/**
 * Returns the vehicle info for the given name.
 */
function FVehicleInfo GetVehicleInfo(name VehicleName)
{
	return Vehicles[Vehicles.Find('Name', VehicleName)];
}

defaultproperties
{
	MapCenter=(X=0,Y=0)
	MapRadius=20000.0

	Vehicles(0)=(Name=Jeep, Archetype=FVehicle_Car'VH_Jeep.Mesh.A_VH_Jeep')
	Vehicles(1)=(Name=Tank, Archetype=FVehicle_Tank'VH_Tank.Mesh.A_VH_Tank')
	Vehicles(2)=(Name=Gunship, Archetype=FVehicle_Aircraft'VH_Gunship.Mesh.A_VH_Gunship')
}
