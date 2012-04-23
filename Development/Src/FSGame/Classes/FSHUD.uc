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
var float MapSize;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	GFxHUD = new class'FSGFxHUD';
	GFxHUD.Init();

	GFxOmniMenu = new class'FSGFxOmniMenu';
	GFxOmniMenu.Init();

	LineColor.A = 255;
	LineColor.B = 0;
	LineColor.G = 255;
	LineColor.R = 0;

	MapSize = FSMapInfo(WorldInfo.GetMapInfo()).MapRadius * 2;
}

function PostRender()
{
	Super.PostRender();

	if (PlayerOwner != None && PlayerOwner.Pawn != None)
	{
		GFxHUD.SetPlayerHealth(PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax);
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
				UnitPositionX = LevelActor.Location.X / (MapSize - LevelActor.Location.Z * 2) * MinimapSize + Canvas.ClipX - MinimapPadding.X - (MinimapSize / 2);
				UnitPositionY = LevelActor.Location.Y / (MapSize - LevelActor.Location.Z * 2) * MinimapSize + MinimapPadding.Y + (MinimapSize / 2);
				UnitGroundPositionX = LevelActor.Location.X / MapSize * MinimapSize + Canvas.ClipX - MinimapPadding.X - (MinimapSize / 2);
				UnitGroundPositionY = LevelActor.Location.Y / MapSize * MinimapSize + MinimapPadding.Y + (MinimapSize / 2);
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

simulated function NotifyLocalPlayerTeamReceived()
{
	Super.NotifyLocalPlayerTeamReceived();

	GFxOmniMenu.UpdateTeam(PlayerOwner.PlayerReplicationInfo.Team.TeamIndex);
}

defaultproperties
{
	MinimapMaterial=Material'FSAssets.HUD.minimap_render'
	MinimapPadding=(X=10,Y=55)
}