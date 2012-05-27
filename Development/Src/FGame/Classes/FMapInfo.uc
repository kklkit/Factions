/**
 * Contains game information specific to the current map.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FMapInfo extends UDKMapInfo;

// Minimap
var() Vector2D MapCenter;
var() float MapRadius;

// Structure types
struct FStructureInfo
{
	var() name Name;
	var() FStructure Archetype;
};
var() array<FStructureInfo> Structures;

/**
 * Returns the structure info for the given name.
 */
function FStructureInfo GetStructureInfo(name StructureName)
{
	return Structures[Structures.Find('Name', StructureName)];
}

defaultproperties
{
	MapCenter=(X=0,Y=0)
	MapRadius=20000.0
	Structures(0)=(Name=Barracks, Archetype=FStructure_Barracks'ST_Barracks.Mesh.A_ST_Barracks')
	Structures(1)=(Name=VehicleFactory, Archetype=FStructure_VehicleFactory'ST_VehicleFactory.Mesh.A_ST_VehicleFactory')
	Structures(2)=(Name=Wall, Archetype=FStructure'ST_Wall.Mesh.A_ST_Wall')
}
