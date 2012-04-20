/*
 * Manages displaying the player's HUD and GUI.
 */
class EmpHUD extends UDKHUD;

var EmpGFxHUD GFxHUD;
var EmpGFxHUDMenu GFxHUDMenu;

var Material MinimapMaterial;
var Vector2d MinimapPadding;
const MinimapSize=256;
const MinimapUnitBoxSize=10;

var Color LineColor;

const CameraHeight=40000;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	MinimapPadding = vect2d(10, 55);

	GFxHUD = new class'EmpGFxHUD';
	GFxHUD.Init();

	GFxHUDMenu = new class'EmpGFxHUDMenu';
	GFxHUDMenu.Init();

	LineColor.A = 255;
	LineColor.B = 0;
	LineColor.G = 255;
	LineColor.R = 0;
}

event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (PlayerOwner != None && PlayerOwner.Pawn != None)
	{
		GFxHUD.SetHealth(PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax);
	}
	else
	{
		GFxHUD.SetHealth(0, 1);
	}
}

function DrawHud()
{
	local EmpPlayerController EmpPlayer;
	local Actor LevelActor;
	local float UnitPositionX, UnitPositionY, UnitGroundPositionX, UnitGroundPositionY;
	
	super.DrawHud();

	EmpPlayer = EmpPlayerController(PlayerOwner);
	if (EmpPlayer != none && !EmpPlayer.bViewingMap)
	{
		Canvas.SetPos(Canvas.ClipX - MinimapSize - MinimapPadding.X, MinimapPadding.Y);
		Canvas.DrawMaterialTile(MinimapMaterial, MinimapSize, MinimapSize, 0, 0, 1, 1);

		Canvas.SetDrawColor(0, 255, 0);
		ForEach DynamicActors(class'Actor', LevelActor)
		{
			if (EmpActorInterface(LevelActor) != None || Projectile(LevelActor) != None || UDKVehicle(LevelActor) != None)
			{
				// Calculate the pixel positions to draw the unit on the minimap.
				UnitPositionX = LevelActor.Location.X / (CameraHeight - LevelActor.Location.Z * 2) * MinimapSize + Canvas.ClipX - MinimapPadding.X - (MinimapSize / 2);
				UnitPositionY = LevelActor.Location.Y / (CameraHeight - LevelActor.Location.Z * 2) * MinimapSize + MinimapPadding.Y + (MinimapSize / 2);
				UnitGroundPositionX = LevelActor.Location.X / CameraHeight * MinimapSize + Canvas.ClipX - MinimapPadding.X - (MinimapSize / 2);
				UnitGroundPositionY = LevelActor.Location.Y / CameraHeight * MinimapSize + MinimapPadding.Y + (MinimapSize / 2);
				Canvas.SetPos(UnitPositionX - (MinimapUnitBoxSize / 2), UnitPositionY - (MinimapUnitBoxSize / 2));
				Canvas.DrawBox(MinimapUnitBoxSize, MinimapUnitBoxSize);
				Canvas.Draw2DLine(UnitPositionX, UnitPositionY, UnitGroundPositionX, UnitGroundPositionY, LineColor);
			}
		}
	}
}

defaultproperties
{
	MinimapMaterial=Material'EmpAssets.HUD.minimap_render'
}