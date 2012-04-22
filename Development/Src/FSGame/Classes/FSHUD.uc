/*
 * Manages displaying the player's HUD and GUI.
 */
class FSHUD extends HUD;

var FSGFxHUD GFxHUD;
var FSGFxOmniMenu GFxOmniMenu;

const MinimapSize=256;
const MinimapUnitBoxSize=10;
var Material MinimapMaterial;
var Vector2d MinimapPadding;

var Color LineColor;

const CameraHeight=40000;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	MinimapPadding = vect2d(10, 55);

	GFxHUD = new class'FSGFxHUD';
	GFxHUD.Init();

	GFxOmniMenu = new class'FSGFxOmniMenu';
	GFxOmniMenu.Init();

	LineColor.A = 255;
	LineColor.B = 0;
	LineColor.G = 255;
	LineColor.R = 0;
}

function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (PlayerOwner != None && PlayerOwner.Pawn != None)
	{
		GFxHUD.SetPlayerHealth(PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax);
		GFxOmniMenu.SetPlayerTeam(PlayerOwner.Pawn.PlayerReplicationInfo.Team.TeamIndex);
	}
	else
	{
		GFxHUD.SetPlayerHealth(0, 1);
	}
}

function DrawHud()
{
	local FSPlayerController FSPlayer;
	local Actor LevelActor;
	local float UnitPositionX, UnitPositionY, UnitGroundPositionX, UnitGroundPositionY;
	
	super.DrawHud();

	FSPlayer = FSPlayerController(PlayerOwner);
	if (FSPlayer != none && !FSPlayer.bViewingMap)
	{
		Canvas.SetPos(Canvas.ClipX - MinimapSize - MinimapPadding.X, MinimapPadding.Y);
		Canvas.DrawMaterialTile(MinimapMaterial, MinimapSize, MinimapSize, 0, 0, 1, 1);

		Canvas.SetDrawColor(0, 255, 0);
		ForEach DynamicActors(class'Actor', LevelActor)
		{
			if (FSActorInterface(LevelActor) != None || Projectile(LevelActor) != None || UDKVehicle(LevelActor) != None)
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

exec function ToggleOmniMenu()
{
	if (GFxOmniMenu.bMovieIsOpen)
	{
		GFxOmniMenu.Close(false);
	}
	else
	{
		GFxOmniMenu.Start(false);
	}
}

defaultproperties
{
	MinimapMaterial=Material'FSAssets.HUD.minimap_render'
}