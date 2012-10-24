class FWeaponAttachment_Healer extends FWeaponAttachment;

var class<UDKExplosionLight> ImpactLightClass;

/**
 * @extends
 */
simulated function FirstPersonFireEffects(Weapon PawnWeapon, Vector HitLocation)
{
	local vector EffectLocation;

	Super.FirstPersonFireEffects(PawnWeapon, HitLocation);

	if (Instigator.FiringMode == 0)
	{
		EffectLocation = FWeapon(PawnWeapon).GetEffectLocation();

		if (!WorldInfo.bDropDetail && Instigator.Controller != None)
		{
			UDKEmitterPool(WorldInfo.MyEmitterPool).SpawnExplosionLight(ImpactLightClass, EffectLocation);
		}
	}
}

defaultproperties
{
	ImpactLightClass=class'UTShockImpactLight'
}
