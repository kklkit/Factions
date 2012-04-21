class EmpPawn extends UDKPawn
	Implements(EmpActorInterface);

var SceneCapture2DComponent MinimapCaptureComponent;
var Vector MinimapCapturePosition;
var Rotator MinimapCaptureRotation;

const MinimapCaptureFOV=90; // This must be 90 degrees otherwise the minimap overlays will be incorrect.

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	MinimapCaptureComponent = new class'SceneCapture2DComponent';
	MinimapCaptureComponent.SetCaptureParameters(TextureRenderTarget2D'EmpAssets.HUD.minimap_render_texture', MinimapCaptureFOV, , 0);
	MinimapCaptureComponent.bUpdateMatrices = false;
	AttachComponent(MinimapCaptureComponent);

	MinimapCapturePosition = vect(0, 0, 20000);
	MinimapCaptureRotation = rot(-16384, -16384, 0);
}

function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	MinimapCaptureComponent.SetView(MinimapCapturePosition, MinimapCaptureRotation);
}

defaultproperties
{
}