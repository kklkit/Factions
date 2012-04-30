/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSAttachment_Firearm extends FSWeaponAttachment;

var ParticleSystem BeamTemplate;
var int CurrentPath;

simulated function FirstPersonFireEffects(Weapon PawnWeapon, Vector HitLocation)
{
	local Vector EffectLocation;

	Super.FirstPersonFireEffects(PawnWeapon, HitLocation);

	EffectLocation = GetEffectLocation();
	SpawnBeam(EffectLocation, HitLocation, true);
}

simulated function ThirdPersonFireEffects(Vector HitLocation)
{
	Super.ThirdPersonFireEffects(HitLocation);

	SpawnBeam(GetEffectLocation(), HitLocation, false);
}

simulated function SpawnBeam(Vector Start, Vector End, bool bFirstPerson)
{
	local ParticleSystemComponent E;
	local Actor HitActor;
	local Vector HitNormal, HitLocation;

	if (End == Vect(0,0,0))
	{
		if (!bFirstPerson || (Instigator.Controller == None))
	    	return;

		End = Start + Vector(Instigator.Controller.Rotation) * class'FSWeap_Firearm'.default.WeaponRange;
		HitActor = Instigator.Trace(HitLocation, HitNormal, End, Start, true, vect(0,0,0), , TRACEFLAG_Bullet);
		if (HitActor != None)
			End = HitLocation;
	}

	E = WorldInfo.MyEmitterPool.SpawnEmitter(BeamTemplate, Start);
	E.SetVectorParameter('Target', End);
	if (bFirstPerson && !class'Engine'.static.IsSplitScreen())
		E.SetDepthPriorityGroup(SDPG_Foreground);
	else
		E.SetDepthPriorityGroup(SDPG_World);
}

defaultproperties
{
	Begin Object Name=AttachmentMeshComponent
		SkeletalMesh=SkeletalMesh'FSAssets.Equipment.SK_WP_AssaultRifle'
	End Object

	BeamTemplate=ParticleSystem'FSAssets.Particles.P_BulletTrail'
}
