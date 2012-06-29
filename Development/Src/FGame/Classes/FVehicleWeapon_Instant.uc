/**
 * Hitscan vehicle weapons.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FVehicleWeapon_Instant extends FVehicleWeapon;

defaultproperties
{
	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_InstantHit
	InstantHitDamageTypes(0)=class'DamageType'
	InstantHitDamageTypes(1)=class'DamageType'
	InstantHitDamage(0)=1.0
	InstantHitDamage(1)=1.0
	InstantHitMomentum(0)=1.0
	InstantHitMomentum(1)=1.0
	FireInterval(0)=0.1
	FireInterval(1)=0.1
	Spread(0)=0.05
	Spread(1)=0.05
	HardpointType=H_Gun
}
