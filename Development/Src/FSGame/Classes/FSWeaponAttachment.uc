/**
 * Client-side weapon attachment.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSWeaponAttachment extends Actor
	abstract
	dependson(FSPawn);

var SkeletalMeshComponent Mesh;

var name MuzzleFlashSocket;
var ParticleSystemComponent	MuzzleFlashPSC;
var ParticleSystem MuzzleFlashPSCTemplate, MuzzleFlashAltPSCTemplate;
var color MuzzleFlashColor;
var bool bMuzzleFlashPSCLoops;
var class<UDKExplosionLight> MuzzleFlashLightClass;
var	UDKExplosionLight MuzzleFlashLight;
var float MuzzleFlashDuration;
var SkeletalMeshComponent OwnerMesh;
var name AttachmentSocket;

var float MaxFireEffectDistance;

var name FireAnim, AltFireAnim;

state CurrentlyAttached
{
}

/**
 * Attaches the weapon to the given Pawn.
 */
simulated function AttachTo(FSPawn OwnerPawn)
{
	if (OwnerPawn.Mesh != None && Mesh != None)
	{
		OwnerMesh = OwnerPawn.Mesh;
		AttachmentSocket = OwnerPawn.WeaponSocket;

		Mesh.SetShadowParent(OwnerPawn.Mesh);
		Mesh.SetLightEnvironment(OwnerPawn.LightEnvironment);

		OwnerPawn.Mesh.AttachComponentToSocket(Mesh, OwnerPawn.WeaponSocket);
	}

	if (MuzzleFlashSocket != '')
	{
		if (MuzzleFlashPSCTemplate != None || MuzzleFlashAltPSCTemplate != None)
		{
			MuzzleFlashPSC = new(self) class'UDKParticleSystemComponent';
			MuzzleFlashPSC.bAutoActivate = false;
			MuzzleFlashPSC.SetOwnerNoSee(false);
			Mesh.AttachComponentToSocket(MuzzleFlashPSC, MuzzleFlashSocket);
		}
	}

	GotoState('CurrentlyAttached');
}

/**
 * Detaches the weapon from the skeletal mesh.
 */
simulated function DetachFrom(SkeletalMeshComponent MeshCpnt)
{
	if (Mesh != None)
	{
		Mesh.SetShadowParent(None);
		Mesh.SetLightEnvironment(None);
		if (MuzzleFlashPSC != None)
			Mesh.DetachComponent(MuzzleFlashPSC);
		if (MuzzleFlashLight != None)
			Mesh.DetachComponent(MuzzleFlashLight);
	}
	if (MeshCpnt != None)
	{
		if (Mesh != None)
		{
			MeshCpnt.DetachComponent(Mesh);
		}
	}

	GotoState('');
}

/**
 * Allows a child to setup custom parameters on the muzzle flash
 */
simulated function SetMuzzleFlashParams(ParticleSystemComponent PSC)
{
	PSC.SetColorParameter('MuzzleFlashColor', MuzzleFlashColor);
}

/**
 * Turns the MuzzleFlashlight off
 */
simulated function MuzzleFlashTimer()
{
	if ( MuzzleFlashLight != None )
		MuzzleFlashLight.SetEnabled(false);

	if (MuzzleFlashPSC != None && (!bMuzzleFlashPSCLoops) )
		MuzzleFlashPSC.DeactivateSystem();
}

/**
 * Causes the muzzle flash to turn on and setup a time to turn it back off again.
 */
