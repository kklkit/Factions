/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSWeap_Firearm extends FSWeapon
	abstract;

defaultproperties
{
	FiringStatesArray(0)=WeaponFiring
	WeaponFireTypes(0)=EWFT_InstantHit
	FireInterval(0)=0.1
	Spread(0)=0.0
	InstantHitDamage(0)=25.0
	InstantHitMomentum(0)=5.0
	InstantHitDamageTypes(0)=class'DamageType'
	ShouldFireOnRelease(0)=0

	EquipTime=+0.45
	PutDownTime=+0.33
	WeaponRange=22000
	AimTraceRange=22000
}
