class EmpPawn extends UDKPawn;

var SceneCapture2DComponent MinimapCaptureComponent;

event PostBeginPlay()
{
	MinimapCaptureComponent = new(self) class'SceneCapture2DComponent';
	MinimapCaptureComponent.SetCaptureParameters(TextureRenderTarget2D'EmpAssets.HUD.minimap_render_texture', , , 0);
	MinimapCaptureComponent.bUpdateMatrices = false;
	AttachComponent(MinimapCaptureComponent);
}

event Tick(float DeltaTime)
{
	MinimapCaptureComponent.SetView(vect(0, 0, 20000), rot(-16384, -16384, 0));
}

defaultproperties
{
}