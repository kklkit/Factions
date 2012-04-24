class FSWeaponAttachment extends Actor
	abstract
	dependson(FSPawn);

var SkeletalMeshComponent Mesh;

var SkeletalMeshComponent OwnerMesh;
var Name AttachmentSocket;

simulated function AttachTo(FSPawn OwnerPawn)
{
	if (OwnerPawn.Mesh != None && Mesh != None)
	{
		OwnerMesh = OwnerPawn.Mesh;
		AttachmentSocket = OwnerPawn.WeaponSocket;

		Mesh.SetShadowParent(OwnerPawn.Mesh);
		Mesh.SetLightEnvironment(OwnerPawn.LightEnvironment);

		OwnerPawn.Mesh.AttachComponentToSocket(Mesh, OwnerPawn.WeaponSocket);
	}

	GotoState('CurrentlyAttached');
}

simulated function FirstPersonFireEffects(FSWeapon PawnWeapon, Vector HitLocation)
{
	if (PawnWeapon != none)
	{
		PawnWeapon.PlayFireEffects(FSPawn(Owner).FiringMode, HitLocation);
	}
}

simulated function ChangeVisibility(bool bIsVisible)
{
	if (Mesh != none)
		Mesh.SetHidden(!bIsVisible);
}

state CurrentlyAttached
{
}

defaultproperties
{
	begin object class=AnimNodeSequence Name=MeshSequenceA
	end object

	begin object class=SkeletalMeshComponent Name=SkeletalMeshComponent0
		bOwnerNoSee=false
		bOnlyOwnerSee=false
		CollideActors=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		MaxDrawDistance=4000
		bForceRefPose=1
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=false
		Animations=MeshSequenceA
		CastShadow=true
		bCastDynamicShadow=true
		bPerBoneMotionBlur=true
	end object
	Mesh=SkeletalMeshComponent0

	TickGroup=TG_DuringAsyncWork
	NetUpdateFrequency=10
	RemoteRole=ROLE_None
	bReplicateInstigator=true
}