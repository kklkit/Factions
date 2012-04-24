class FSWeapon extends UDKWeapon
	dependson(FSPlayerController)
	config(WeaponFS)
	abstract;

simulated event SetPosition(UDKPawn Holder)
{
	SetLocation(Holder.Location);
	SetRotation(Holder.Rotation);
	SetBase(Holder);
}

simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional name SocketName)
{
	super.AttachWeaponTo(MeshCpnt, SocketName);

	AttachComponent(Mesh);
	SetHidden(false);
}

simulated function TimeWeaponEquipping()
{
	AttachWeaponTo(Instigator.Mesh);

	super.TimeWeaponEquipping();
}

defaultproperties
{
}
