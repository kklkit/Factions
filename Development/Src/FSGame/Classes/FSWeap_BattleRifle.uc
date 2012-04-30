/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSWeap_BattleRifle extends FSWeap_Firearm;

defaultproperties
{
	Begin Object Name=PickupMeshComponent
		SkeletalMesh=SkeletalMesh'FSAssets.Equipment.SK_WP_BattleRifle'
	End Object

	AttachmentClass=class'FSAttachment_BattleRifle'
}
