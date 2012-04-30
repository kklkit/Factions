/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSWeap_AssaultRifle extends FSWeap_Firearm;

defaultproperties
{
	Begin Object Name=PickupMeshComponent
		SkeletalMesh=SkeletalMesh'FSAssets.Equipment.SK_WP_AssaultRifle'
	End Object

	AttachmentClass=class'FSAttachment_AssaultRifle'
}
