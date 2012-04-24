class FSWeapon extends UDKWeapon
	dependson(FSPlayerController)
	config(WeaponFS)
	abstract;

var class<FSWeaponAttachment> AttachmentClass;

simulated event SetPosition(UDKPawn Holder)
{
	SetLocation(Holder.Location);
	SetRotation(Holder.Rotation);
	SetBase(Holder);
}

simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional name SocketName)
{
	local FSPawn FSP;

	super.AttachWeaponTo(MeshCpnt, SocketName);

	FSP = FSPawn(Instigator);

	AttachComponent(Mesh);
	SetHidden(false);

	if (Role == ROLE_Authority && FSP != none)
	{
		FSP.CurrentWeaponAttachmentClass = AttachmentClass;
		if (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || (WorldInfo.NetMode == NM_Client && Instigator.IsLocallyControlled()))
		{
			FSP.WeaponAttachmentChanged();
		}
	}
}

simulated function TimeWeaponEquipping()
{
	AttachWeaponTo(Instigator.Mesh);

	super.TimeWeaponEquipping();
}

defaultproperties
{
}
