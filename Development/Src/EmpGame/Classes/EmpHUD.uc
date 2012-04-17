class EmpHUD extends UDKHUD;

var Material MinimapMaterial;

function DrawHud()
{
	local Actor LevelActor;
	local UTVehicle_Scorpion_Content LevelVehicle;
	local Vector LocalCoords;

	super.DrawHud();

	Canvas.SetPos(Canvas.ClipX-256-10, 10);
	Canvas.DrawMaterialTile(MinimapMaterial, 256, 256, 0, 0, 1, 1);
	
	ForEach DynamicActors(class'Actor', LevelActor)
	{
		if (UTVehicle_Scorpion_Content(LevelActor) != None)
		{
			LevelVehicle = UTVehicle_Scorpion_Content(LevelActor);
			LocalCoords = Canvas.Project(LevelVehicle.Location);
			Canvas.SetPos(LocalCoords.X, LocalCoords.Y);
			Canvas.DrawText("Health:" @ LevelVehicle.Health);
		}
		Canvas.SetPos(LevelActor.Location.X / 40000 * 256 + Canvas.ClipX - 128 - 10 - 5, LevelActor.Location.Y / 40000 * 256 + 10 + 128 - 5);
		Canvas.DrawBox(10, 10);
	}
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	Canvas.bCenter = true;
	Canvas.SetDrawColor(255, 255, 255);
}

defaultproperties
{
	MinimapMaterial=Material'EmpAssets.HUD.minimap_render'
}