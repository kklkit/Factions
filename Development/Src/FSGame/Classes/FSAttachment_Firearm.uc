/**
 * Physical model and effects for infantry weapons.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSAttachment_Firearm extends FSWeaponAttachment;

var ParticleSystem BeamTemplate;
var int CurrentPath;

simulated function SpawnBeam(Vector Start, Vector End, bool bFirstPerson)
{
	local ParticleSystemComponent E;
	local Actor HitActor;
	local Vector HitNormal, HitLocation;

	if (End == Vect(0,0,0))
	{
		if (!bFirstPerson || (Instigator.Controller == none))
	    	return;

		End = Start + Vector(Instigator.Controller.Rotation) * class'FSWeap_Firearm'.default.WeaponRange;
		HitActor = Instigator.Trace(HitLocation, HitNormal, End, Start, true, vect(0,0,0), , TRACEFLAG_Bullet);
		if (HitActor != none)
			End = HitLocation;
	}

	E = WorldInfo.MyEmitterPool.SpawnEmitter(BeamTemplate, Start);
	E.SetVectorParameter('Target', End);
	if (bFirstPerson && !class'Engine'.static.IsSplitScreen())
		E.SetDepthPriorityGroup(SDPG_Foreground);
	else
		E.SetDepthPriorityGroup(SDPG_World);
}

simulated function FirstPersonFireEffects(Weapon PawnWeapon, Vector HitLocation)
{
	local Vector EffectLocation;

	super.FirstPersonFireEffects(PawnWeapon, HitLocation);

	EffectLocation = GetEffectLocation();
	SpawnBeam(EffectLocation, HitLocation, true);
}

simulated function ThirdPersonFireEffects(Vector HitLocation)
{
	super.ThirdPersonFireEffects(HitLocation);

	SpawnBeam(GetEffectLocation(), HitLocation, false);
}

//@todo Implement muzzle flash
simulated function SetMuzzleFlashParams(ParticleSystemComponent PSC)
{
	local float PathValues[3];
	local int NewPath;
	Super.SetMuzzleFlashparams(PSC);
	if (Instigator.FiringMode == 0)
	{
		NewPath = Rand(3);
		if (NewPath == CurrentPath)
		{
			NewPath++;
		}
		CurrentPath = NewPath % 3;

		PathValues[CurrentPath % 3] = 1.0;
		PSC.SetFloatParameter('Path1',PathValues[0]);
		PSC.SetFloatParameter('Path2',PathValues[1]);
		PSC.SetFloatParameter('Path3',PathValues[2]);
//			CurrentPath++;
	}
	else if (Instigator.FiringMode == 3)
	{
		PSC.SetFloatParameter('Path1',1.0);
		PSC.SetFloatParameter('Path2',1.0);
		PSC.SetFloatParameter('Path3',1.0);
	}
	else
	{
		PSC.SetFloatParameter('Path1',0.0);
		PSC.SetFloatParameter('Path2',0.0);
		PSC.SetFloatParameter('Path3',0.0);
	}
}

defaultproperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'FSAssets.Equipment.SK_HeavyRifle'
	End Object

	BeamTemplate=ParticleSystem'FSAssets.Particles.P_BulletTrail'
	
	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_3P_MF
	MuzzleFlashAltPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_3P_MF
	MuzzleFlashColor=(R=255,G=120,B=255,A=255)
	MuzzleFlashDuration=0.33;
	MuzzleFlashLightClass=class'UTGame.UTShockMuzzleFlashLight'
}
