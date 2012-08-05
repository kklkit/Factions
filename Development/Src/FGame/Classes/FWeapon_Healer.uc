/**
 * Heals friendlies it shoots at.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FWeapon_Healer extends FWeapon;

/**
 * @extends
 */
simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
	if (Impact.HitActor != None)
		Impact.HitActor.HealDamage(InstantHitDamage[CurrentFireMode] * Max(NumHits, 1), Instigator.Controller, InstantHitDamageTypes[FiringMode]);
}

defaultproperties
{
	InstantHitDamage(0)=10.0
	WeaponRange=200.0
	AmmoCount=100
	MaxAmmoCount=100
}
