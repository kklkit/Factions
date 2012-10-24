class FWeapon_RocketLauncher extends FWeapon;

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

/**
 * @extends
 */
simulated event ReplicatedEvent(name VarName)
{
	Super.ReplicatedEvent(VarName);

	if (VarName == 'AmmoCount')
	{
		if (AmmoCount>0)
			attachRocket();
	}	
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
