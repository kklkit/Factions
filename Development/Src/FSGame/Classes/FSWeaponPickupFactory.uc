/**
 * Dispenses weapons to players.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSWeaponPickupFactory extends UDKPickupFactory;

var() class<FSWeapon> WeaponPickupClass;

/**
 * @extends
 */
simulated function InitializePickup()
{
	InventoryType = WeaponPickupClass;
	if (InventoryType == None)
	{
		GotoState('Disabled');
		return;
	}

	super.InitializePickup();
}

/**
 * @extends
 */
simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'InventoryType')
	{
		if (InventoryType != WeaponPickupClass)
			WeaponPickupClass = class<FSWeapon>(InventoryType);
	}
	super.ReplicatedEvent(VarName);
}

/**
 * @extends
 */
function bool CheckForErrors()
{
	if (super.CheckForErrors())
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
	Components.Remove(Sprite)
	Components.Remove(Sprite2)
	Components.Remove(Arrow)
	GoodSprite=None
	BadSprite=None

	bMovable=false
	bStatic=false

	bDoVisibilityFadeIn=false // weapons are all skeletal meshes and don't do the ResIn effect. Also most weapons are always available
	bRotatingPickup=true
	bCollideActors=true
	bBlockActors=true

	YawRotationRate=32768

	Begin Object Name=CollisionCylinder
		CollisionRadius=+00040.000000
		CollisionHeight=+00044.000000
		CollideActors=true
		BlockZeroExtent=false
	End Object

	BasePulseRate=0.5
	PulseThreshold=5.0

	Begin Object Class=StaticMeshComponent Name=BaseMeshComp
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
	BaseMesh=BaseMeshComp
	Components.Add(BaseMeshComp)
}
