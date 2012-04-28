/**
 * Firearm-type weapon.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSWeap_Firearm extends FSWeapon;

defaultproperties
{
	AttachmentClass=class'FSGame.FSAttachment_Firearm'

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'FSAssets.Equipment.SK_HeavyRifle'
	End Object
}
