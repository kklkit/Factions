class EmpHUD extends UDKHUD;

var Material MinimapMaterial;

function DrawHud()
{
	local Actor LevelActor;

	super.DrawHud();

	Canvas.SetPos(Canvas.ClipX-256-10, 10);
	Canvas.DrawMaterialTile(MinimapMaterial, 256, 256, 0, 0, 1, 1);
	Canvas.SetDrawColor(0, 255, 0);

	ForEach DynamicActors(class'Actor', LevelActor)
	{
		Canvas.SetPos(LevelActor.Location.X / 40000 * 256 + Canvas.ClipX - 128 - 10 - 5, LevelActor.Location.Y / 40000 * 256 + 10 + 128 - 5);
		Canvas.DrawBox(10, 10);
	}
}

defaultproperties
{
	MinimapMaterial=Material'EmpAssets.HUD.minimap_render'
}