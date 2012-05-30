/**
 * Weapon attachment for infantry guns.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FWeaponAttachment_Firearm extends FWeaponAttachment;

var ParticleSystem BulletTrail;

simulated function FirstPersonFireEffects(Weapon PawnWeapon, Vector HitLocation)
{
	Super.FirstPersonFireEffects(PawnWeapon, HitLocation);

	SpawnBulletTrail(GetEffectLocation(), HitLocation);
}

simulated function ThirdPersonFireEffects(Vector HitLocation)
{
	Super.ThirdPersonFireEffects(HitLocation);

	SpawnBulletTrail(GetEffectLocation(), HitLocation);
}

simulated function SpawnBulletTrail(Vector Start, Vector End)
{
	local ParticleSystemComponent BulletTrailEmitter;

	BulletTrailEmitter = WorldInfo.MyEmitterPool.SpawnEmitter(BulletTrail, Start);
	BulletTrailEmitter.SetVectorParameter('Target', End);
}

defaultproperties
{
	BulletTrail=ParticleSystem'Factions_Assets.Particles.P_BulletTrail'
}
