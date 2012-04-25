/**
 * Firearm-type weapon.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSWeap_Firearm extends FSWeapon;

defaultproperties
{
	Begin Object Class=UDKSkeletalMeshComponent Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_1P'
		AnimSets(0)=AnimSet'WP_ShockRifle.Anim.K_WP_ShockRifle_1P_Base'
		Animations=MeshSequenceA
		Rotation=(Yaw=-16384)
		Scale=0.9
		FOV=60.0
	End Object
	Mesh=FirstPersonMesh

	AttachmentClass=class'FSGame.FSAttachment_Firearm'

	Begin Object Class=SkeletalMeshComponent Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_3P'
		bOnlyOwnerSee=false
	End Object
	DroppedPickupMesh=PickupMesh
}
