class FWeaponAttachment_Firearm extends FWeaponAttachment;

var ParticleSystem BeamTemplate;
var class<UDKExplosionLight> ImpactLightClass;

/**
 * Spawns a beam effect.
 */
simulated function SpawnBeam(vector Start, vector End, bool bFirstPerson)
{
	local ParticleSystemComponent E;

	E = WorldInfo.MyEmitterPool.SpawnEmitter(BeamTemplate, Start);
	E.SetVectorParameter('ShockBeamEnd', End);

	if (bFirstPerson && !class'Engine'.static.IsSplitScreen())
	{
		E.SetDepthPriorityGroup(SDPG_Foreground);
	}
	else
	{
		E.SetDepthPriorityGroup(SDPG_World);
	}
}

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
		SpawnBeam(EffectLocation, HitLocation, True);

		if (!WorldInfo.bDropDetail && Instigator.Controller != None)
		{
			UDKEmitterPool(WorldInfo.MyEmitterPool).SpawnExplosionLight(ImpactLightClass, HitLocation);
		}
	}
}

/**
 * @extends
 */
simulated function ThirdPersonFireEffects(Vector HitLocation)
{
	Super.ThirdPersonFireEffects(HitLocation);

	if (Instigator.FiringMode == 0)
	{
		SpawnBeam(GetEffectLocation(), HitLocation, False);
	}
}

defaultproperties
{
	BeamTemplate=ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_2ndPrim_Beam'
	ImpactLightClass=class'UTShockImpactLight'
}
