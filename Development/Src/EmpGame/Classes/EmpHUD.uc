class EmpHUD extends UDKHUD;

var Material MinimapMaterial;

function DrawHud()
{
	local Actor LevelActor;
	local UDKVehicle LevelVehicle;
	local Vector LocalCoords;
	local Vector CameraLocation;
	local Rotator CameraRotation;
	local float ActualUnitPositionX, ActualUnitPositionY, GroundUnitPositionX, GroundUnitPositionY;
	local Color LineColor;
	local int MinimapOffset, MinimapSize, CameraHeight;

	super.DrawHud();

	CameraHeight = 40000;
	MinimapSize = 256;
	MinimapOffset = 10;

	Canvas.SetPos(Canvas.ClipX-256-10, 10);
	Canvas.DrawMaterialTile(MinimapMaterial, 256, 256, 0, 0, 1, 1);

	Canvas.bCenter = true;
	Canvas.SetDrawColor(0, 255, 0);
	
	ForEach DynamicActors(class'Actor', LevelActor)
	{
		if (UDKVehicle(LevelActor) != None || EmpActorInterface(LevelActor) != None || Projectile(LevelActor) != None)
		{
			if (UDKVehicle(LevelActor) != None && PlayerOwner != None && PlayerOwner.Pawn != None)
			{
				LevelVehicle = UDKVehicle(LevelActor);

				PlayerOwner.GetPlayerViewPoint(CameraLocation, CameraRotation);
				if (Normal(LevelVehicle.Location - PlayerOwner.Pawn.Location) dot Vector(CameraRotation) >= 0.f)
				{
					LocalCoords = Canvas.Project(LevelVehicle.Location);
					Canvas.SetPos(LocalCoords.X, LocalCoords.Y);
					Canvas.DrawText("Health:" @ LevelVehicle.Health);
				}
			}
			GroundUnitPositionX = LevelActor.Location.X / CameraHeight * MinimapSize + Canvas.ClipX - MinimapOffset - (MinimapSize / 2);
			GroundUnitPositionY = LevelActor.Location.Y / CameraHeight * MinimapSize + MinimapOffset + (MinimapSize / 2);
			ActualUnitPositionX = LevelActor.Location.X / (CameraHeight - LevelActor.Location.Z * 2) * MinimapSize + Canvas.ClipX - MinimapOffset - (MinimapSize / 2);
			ActualUnitPositionY = LevelActor.Location.Y / (CameraHeight - LevelActor.Location.Z * 2) * MinimapSize + MinimapOffset + (MinimapSize / 2);
			Canvas.SetPos(ActualUnitPositionX - 5, ActualUnitPositionY - 5);
			Canvas.DrawBox(10, 10);
			LineColor.A = 255;
			LineColor.B = 0;
			LineColor.G = 255;
			LineColor.R = 0;
			Canvas.Draw2DLine(GroundUnitPositionX, GroundUnitPositionY, ActualUnitPositionX, ActualUnitPositionY, LineColor);
		}
	}
}

defaultproperties
{
	MinimapMaterial=Material'EmpAssets.HUD.minimap_render'
}