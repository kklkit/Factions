/**
 * Base weapon class.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSWeapon extends UDKWeapon
	dependson(FSPlayerController)
	config(WeaponFS)
	abstract;

var class<FSWeaponAttachment> AttachmentClass;

/**
 * @extends
 */
simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional name SocketName)
{
	local FSPawn FSP;

	super.AttachWeaponTo(MeshCpnt, SocketName);

	FSP = FSPawn(Instigator);

	//@todo enable if fake fps view is used
	// AttachComponent(Mesh);
	// SetHidden(false);

	if (Role == ROLE_Authority && FSP != None)
	{
		FSP.CurrentWeaponAttachmentClass = AttachmentClass;
		if (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || (WorldInfo.NetMode == NM_Client && Instigator.IsLocallyControlled()))
		{
			FSP.WeaponAttachmentChanged();
		}
	}
}

/**
 * @extends
 */
simulated function DetachWeapon()
{
	local FSPawn FSP;

	super.DetachWeapon();

	//@todo enable if fake fps view is used
	//DetachComponent(Mesh);
	//if (OverlayMesh != None)
	//{
	//	DetachComponent(OverlayMesh);
	//}

	FSP = FSPawn(Instigator);
	if (FSP != None)
	{
		if (Role == ROLE_Authority && FSP.CurrentWeaponAttachmentClass == AttachmentClass)
		{
			FSP.CurrentWeaponAttachmentClass = None;
			if (Instigator.IsLocallyControlled())
			{
				FSP.WeaponAttachmentChanged();
			}
		}
	}

	SetBase(None);
	//SetHidden(True);
	//Mesh.SetLightEnvironment(None);
}

/**
 * @extends
 */
simulated function TimeWeaponEquipping()
{
	AttachWeaponTo(Instigator.Mesh);

	super.TimeWeaponEquipping();
}

defaultproperties
{
}
