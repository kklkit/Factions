/**
 * Base class for launcher-type infantry weapons.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FWeapon_Launcher extends FWeapon;

var SkeletalMeshComponent RocketSkeletalMesh;


/**
 * @extends
 */
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	AttachRocket();
}

/**
 * @extends
 */
simulated function FireAmmunition()
{
	Super.FireAmmunition();
	DetachRocket();	
}

/**
 * @extends
 */
reliable server function ServerReload()
{
	Super.ServerReload();
	AttachRocket();
}

/**
 * Attach rocket to the weapon's mesh
 */
simulated function AttachRocket()
{
	if (Mesh != none && RocketSkeletalMesh != none)
		UDKSkeletalMeshComponent(Mesh).AttachComponentToSocket(RocketSkeletalMesh,'RocketSocket');
}

/**
 * Detach rocket from the weapon's mesh
 */
simulated function DetachRocket()
{
	if (RocketSkeletalMesh != none)
		UDKSkeletalMeshComponent(Mesh).DetachComponent(RocketSkeletalMesh);
}

DefaultProperties
{
	Begin Object Class=SkeletalMeshComponent Name=RocketSKMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		SkeletalMesh=SkeletalMesh'WP_RPG.Mesh.SK_WP_RPG_Rocket_Mash'
	End Object
	RocketSkeletalMesh=RocketSKMesh

	WeaponFireTypes(0)=EWFT_Projectile
	WeaponProjectiles(0)=class'UTProj_Rocket'
	AmmoCount=1
	MaxAmmoCount=1
	AmmoPool=5
}
