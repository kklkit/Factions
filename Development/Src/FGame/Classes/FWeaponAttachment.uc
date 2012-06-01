/**
 * Physical equipment attachment used for viewing equipment on other pawns.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FWeaponAttachment extends Actor;

var() SkeletalMeshComponent Mesh;
var() name MuzzleSocketName;

simulated function AttachTo(FPawn Pawn)
{
	if (Mesh != None && Pawn.Mesh != None)
	{
		Mesh.SetShadowParent(Pawn.Mesh);
		Mesh.SetLightEnvironment(Pawn.LightEnvironment);
		Pawn.Mesh.AttachComponentToSocket(Mesh, Pawn.WeaponSocketName);
	}
}

simulated function DetachFrom(SkeletalMeshComponent MeshComponent)
{
	if (Mesh != None && MeshComponent != None)
	{
		Mesh.SetShadowParent(None);
		Mesh.SetLightEnvironment(None);
		MeshComponent.DetachComponent(Mesh);
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
	PlayRecoil();
}

simulated function StopThirdPersonFireEffects();

simulated function PlayRecoil()
{
	local FPawn InstigatorPawn;

	InstigatorPawn = FPawn(Instigator);

	if (InstigatorPawn != None && InstigatorPawn.GunRecoilNode != None)
		InstigatorPawn.GunRecoilNode.bPlayRecoil = True;
}

simulated function ChangeVisibility(bool bIsVisible)
{
	if (Mesh != None)
		Mesh.SetHidden(!bIsVisible);
}

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