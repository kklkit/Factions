class EmpPawn extends Pawn
	Implements(EmpActorInterface);

var SceneCapture2DComponent MinimapCaptureComponent;
var Vector MinimapCapturePosition;
var Rotator MinimapCaptureRotation;

const MinimapCaptureFOV=90; // This must be 90 degrees otherwise the minimap overlays will be incorrect.

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (WorldInfo.NetMode == NM_Client || WorldInfo.NetMode == NM_Standalone)
	{
		MinimapCaptureComponent = new class'SceneCapture2DComponent';
		MinimapCaptureComponent.SetCaptureParameters(TextureRenderTarget2D'EmpAssets.HUD.minimap_render_texture', MinimapCaptureFOV, , 0);
		MinimapCaptureComponent.bUpdateMatrices = false;
		AttachComponent(MinimapCaptureComponent);

		MinimapCapturePosition = vect(0, 0, 20000);
		MinimapCaptureRotation = rot(-16384, -16384, 0);
	}
}

function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (WorldInfo.NetMode == NM_Client || WorldInfo.NetMode == NM_Standalone)
	{
		MinimapCaptureComponent.SetView(MinimapCapturePosition, MinimapCaptureRotation);
	}
}

function bool CalcCamera(float fDeltaTime, out vector out_CamLoc, out Rotator out_CamRot, out float out_FOV)
{
	Mesh.GetSocketWorldLocationAndRotation('Eyes', out_CamLoc);
	out_CamRot = GetViewRotation();
	return true;
}

defaultproperties
{
	Components.Remove(Sprite);

	begin object Class=SkeletalMeshComponent Name=EmpSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'EmpAssets.Mesh.IronGuard'
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
	end object
	Mesh=EmpSkeletalMeshComponent
	Components.Add(EmpSkeletalMeshComponent)
}