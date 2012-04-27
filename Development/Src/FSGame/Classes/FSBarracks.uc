/**
 * Spawns players and weapons.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSBarracks extends FSStructure;

/**
 * @extends
 */
event PostBeginPlay()
{
	local Vector WPFLocation;

	super.PostBeginPlay();

	WPFLocation.X = Location.X + 200;
	WPFLocation.Y = Location.Y + 1000;
	WPFLocation.Z = Location.Z + 75;

	Spawn(class'FSWeaponPickupFactory', self, , WPFLocation, , , );
}

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		StaticMesh=StaticMesh'FSAssets.Structures.Barracks'
	End Object
}
