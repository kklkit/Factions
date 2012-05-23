/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FWeaponAttachment extends Actor
	dependson(FWeaponInfo)
	abstract;

var SkeletalMeshComponent Mesh;
var name MuzzleSocket;
var WeaponInfo WeaponInfo;

simulated function AttachTo(FPawn TargetPawn)
{
	Mesh.SetSkeletalMesh(SkeletalMesh(DynamicLoadObject(WeaponInfo.Mesh, class'SkeletalMesh')));
	if (TargetPawn.Mesh != None && Mesh != None)
	{
		Mesh.SetScale(WeaponInfo.DrawScale);
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

	PlayRecoil();
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

	if (MuzzleSocket != 'None')
	{
		Mesh.GetSocketWorldLocationAndRotation(MuzzleSocket, SocketLocation);
		return SocketLocation;
	}
	else
	{
		return Mesh.Bounds.Origin + (vect(45,0,0) >> Instigator.Rotation);
	}
}

defaultproperties
{
	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
	End Object
	Mesh=SkeletalMeshComponent0

	bReplicateInstigator=True
	MuzzleSocket=Muzzle
	NetUpdateFrequency=10.0
	TickGroup=TG_DuringAsyncWork
	RemoteRole=ROLE_None
}