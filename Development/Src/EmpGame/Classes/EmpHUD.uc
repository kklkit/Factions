/*
 * Manages displaying the player's HUD and GUI.
 */
class EmpHUD extends UDKHUD;

var EmpGFxHUDTopLeft GFxHUDTopLeft;
var EmpGFxHUDTopRight GFxHUDTopRight;
var EmpGFxHUDBottomLeft GFxHUDBottomLeft;
var EmpGFxHUDBottomRight GFxHUDBottomRight;
var EmpGFxHUDMenu GFxHUDMenu;

var Material MinimapMaterial;
var Color LineColor;

const MinimapOffset=10;
const MinimapSize=256;
const CameraHeight=40000;
const MinimapBoxSize=10;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	GFxHUDTopLeft = new class'EmpGFxHUDTopLeft';
	GFxHUDTopLeft.Init();
	GFxHUDTopLeft.SetAlignment(Align_TopLeft);

	GFxHUDTopRight = new class'EmpGFxHUDTopRight';
	GFxHUDTopRight.Init();
	GFxHUDTopRight.SetAlignment(Align_TopRight);

	GFxHUDBottomLeft = new class'EmpGFxHUDBottomLeft';
	GFxHUDBottomLeft.Init();
	GFxHUDBottomLeft.SetAlignment(Align_BottomLeft);

	GFxHUDBottomRight = new class'EmpGFxHUDBottomRight';
	GFxHUDBottomRight.Init();
	GFxHUDBottomRight.SetAlignment(Align_BottomRight);

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
		GFxHUDBottomLeft.SetHealth(PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax);
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
		Canvas.SetPos(Canvas.ClipX - MinimapSize - MinimapOffset, MinimapOffset);
		Canvas.DrawMaterialTile(MinimapMaterial, MinimapSize, MinimapSize, 0, 0, 1, 1);

		Canvas.SetDrawColor(0, 255, 0);
		ForEach DynamicActors(class'Actor', LevelActor)
		{
			if (EmpActorInterface(LevelActor) != None || Projectile(LevelActor) != None || UDKVehicle(LevelActor) != None)
			{
				// Calculate the pixel positions to draw the unit on the minimap.
				UnitPositionX = LevelActor.Location.X / (CameraHeight - LevelActor.Location.Z * 2) * MinimapSize + Canvas.ClipX - MinimapOffset - (MinimapSize / 2);
				UnitPositionY = LevelActor.Location.Y / (CameraHeight - LevelActor.Location.Z * 2) * MinimapSize + MinimapOffset + (MinimapSize / 2);
				UnitGroundPositionX = LevelActor.Location.X / CameraHeight * MinimapSize + Canvas.ClipX - MinimapOffset - (MinimapSize / 2);
				UnitGroundPositionY = LevelActor.Location.Y / CameraHeight * MinimapSize + MinimapOffset + (MinimapSize / 2);
				Canvas.SetPos(UnitPositionX - (MinimapBoxSize / 2), UnitPositionY - (MinimapBoxSize / 2));
				Canvas.DrawBox(MinimapBoxSize, MinimapBoxSize);
				Canvas.Draw2DLine(UnitPositionX, UnitPositionY, UnitGroundPositionX, UnitGroundPositionY, LineColor);
			}
		}
	}
}

defaultproperties
{
	MinimapMaterial=Material'EmpAssets.HUD.minimap_render'
}