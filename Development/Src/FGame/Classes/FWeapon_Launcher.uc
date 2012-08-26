/**
 * Base class for launcher-type infantry weapons.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FWeapon_Launcher extends FWeapon;

DefaultProperties
{
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponProjectiles(0)=class'UTProj_Rocket'
	AmmoCount=1
	MaxAmmoCount=1
	AmmoPool=5
}
