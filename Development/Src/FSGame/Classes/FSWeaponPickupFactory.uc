/**
 * Dispenses weapons to players.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSWeaponPickupFactory extends UDKPickupFactory
	ClassGroup(Pickups,Weapon);

var() class<FSWeapon> WeaponPickupClass;

simulated function ReplicatedEvent(name VarName)
{
	if (VarName == 'InventoryType')
	{
		if (WeaponPickupClass != InventoryType)
			WeaponPickupClass = class<FSWeapon>(InventoryType);
	}

	Super.ReplicatedEvent(VarName);
}

simulated function InitializePickup()
{
	InventoryType = WeaponPickupClass;
	if (InventoryType == None)
	{
		GotoState('Disabled');
		return;
	}

	Super.InitializePickup();
}

function bool CheckForErrors()
{
	if (Super.CheckForErrors())
		return true;

	if (WeaponPickupClass == None)
	{
		`log(self @ " no weapon pickup class");
		return true;
	}

	return false;
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=BaseMeshComponent
		StaticMesh=StaticMesh'Pickups.WeaponBase.S_Pickups_WeaponBase'
		Translation=(X=0.0,Y=0.0,Z=-44.0)
		Scale3D=(X=1.0,Y=1.0,Z=1.0)

		CastShadow=false
		bCastDynamicShadow=false
		bAcceptsLights=true
		bForceDirectLightMap=true

		CollideActors=false
		MaxDrawDistance=7000
	End Object
	BaseMesh=BaseMeshComponent
	Components.Add(BaseMeshComponent)

	bNoDelete=false

	WeaponPickupClass=class'FSWeap_Firearm'
}
