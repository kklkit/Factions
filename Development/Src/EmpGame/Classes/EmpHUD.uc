class EmpHUD extends UDKHUD;

var Material MinimapMaterial;

function DrawHud()
{
	super.DrawHud();
	Canvas.SetPos(Canvas.ClipX-256-10,10);
	Canvas.DrawMaterialTile(MinimapMaterial, 256, 256, 0, 0, 1, 1);
}

defaultproperties
{
	MinimapMaterial=Material'EmpAssets.HUD.minimap_render'
}