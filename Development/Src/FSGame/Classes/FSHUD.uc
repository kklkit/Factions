/**
 * Manages the GFx movie clips and displaying the minimap.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSHUD extends HUD;

const MinimapSize=256;
const MinimapUnitBoxSize=10;

var FSGFxHUD GFxHUD;
var FSGFxOmniMenu GFxOmniMenu;

var Material MinimapMaterial;
var Vector2d MinimapPadding;

var float MapSize;

var Color LineColor;

/**
 * @extends
 */
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Initialize the GFx movie clips
	GFxHUD = new class'FSGFxHUD';
	GFxHUD.Init();

	GFxOmniMenu = new class'FSGFxOmniMenu';
	GFxOmniMenu.Init();

	// Set the map size for use by the minimap
	MapSize = FSMapInfo(WorldInfo.GetMapInfo()).MapRadius * 2;
}

/**
 * @extends
 */
function PostRender()
{
	Super.PostRender();

	//@todo this should use push notifications instead for better performance
	if (PlayerOwner != None && PlayerOwner.Pawn != None)
		GFxHUD.UpdateHealth(PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax);
	else
		GFxHUD.UpdateHealth(0, 1);
}

/**
 * @extends
 */
function DrawHud()
{
	local FSPlayerController FSPlayer;
	local Actor LevelActor;
	local float UnitPositionX, UnitPositionY, UnitGroundPositionX, UnitGroundPositionY; //@todo use vector2d instead
	
	super.DrawHud();

	FSPlayer = FSPlayerController(PlayerOwner);
	if (FSPlayer != none && !FSPlayer.bViewingMap)
	{
		// Draw the minimap
		//@todo this should be done in scaleform once the render texture crash is fixed
		Canvas.SetPos(Canvas.ClipX - MinimapSize - MinimapPadding.X, MinimapPadding.Y);
		Canvas.DrawMaterialTile(MinimapMaterial, MinimapSize, MinimapSize, 0, 0, 1, 1);

		// Draw actor overlays on the minimap
		Canvas.SetDrawColor(0, 255, 0);
		ForEach DynamicActors(class'Actor', LevelActor)
		{
			if (FSActorInterface(LevelActor) != None || Projectile(LevelActor) != None || UDKVehicle(LevelActor) != None)
			{
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

/**
 * Toggles opening and closing the menu.
 */
exec function ToggleOmniMenu()
{
	if (GFxOmniMenu.bMovieIsOpen)
		GFxOmniMenu.Close(false);
	else
		GFxOmniMenu.Start(false);
}

/**
 * Important: In UDK this function is only called during dedicated games. It must be called manually for other modes.
 * 
 * @extends
 */
simulated function NotifyLocalPlayerTeamReceived()
{
	Super.NotifyLocalPlayerTeamReceived();

	GFxOmniMenu.UpdateTeam(PlayerOwner.PlayerReplicationInfo.Team.TeamIndex);
}

defaultproperties
{
	MinimapMaterial=Material'FSAssets.HUD.minimap_render'
	MinimapPadding=(X=10,Y=55)
	LineColor=(A=255,B=0,G=255,R=0)
}