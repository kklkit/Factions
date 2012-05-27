/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FHUD extends UDKHUD;

var FGFxHUD GFxHUD;
var FGFxOmniMenu GFxOmniMenu;
var FGFxCommanderHUD GFxCommanderHUD;

var Material MinimapMaterial;
var Vector2D MinimapPadding;
const MinimapSize=256;
const MinimapUnitBoxSize=10;

var float MapSize;
var Color LineColor;

// Commander mouse dragging
var bool bDragging;
var Vector2D DragStart;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	GFxHUD = new class'FGFxHUD';
	GFxHUD.Init();

	GFxOmniMenu = new class'FGFxOmniMenu';
	GFxOmniMenu.Init();

	GFxCommanderHUD = new class'FGFxCommanderHUD';
	GFxCommanderHUD.Init();

	MapSize = FMapInfo(WorldInfo.GetMapInfo()).MapRadius * 2;
}

event PostRender()
{
	Super.PostRender();

	GFxHUD.TickHud();
	GFxCommanderHUD.TickHUD();
	GFxOmniMenu.TickHUD();
}

simulated function NotifyLocalPlayerTeamReceived()
{
	Super.NotifyLocalPlayerTeamReceived();

	GFxOmniMenu.Invalidate("team");

	GFxOmniMenu.Close(False);
	GFxCommanderHUD.Close(False);

	if (PlayerOwner.PlayerReplicationInfo.Team != None && !GFxHUD.bMovieIsOpen)
		GFxHUD.Start();
	else if (PlayerOwner.PlayerReplicationInfo.Team == None && GFxHUD.bMovieIsOpen)
		GFxHUD.Close(False);
}

function DrawHud()
{
	local FPlayerController PlayerController;
	
	Super.DrawHud();

	PlayerController = FPlayerController(PlayerOwner);
	if (PlayerController != None)
	{
		DrawMinimap();

		if (PlayerController.PlacingStructurePreview != None)
			UpdateStructurePreview();

		if (bDragging)
			DrawSelectionBox();
	}
}

function DrawMinimap()
{
	local Actor LevelActor;
	local Vector2D UnitPosition, UnitGroundPosition;

	//@todo this should be done in scaleform once the render texture crash is fixed
	Canvas.SetPos(Canvas.ClipX - MinimapSize - MinimapPadding.X, MinimapPadding.Y);
	Canvas.DrawMaterialTile(MinimapMaterial, MinimapSize, MinimapSize, 0, 0, 1, 1);

	// Draw actor overlays on the minimap
	Canvas.SetDrawColor(0, 255, 0);
	foreach DynamicActors(class'Actor', LevelActor)
	{
		if (Pawn(LevelActor) != None || Projectile(LevelActor) != None)
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
}

function DrawSelectionBox()
{
	local Vector2D MousePosition;

	MousePosition = GetMousePosition();
	
	Canvas.SetDrawColor(0, 255, 0);
	Canvas.SetPos(Min(DragStart.X, MousePosition.X), Min(DragStart.Y, MousePosition.Y));
	Canvas.DrawBox(Max(DragStart.X, MousePosition.X) - Min(DragStart.X, MousePosition.X), Max(DragStart.Y, MousePosition.Y) - Min(DragStart.Y, MousePosition.Y));
}

function UpdateStructurePreview()
{
	local Vector HitLocation, HitNormal, WorldOrigin, WorldDirection;

	Canvas.DeProject(GetMousePosition(), WorldOrigin, WorldDirection);
	Trace(HitLocation, HitNormal, WorldOrigin + WorldDirection * 65536.0, WorldOrigin, False,,,);
	
	FPlayerController(PlayerOwner).ServerUpdateStructurePlacement(HitLocation);
}

function BeginDragging()
{
	bDragging = True;
	DragStart = GetMousePosition();
}

function EndDragging()
{
	bDragging = False;
}

function Vector2D GetMousePosition()
{
	return LocalPlayer(PlayerOwner.Player).ViewportClient.GetMousePosition();
}

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
	LineColor=(A=255,B=0,G=255,R=0)
}