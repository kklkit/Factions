/**
 * Client-side weapon actor that is attached to the Pawn.
 */
class FSWeaponAttachment extends Actor
	abstract
	dependson(FSPawn);

var SkeletalMeshComponent Mesh;
var SkeletalMeshComponent OwnerMesh;

var name AttachmentSocket;

/**
 * Attaches the weapon to the given Pawn.
 */
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

/**
 * Detaches the weapon from the skeletal mesh.
 */
simulated function DetachFrom(SkeletalMeshComponent MeshCpnt)
{
	if (Mesh != None)
	{
		Mesh.SetShadowParent(None);
		Mesh.SetLightEnvironment(None);
	}
	if (MeshCpnt != None)
	{
		if (Mesh != None)
		{
			MeshCpnt.DetachComponent(Mesh);
		}
	}

	GotoState('');
}

/**
 * Show or hide the weapon mesh.
 */
simulated function ChangeVisibility(bool bIsVisible)
{
	if (Mesh != none)
		Mesh.SetHidden(!bIsVisible);
}

simulated function FireModeUpdated(byte FiringMode, bool bViaReplication);

simulated function SetPuttingDownWeapon(bool bNowPuttingDown);

state CurrentlyAttached
{
}

defaultproperties
{
	Begin Object Class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
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
	End Object
	Mesh=SkeletalMeshComponent0

	TickGroup=TG_DuringAsyncWork
	NetUpdateFrequency=10
	RemoteRole=ROLE_None
	bReplicateInstigator=true
}