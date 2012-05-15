/**
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

var FSStructurePreview PreviewBuilding;

var float MapSize;
var Color LineColor;

// Commander mouse dragging
var bool bDragging;
var Vector2D DragStart;

function PostRender()
{
	Super.PostRender();

	GFxHUD.TickHud();
	GFxCommanderHUD.TickHUD();
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	GFxHUD = new class'FSGFxHUD';
	GFxHUD.Init();

	GFxOmniMenu = new class'FSGFxOmniMenu';
	GFxOmniMenu.Init();

	GFxCommanderHUD = new class'FSGFxCommanderHUD';
	GFxCommanderHUD.Init();

	MapSize = FSMapInfo(WorldInfo.GetMapInfo()).MapRadius * 2;
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
	local FSPlayerController FSPlayer;
	
	Super.DrawHud();

	FSPlayer = FSPlayerController(PlayerOwner);
	if (FSPlayer != None)
	{
		DrawMinimap();
		if (FSPlayer.PlacingStructureIndex != 0)
			UpdatePreviewStructure();

		if (bDragging)
			DrawSelectionBox();

		if (FSPlayer.bPlacingStructure)
			SpawnStructure(FSPlayer);
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
}

function DrawSelectionBox()
{
	local Vector2D MousePosition;

	MousePosition = GetMousePosition();
	
	Canvas.SetDrawColor(0, 255, 0);
	Canvas.SetPos(Min(DragStart.X, MousePosition.X), Min(DragStart.Y, MousePosition.Y));
	Canvas.DrawBox(Max(DragStart.X, MousePosition.X) - Min(DragStart.X, MousePosition.X), Max(DragStart.Y, MousePosition.Y) - Min(DragStart.Y, MousePosition.Y));
}

reliable client function StartPreviewStructure(byte StructureIndex)
{
	// If we are already placing a building, kill it
	if (PreviewBuilding != none)
		PreviewBuilding.Destroy();
	PreviewBuilding = Spawn(class'FSStructure'.static.GetPreviewClass(StructureIndex),,,,rot(0, 0, 0),,true);
}
reliable client function UpdatePreviewStructure()
{
	local Vector HitLocation, HitNormal, WorldOrigin, WorldDirection;

	Canvas.DeProject(GetMousePosition(), WorldOrigin, WorldDirection);
	Trace(HitLocation, HitNormal, WorldOrigin + WorldDirection * 65536.0, WorldOrigin, False, , , );
	
	PreviewBuilding.SetLocation(HitLocation);
}

function SpawnStructure(FSPlayerController FSPlayer)
{
	if (PreviewBuilding.CanBuildHere())
	{
		PreviewBuilding.Destroy();
		FSPlayer.ServerSpawnStructure(PreviewBuilding.Location, FSPlayer.PlacingStructureIndex);
	}
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
		GFxOmniMenu.Close(False);
	else
		GFxOmniMenu.Start();
}

defaultproperties
{
	MinimapMaterial=Material'FSAssets.HUD.minimap_render'
	MinimapPadding=(X=10,Y=50)
	LineColor=(A=255,B=0,G=255,R=0)
}