/**
 * Client-side weapon attachment.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSWeaponAttachment extends Actor
	abstract;

var SkeletalMeshComponent Mesh;
var name MuzzleFlashSocket;

simulated function AttachTo(FSPawn TargetPawn)
{
	if (TargetPawn.Mesh != None && Mesh != None)
	{
		Mesh.SetShadowParent(TargetPawn.Mesh);
		Mesh.SetLightEnvironment(TargetPawn.LightEnvironment);

		TargetPawn.Mesh.AttachComponentToSocket(Mesh, TargetPawn.WeaponSocket);
	}
}

simulated function DetachFrom(SkeletalMeshComponent TargetMeshComponent)
{
	if (TargetMeshComponent != None && Mesh != None)
	{
		Mesh.SetShadowParent(None);
		Mesh.SetLightEnvironment(None);
		TargetMeshComponent.DetachComponent(Mesh);
	}
}

simulated function FirstPersonFireEffects(Weapon PawnWeapon, Vector HitLocation)
{
	if (PawnWeapon != None)
		PawnWeapon.PlayFireEffects(Pawn(Owner).FiringMode, HitLocation);
}

simulated function StopFirstPersonFireEffects(Weapon PawnWeapon)
{
	if (PawnWeapon != None)
		PawnWeapon.StopFireEffects(Pawn(Owner).FiringMode);
}

simulated function ThirdPersonFireEffects(Vector HitLocation)
{
	local FSPawn InstigatorPawn;

	InstigatorPawn = FSPawn(Instigator);

	if (InstigatorPawn != None && InstigatorPawn.GunRecoilNode != None)
		InstigatorPawn.GunRecoilNode.bPlayRecoil = true;
}

simulated function StopThirdPersonFireEffects();

simulated function ChangeVisibility(bool bIsVisible)
{
	if (Mesh != None)
		Mesh.SetHidden(!bIsVisible);
}

simulated function FireModeUpdated(byte FiringMode, bool bViaReplication);

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
		CastShadow=true
		bCastDynamicShadow=true
		bPerBoneMotionBlur=true
	End Object
	Mesh=SkeletalMeshComponent0

	bReplicateInstigator=true

	NetUpdateFrequency=10
	TickGroup=TG_DuringAsyncWork
	RemoteRole=ROLE_None
}