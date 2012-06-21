/**
 * Initializes the Flash HUD and updates the canvas HUD.
 * 
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FHUD extends UDKHUD;

// Scaleform classes
var FGFxHUD GFxHUD;
var FGFxOmniMenu GFxOmniMenu;
var FGFxCommanderHUD GFxCommanderHUD;

// Minimap
const MinimapSize=256;
const MinimapUnitBoxSize=10;
var float MapSize;
var Material MinimapMaterial;
var Vector2D MinimapPadding;
var Color LineColor;

// Commander mouse dragging
var bool bDragging;
var Vector2D DragStart;

/**
 * @extends
 */
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Initialize all the Scaleform HUDs.
	GFxHUD = new class'FGFxHUD';
	GFxHUD.Init();
	GFxOmniMenu = new class'FGFxOmniMenu';
	GFxOmniMenu.Init();
	GFxCommanderHUD = new class'FGFxCommanderHUD';
	GFxCommanderHUD.Init();

	// Get the map size.
	MapSize = FMapInfo(WorldInfo.GetMapInfo()).MapLength;
}

/**
 * @extends
 */
event PostRender()
{
	Super.PostRender();

	// Update the interface elements in each HUD.
	GFxHUD.TickHud();
	GFxCommanderHUD.TickHUD();
	GFxOmniMenu.TickHUD();
}

/**
 * @extends
 */
simulated function NotifyLocalPlayerTeamReceived()
{
	Super.NotifyLocalPlayerTeamReceived();

	// Signal that the team information has changed.
	GFxOmniMenu.Invalidate("team");

	// Close the movie clips that display mouse cursors. This is a work-around for the mouse cursor disappearing after changing teams.
	GFxOmniMenu.Close(False);
	GFxCommanderHUD.Close(False);

	// Show the player HUD if joining a team.
	if (PlayerOwner.PlayerReplicationInfo.Team != None && !GFxHUD.bMovieIsOpen)
		GFxHUD.Start();

	// Hide the player HUD if joining spectator.
	else if (PlayerOwner.PlayerReplicationInfo.Team == None && GFxHUD.bMovieIsOpen)
		GFxHUD.Close(False);
}

/**
 * @extends
 */
function DrawHud()
{
	Super.DrawHud();

	DrawSelectionBox();
	DrawMinimap();
}

/**
 * Draws the minimap on the screen.
 */
function DrawMinimap()
{
	local Actor LevelActor;
	local Vector2D UnitPosition;

	// Draw the minimap material.
	Canvas.SetPos(Canvas.ClipX - MinimapSize - MinimapPadding.X, MinimapPadding.Y);
	Canvas.DrawMaterialTile(MinimapMaterial, MinimapSize, MinimapSize, 0, 0, 1, 1);

	// Draw actor overlays on the minimap.
	foreach DynamicActors(class'Actor', LevelActor)
	{
		if (LevelActor.GetTeamNum() == TEAM_RED)
		{
			Canvas.SetDrawColor(200, 0, 0);
			LineColor.R = 200;
			LineColor.G = 0;
			LineColor.B = 0;
		}
		else if (LevelActor.GetTeamNum() == TEAM_BLUE)
		{
			Canvas.SetDrawColor(0, 0, 255);
			LineColor.R = 0;
			LineColor.G = 0;
			LineColor.B = 255;
		}
		else
		{
			Canvas.SetDrawColor(255, 255, 255);
			LineColor.R = 255;
			LineColor.G = 255;
			LineColor.B = 255;
		}

		if (Pawn(LevelActor) != None || Projectile(LevelActor) != None)
		{
			UnitPosition.X = LevelActor.Location.X / MapSize * MinimapSize + Canvas.ClipX - MinimapPadding.X - (MinimapSize / 2);
			UnitPosition.Y = LevelActor.Location.Y / MapSize * MinimapSize + MinimapPadding.Y + (MinimapSize / 2);
			Canvas.SetPos(UnitPosition.X - (MinimapUnitBoxSize / 2), UnitPosition.Y - (MinimapUnitBoxSize / 2));
			Canvas.DrawBox(MinimapUnitBoxSize, MinimapUnitBoxSize);

			if (FStructure_Refinery(LevelActor) != None && LevelActor.GetTeamNum() == PlayerOwner.GetTeamNum())
			{
				Canvas.SetPos(UnitPosition.X, UnitPosition.Y);
				Canvas.DrawText(FStructure_Refinery(LevelActor).Resources);
			}
		}
	}
}

/**
 * Draws the drag-selection box when the mouse is held down.
 */
function DrawSelectionBox()
{
	local Vector2D MousePosition;

	if (!bDragging)
		return;

	MousePosition = GetMousePosition();
	
	Canvas.SetDrawColor(0, 255, 0);
	Canvas.SetPos(Min(DragStart.X, MousePosition.X), Min(DragStart.Y, MousePosition.Y));
	Canvas.DrawBox(Max(DragStart.X, MousePosition.X) - Min(DragStart.X, MousePosition.X), Max(DragStart.Y, MousePosition.Y) - Min(DragStart.Y, MousePosition.Y));
}

/**
 * Sets the mouse dragging status to true.
 */
function BeginDragging()
{
	bDragging = True;
	DragStart = GetMousePosition();
}

/**
 * Sets the mouse dragging status to false.
 */
function EndDragging()
{
	bDragging = False;
}

/**
 * Returns the screen coordinates for the mouse cursor.
 */
function Vector2D GetMousePosition()
{
	return LocalPlayer(PlayerOwner.Player).ViewportClient.GetMousePosition();
}

/**
 * Toggles the display of the omnimenu.
 */
exec function ToggleOmniMenu()
{
	if (GFxOmniMenu.bMovieIsOpen)
	{
		GFxOmniMenu.Close(False);
	}
	else
	{
		GFxOmniMenu.Start();
		if (PlayerOwner.Pawn != None) // Player in the world
		{
			if (FStructure_Barracks(PlayerOwner.Pawn.Base) != None)
				GFxOmniMenu.GotoPanel("Infantry");
			else if (FStructure_VehicleFactory(PlayerOwner.Pawn.Base) != None)
				GFxOmniMenu.GotoPanel("Vehicle");
		}
		else if (PlayerOwner.PlayerReplicationInfo.Team == None) // Player not on a team
		{
			GFxOmniMenu.GotoPanel("Team");
		}
	}
}

defaultproperties
{
	MinimapMaterial=Material'Factions_Assets.minimap_render'
	MinimapPadding=(X=10,Y=50)
}