/**
 * Manages the GFx movie clips and displaying the minimap.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FSHUD extends UDKHUD;

const MinimapSize=256;
const MinimapUnitBoxSize=10;

var FSGFxHUD GFxHUD;
var FSGFxOmniMenu GFxOmniMenu;
var FSGFxCommanderHUD GFxCommanderHUD;

var Material MinimapMaterial;
var Vector2D MinimapPadding;

var float MapSize;
var Color LineColor;

// Commander mouse dragging
var bool bDragging;
var Vector2D DragStart;

/**
 * @extends
 */
function PostRender()
{
	Super.PostRender();

	GFxHUD.TickHud();
}

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

	GFxCommanderHUD = new class'FSGFxCommanderHUD';
	GFxCommanderHUD.Init();

	// Set the map size for use by the minimap
	MapSize = FSMapInfo(WorldInfo.GetMapInfo()).MapRadius * 2;
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

/**
 * @extends
 */
function DrawHud()
{
	local FSPlayerController FSPlayer;
	local Actor LevelActor;
	local Vector2D UnitPosition, UnitGroundPosition;
	
	Super.DrawHud();

	FSPlayer = FSPlayerController(PlayerOwner);
	if (FSPlayer != None)
	{
		// Draw the minimap
		//@todo this should be done in scaleform once the render texture crash is fixed
		Canvas.SetPos(Canvas.ClipX - MinimapSize - MinimapPadding.X, MinimapPadding.Y);
		Canvas.DrawMaterialTile(MinimapMaterial, MinimapSize, MinimapSize, 0, 0, 1, 1);

		// Draw actor overlays on the minimap
		Canvas.SetDrawColor(0, 255, 0);
		foreach DynamicActors(class'Actor', LevelActor)
		{
			if (FSActorInterface(LevelActor) != None || Projectile(LevelActor) != None || UDKVehicle(LevelActor) != None)
			{
				UnitPosition.X = LevelActor.Location.X / (MapSize - LevelActor.Location.Z * 2) * MinimapSize + Canvas.ClipX - MinimapPadding.X - (MinimapSize / 2);
				UnitPosition.Y = LevelActor.Location.Y / (MapSize - LevelActor.Location.Z * 2) * MinimapSize + MinimapPadding.Y + (MinimapSize / 2);
				//@todo Ground position should be calculated from the actual ground
				UnitGroundPosition.X = LevelActor.Location.X / MapSize * MinimapSize + Canvas.ClipX - MinimapPadding.X - (MinimapSize / 2);
				UnitGroundPosition.Y = LevelActor.Location.Y / MapSize * MinimapSize + MinimapPadding.Y + (MinimapSize / 2);
				Canvas.SetPos(UnitPosition.X - (MinimapUnitBoxSize / 2), UnitPosition.Y - (MinimapUnitBoxSize / 2));
				Canvas.DrawBox(MinimapUnitBoxSize, MinimapUnitBoxSize);
				Canvas.Draw2DLine(UnitPosition.X, UnitPosition.Y, UnitGroundPosition.X, UnitGroundPosition.Y, LineColor);
			}
		}

		if (bDragging)
		{
			DrawSelectionBox(FSPlayer);
		}

		if (FSPlayer.bPlacingStructure)
		{
			PlaceStructure(FSPlayer);
		}
	}
}

/**
 * Draw the unit selection box.
 */
function DrawSelectionBox(PlayerController PC)
{
	local Vector2D MousePosition;

	MousePosition = GetMousePosition();
	
	Canvas.SetDrawColor(0, 255, 0);
	Canvas.SetPos(Min(DragStart.X, MousePosition.X), Min(DragStart.Y, MousePosition.Y));
	Canvas.DrawBox(Max(DragStart.X, MousePosition.X) - Min(DragStart.X, MousePosition.X), Max(DragStart.Y, MousePosition.Y) - Min(DragStart.Y, MousePosition.Y));
}

/**
 * Requests that the server place a structure at the current mouse coordinates.
 */
function PlaceStructure(FSPlayerController FSPlayer)
{
	local Vector HitLocation, HitNormal, WorldOrigin, WorldDirection;

	Canvas.DeProject(GetMousePosition(), WorldOrigin, WorldDirection);
	Trace(HitLocation, HitNormal, WorldOrigin + WorldDirection * 65536.0, WorldOrigin, true, , , );
	FSTeamGame(WorldInfo.Game).PlaceStructure(HitLocation);
	FSPlayer.bPlacingStructure = false;
}

/**
 * Called to signal that the player started dragging the mouse.
 */
function BeginDragging()
{
	bDragging = true;
	DragStart = GetMousePosition();
}

/**
 * Called to signal that mouse dragging has ended.
 */
function EndDragging()
{
	bDragging = false;
}

/**
 * Returns the hardware mouse coordinates.
 */
function Vector2D GetMousePosition()
{
	return LocalPlayer(PlayerOwner.Player).ViewportClient.GetMousePosition();
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

defaultproperties
{
	MinimapMaterial=Material'FSAssets.HUD.minimap_render'
	MinimapPadding=(X=10,Y=55)
	LineColor=(A=255,B=0,G=255,R=0)
}