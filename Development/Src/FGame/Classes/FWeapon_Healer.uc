/**
 * Heals friendlies it shoots at.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FWeapon_Healer extends FWeapon;

var(Weapon) float AmmoRegenRate;

/**
 * @extends
 */
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Role == ROLE_Authority && !IsTimerActive(NameOf(RegenerateAmmo)))
	{
		SetTimer(AmmoRegenRate, True, NameOf(RegenerateAmmo));
	}
}

/**
 * @extends
 */
simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
	if (Impact.HitActor != None)
		Impact.HitActor.HealDamage(InstantHitDamage[CurrentFireMode] * Max(NumHits, 1), Instigator.Controller, InstantHitDamageTypes[FiringMode]);
}

/**
 * @extends
 */
simulated function UpdateSpread();

/**
 * Adds ammo to the weapon.
 */
function RegenerateAmmo()
{
	AddAmmo(1);
}

simulated state WeaponFiring
{
	ignores RegenerateAmmo;

	/**
	 * @extends
	 */
	simulated event BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		if (Role == ROLE_Authority)
		{
			ClearTimer(NameOf(RegenerateAmmo));
		}
	}

	/**
	 * @extends
	 */
	simulated event EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);

		if (Role == ROLE_Authority)
		{
			SetTimer(AmmoRegenRate, True, NameOf(RegenerateAmmo));
		}
	}
}

defaultproperties
{
	InstantHitDamage(0)=10.0
	WeaponRange=200.0
	AmmoCount=100
	MaxAmmoCount=100
	AmmoPool=100
	AmmoRegenRate=0.5
}
