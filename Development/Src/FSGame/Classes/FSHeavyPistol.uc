class FSHeavyPistol extends FSWeapon;

defaultproperties
{
	begin object class=AnimNodeSequence Name=MeshSequenceA
		bCauseActorAnimEnd=true
	end object

	Begin Object Class=UDKSkeletalMeshComponent Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_1P'
		AnimSets(0)=AnimSet'WP_ShockRifle.Anim.K_WP_ShockRifle_1P_Base'
		Animations=MeshSequenceA
		Rotation=(Yaw=-16384)
		FOV=60.0
	End Object
	Mesh=FirstPersonMesh

	Begin Object Class=SkeletalMeshComponent Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_3P'
	End Object
	DroppedPickupMesh=PickupMesh

	WeaponFireTypes(0)=EWFT_InstantHit
}