simulated function CauseMuzzleFlash()
{
	local ParticleSystem MuzzleTemplate;

	if ((!WorldInfo.bDropDetail && !class'Engine'.static.IsSplitScreen()) || WorldInfo.IsConsoleBuild(CONSOLE_Mobile))
	{
		if (MuzzleFlashLight == None)
		{
			if (MuzzleFlashLightClass != None)
			{
				MuzzleFlashLight = new(Outer) MuzzleFlashLightClass;

				if (Mesh != None && Mesh.GetSocketByName(MuzzleFlashSocket) != None)
					Mesh.AttachComponentToSocket(MuzzleFlashLight, MuzzleFlashSocket);
				else if (OwnerMesh != None)
					OwnerMesh.AttachComponentToSocket(MuzzleFlashLight, AttachmentSocket);
			}
		}
		else
			MuzzleFlashLight.ResetLight();
	}

	if (MuzzleFlashPSC != None)
	{
		if (!bMuzzleFlashPSCLoops || !MuzzleFlashPSC.bIsActive)
		{
			if (Instigator != None && Instigator.FiringMode == 1 && MuzzleFlashAltPSCTemplate != None)
				MuzzleTemplate = MuzzleFlashAltPSCTemplate;
			else
				MuzzleTemplate = MuzzleFlashPSCTemplate;

			if (MuzzleTemplate != MuzzleFlashPSC.Template)
				MuzzleFlashPSC.SetTemplate(MuzzleTemplate);

			SetMuzzleFlashParams(MuzzleFlashPSC);
			MuzzleFlashPSC.ActivateSystem();
		}
	}

	SetTimer(MuzzleFlashDuration, false, 'MuzzleFlashTimer');
}

/**
 * Stops the muzzle flash.
 */
simulated function StopMuzzleFlash()
{
	ClearTimer('MuzzleFlashTimer');
	MuzzleFlashTimer();

	if (MuzzleFlashPSC != None)
	{
		MuzzleFlashPSC.DeactivateSystem();
	}
}

simulated function FirstPersonFireEffects(Weapon PawnWeapon, vector HitLocation)
{
	if (PawnWeapon != None)
		PawnWeapon.PlayFireEffects(Pawn(Owner).FiringMode, HitLocation);
}

simulated function StopFirstPersonFireEffects(Weapon PawnWeapon)
{
	if (PawnWeapon != None)
		PawnWeapon.StopFireEffects(Pawn(Owner).FiringMode);
}

simulated function ThirdPersonFireEffects(vector HitLocation)
{
	local FSPawn P;
	if (EffectIsRelevant(Location, false, MaxFireEffectDistance))
		CauseMuzzleFlash();

	P = FSPawn(Instigator);
	if (P != None && P.GunRecoilNode != None)
		P.GunRecoilNode.bPlayRecoil = true;

	if (Instigator.FiringMode == 1 && AltFireAnim != 'None')
		Mesh.PlayAnim(AltFireAnim, , , false);
	else if (FireAnim != 'None')
		Mesh.PlayAnim(FireAnim, , , false);
}

simulated function StopThirdPersonFireEffects()
{
	StopMuzzleFlash();
}

/**
 * Show or hide the weapon mesh.
 */
simulated function ChangeVisibility(bool bIsVisible)
{
	if (Mesh != None)
		Mesh.SetHidden(!bIsVisible);
}

/**
 * Called when the fire mode is updated.
 */
simulated function FireModeUpdated(byte FiringMode, bool bViaReplication);

/**
 * Called when the weapon is being put down.
 */
simulated function SetPuttingDownWeapon(bool bNowPuttingDown);

simulated function Vector GetEffectLocation()
{
	local Vector SocketLocation;

	if (MuzzleFlashSocket != 'None')
	{
		Mesh.GetSocketWorldLocationAndRotation(MuzzleFlashSocket, SocketLocation);
		return SocketLocation;
	}
	else
		return Mesh.Bounds.Origin + (vect(45,0,0) >> Instigator.Rotation);
}


defaultproperties
{
	Begin Object Class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
		bOwnerNoSee=false
		bOnlyOwnerSee=false
		CollideActors=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		MaxDrawDistance=4000
		bForceRefPose=1
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=false
		Animations=MeshSequenceA
		CastShadow=true
		bCastDynamicShadow=true
		bPerBoneMotionBlur=true
	End Object
	Mesh=SkeletalMeshComponent0

	TickGroup=TG_DuringAsyncWork
	NetUpdateFrequency=10
	RemoteRole=ROLE_None
	bReplicateInstigator=true
	MaxFireEffectDistance=5000.0
	MuzzleFlashDuration=0.3
	MuzzleFlashColor=(R=255,G=255,B=255,A=255)
}