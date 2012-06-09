/**
 * Physical equipment attachment used for viewing equipment on other pawns.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FWeaponAttachment extends Actor;

// Third person mesh
var() SkeletalMeshComponent Mesh;

// Name of the socket used to attach muzzle effects
var() name MuzzleSocketName;

/**
 * Attaches this weapon attachment to the given pawn.
 */
simulated function AttachTo(FPawn Pawn)
{
	if (Mesh != None && Pawn.Mesh != None)
	{
		Mesh.SetShadowParent(Pawn.Mesh);
		Mesh.SetLightEnvironment(Pawn.LightEnvironment);
		Pawn.Mesh.AttachComponentToSocket(Mesh, Pawn.WeaponSocketName);
	}
}

/**
 * Detaches this weapon attachment from the given pawn.
 */
simulated function DetachFrom(SkeletalMeshComponent MeshComponent)
{
	if (Mesh != None && MeshComponent != None)
	{
		Mesh.SetShadowParent(None);
		Mesh.SetLightEnvironment(None);
		MeshComponent.DetachComponent(Mesh);
	}
}

/**
 * Play the first-person firing effects.
 */
simulated function FirstPersonFireEffects(Weapon PawnWeapon, Vector HitLocation)
{
	if (PawnWeapon != None)
		PawnWeapon.PlayFireEffects(Pawn(Owner).FiringMode, HitLocation);
}

/**
 * Stop playing the first-person firing effects.
 */
simulated function StopFirstPersonFireEffects(Weapon PawnWeapon)
{
	if (PawnWeapon != None)
		PawnWeapon.StopFireEffects(Pawn(Owner).FiringMode);
}

/**
 * Play the third-person firing effects.
 */
simulated function ThirdPersonFireEffects(Vector HitLocation)
{
	PlayRecoil();
}

/**
 * Stop playing the third-person firing effects.
 */
simulated function StopThirdPersonFireEffects();

/**
 * Play the recoil effect on the weapon attachment.
 */
simulated function PlayRecoil()
{
	local FPawn InstigatorPawn;

	InstigatorPawn = FPawn(Instigator);

	if (InstigatorPawn != None && InstigatorPawn.GunRecoilNode != None)
		InstigatorPawn.GunRecoilNode.bPlayRecoil = True;
}

/**
 * Sets the visibility of the weapon attachment.
 */
simulated function ChangeVisibility(bool bIsVisible)
{
	if (Mesh != None)
		Mesh.SetHidden(!bIsVisible);
}

/**
 * Returns the location for firing effects.
 */
simulated function Vector GetEffectLocation()
{
	local Vector SocketLocation;

	if (MuzzleSocketName != 'None')
	{
		Mesh.GetSocketWorldLocationAndRotation(MuzzleSocketName, SocketLocation);
		return SocketLocation;
	}
	else
	{
		return Mesh.Bounds.Origin + (vect(45,0,0) >> Instigator.Rotation);
	}
}

defaultproperties
{
	Begin Object Class=UDKSkeletalMeshComponent Name=SkeletalMeshComponent0
		bOwnerNoSee=True
	End Object
	Mesh=SkeletalMeshComponent0

	bReplicateInstigator=True
	MuzzleSocketName=Muzzle
	NetUpdateFrequency=10.0
	TickGroup=TG_DuringAsyncWork
	RemoteRole=ROLE_None
}