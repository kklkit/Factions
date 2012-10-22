/**
 * Copyright 2012 Factions Team. All Rights Reserved.
 */
class FHUD extends UDKHUD;

// Scaleform classes
var FGFxMainHud GFxMainHUD;
var FGFxHUD GFxHUD;
var FGFxOmniMenu GFxOmniMenu;
var FGFxCommanderHUD GFxCommanderHUD;
var FGFxChat GFxChat;

// Minimap
const MinimapSize=256;
const MinimapUnitBoxSize=10;
var float MapSize;
var Material MinimapMaterial;
var Vector2D MinimapPadding;
var Color LineColor;

// Mouse cursor
var bool bIsDisplayingMouseCursor;
var bool bUpdateMouseCursorOnNextTick;

// Unit selection
var bool bSelectingUnits;
var array<Pawn> UnitSelection;
var Vector2D UnitSelectionDragStart;

/**
 * @extends
 */
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Get the map size.
	MapSize = FMapInfo(WorldInfo.GetMapInfo()).MapLength;

	// Initialize all the Scaleform HUDs.
	GFxMainHUD = new class'FGFxMainHUD';
	GFxMainHUD.Init();

	GFxHUD = new class'FGFxHUD';
	GFxHUD.Init();

	GFxOmniMenu = new class'FGFxOmniMenu';
	GFxOmniMenu.Init();

	GFxCommanderHUD = new class'FGFxCommanderHUD';
	GFxCommanderHUD.Init();

	GFxChat = new class'FGFxChat';
	GFxChat.Init();
	GFxChat.Start();
}

/**
 * @extends
 */
event PostRender()
{
	Super.PostRender();

	// Update the interface elements in each HUD.
	GFxMainHUD.TickHud();
	GFxHUD.TickHud();
	GFxCommanderHUD.TickHUD();
	GFxOmniMenu.TickHUD();

	if (bUpdateMouseCursorOnNextTick)
	{
		bUpdateMouseCursorOnNextTick = False;
		UpdateHardwareMouseCursorVisibility();
	}
}

/**
 * @extends
 */
simulated function NotifyLocalPlayerTeamReceived()
{
	Super.NotifyLocalPlayerTeamReceived();

	// Close the movie clips that display mouse cursors. This is a work-around for the mouse cursor disappearing after changing teams.
	GFxOmniMenu.Close(False);
	GFxCommanderHUD.Close(False);

	// Show the player HUD if joining a team.
	if (PlayerOwner.PlayerReplicationInfo.Team != None && !GFxHUD.bMovieIsOpen)
	{
		GFxHUD.Start();
		GFxMainHUD.Start();
	}

	// Hide the player HUD if joining spectator.
	else if (PlayerOwner.PlayerReplicationInfo.Team == None && GFxHUD.bMovieIsOpen)
	{
		GFxHUD.Close(False);
		GFxMainHUD.Close(False);
	}

	// Player team has changed
	GFxOmniMenu.Invalidate("team");
}

/**
 * @extends
 */
function Message(PlayerReplicationInfo PRI, coerce string Msg, name MsgType, optional float LifeTime)
{
	local string ThePlayerName;

	if (bMessageBeep)
	{
		PlayerOwner.PlayBeepSound();
	}

	// Format the message
	if ((MsgType == 'Say') || (MsgType == 'TeamSay'))
	{
		ThePlayerName = PRI != None ? PRI.PlayerName : "";
		Msg = ThePlayerName $ ": " $ Msg;

		// Prepend (TEAM) for team messages
		if (MsgType == 'TeamSay')
		{
			Msg = "(TEAM)" @ Msg;
		}
	}

	AddConsoleMessage(Msg, class'LocalMessage', PRI, LifeTime);
}

/**
 * @extends
 */
function AddConsoleMessage(string M, class<LocalMessage> InMessageClass, PlayerReplicationInfo PRI, optional float LifeTime)
{
	local int ColorCode;

	Super.AddConsoleMessage(M, InMessageClass, PRI, LifeTime);

	switch (PRI.GetTeamNum())
	{
	case 0:
		ColorCode = 0;
		if (PRI == FTeamInfo(GetALocalPlayerController().WorldInfo.GRI.Teams[0]).Commander.PlayerReplicationInfo)
			ColorCode = 3;
		break;
	case 1:
		ColorCode = 1;
		if (PRI == FTeamInfo(GetALocalPlayerController().WorldInfo.GRI.Teams[1]).Commander.PlayerReplicationInfo)
			ColorCode = 4;
		break;
	default:
		ColorCode = 2;
		break;
	}

	if (GFxChat != None)
		GFxChat.ChatLogBoxAddNewChatLine(M, ColorCode);
}

/**
 * @extends
 * 
 * Override to prevent messages from being displayed on canvas.
 */
function DisplayConsoleMessages();

/**
 * @extends
 */
function DrawHud()
{
	Super.DrawHud();

	DrawOrders();
	DrawPlayerNames();
	DrawVehiclePassengerList();
	DrawUnitSelection();
	DrawSelectionBox();
	DrawMinimap();
}

function DrawVehiclePassengerList()
{
	local FVehicle V;
	local PlayerReplicationInfo PRI;
	local int i;
	
	Canvas.SetDrawColor(0, 255, 0);

	V = FVehicle(PlayerOwner.Pawn);

	if (V != None)
	{
		for (i = 0; i < V.Seats.Length; i++)
		{
			Canvas.SetPos(10, 100 + i * 15);

			PRI = V.PassengerPRIs[i];

			if (PRI != None)
			{
				Canvas.DrawText(i + 1 $ ":" @ PRI.PlayerName);
			}
			else
			{
				Canvas.DrawText(i + 1 $ ": Empty");
			}
		}
	}
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

		if ((Pawn(LevelActor) != None && Pawn(LevelActor).DrivenVehicle == None) || Projectile(LevelActor) != None)
		{
			UnitPosition.X = LevelActor.Location.X / MapSize * MinimapSize + Canvas.ClipX - MinimapPadding.X - (MinimapSize / 2);
			UnitPosition.Y = LevelActor.Location.Y / MapSize * MinimapSize + MinimapPadding.Y + (MinimapSize / 2);
			Canvas.SetPos(UnitPosition.X - (MinimapUnitBoxSize / 2), UnitPosition.Y - (MinimapUnitBoxSize / 2));
			Canvas.DrawBox(MinimapUnitBoxSize, MinimapUnitBoxSize);

			if (FStructure_Refinery(LevelActor) != None && (PlayerOwner.IsSpectating() || LevelActor.GetTeamNum() == PlayerOwner.GetTeamNum()))
			{
				Canvas.SetPos(UnitPosition.X, UnitPosition.Y);
				Canvas.DrawText(FStructure_Refinery(LevelActor).Resources);
			}
		}
	}
}

function DrawPlayerNames()
{
	local FPawn LevelPawn;
	local Vector LocalCoords;
	local Vector ProjectLocation;
	local string PlayerString;
	local float XL, YL;

	Canvas.SetDrawColor(0, 255, 0);
	
	foreach VisibleActors(class'FPawn', LevelPawn)
	{
		if (LevelPawn != PlayerOwner.Pawn)
		{
			PlayerString = LevelPawn.GetHumanReadableName();
			Canvas.StrLen(PlayerString, XL, YL);

			ProjectLocation = LevelPawn.Location;
			ProjectLocation.Z += LevelPawn.EyeHeight + (LevelPawn.EyeHeight / 2);

			LocalCoords = Canvas.Project(ProjectLocation);
			Canvas.SetPos(LocalCoords.X - (XL / 2), LocalCoords.Y);
			Canvas.DrawText(PlayerString);
		}
	}
}

function DrawOrders()
{
	local PlayerReplicationInfo PRI;

	foreach WorldInfo.GRI.PRIArray(PRI)
	{
		DrawOrder(FPlayerReplicationInfo(PRI).OrderLocation);
	}
}

function DrawOrder(Vector OrderLocation)
{
	local Vector ScreenCoords, CameraLoc;
	local Rotator CameraRot;

	PlayerOwner.GetPlayerViewPoint(CameraLoc, CameraRot);

	if ((OrderLocation - CameraLoc) dot Vector(CameraRot) > 0.0 && OrderLocation != vect(0,0,0))
	{
		ScreenCoords = Canvas.Project(OrderLocation);
		Canvas.SetPos(ScreenCoords.X - 25, ScreenCoords.Y - 25);
		Canvas.SetDrawColor(0, 255, 0);
		Canvas.DrawText("Move");
		Canvas.DrawBox(50, 50);
	}
}

/**
 * Draws the selection box on the screen.
 */
function DrawSelectionBox()
{
	local Vector2D MousePosition;

	if (!bSelectingUnits) return;

	MousePosition = GetMousePosition();

	Canvas.SetDrawColor(0, 255, 0);

	Canvas.SetPos(Min(UnitSelectionDragStart.X, MousePosition.X), Min(UnitSelectionDragStart.Y, MousePosition.Y));
	Canvas.DrawBox(Max(UnitSelectionDragStart.X, MousePosition.X) - Min(UnitSelectionDragStart.X, MousePosition.X), Max(UnitSelectionDragStart.Y, MousePosition.Y) - Min(UnitSelectionDragStart.Y, MousePosition.Y));
}

function DrawUnitSelection()
{
	local Pawn SelectedUnit;

	UpdateUnitSelection();

	foreach UnitSelection(SelectedUnit)
	{
		RenderSelectionBracket(SelectedUnit);
	}
}

function UpdateUnitSelection()
{
	local Pawn P;

	if (!bSelectingUnits) return;

	foreach UnitSelection(P)
		if (!IsActorSelected(P))
			UnitSelection.RemoveItem(P);

	foreach PlayerOwner.VisibleCollidingActors(class'Pawn', P, 65535.0)
		if (IsActorSelected(P) && UnitSelection.Find(P) == INDEX_NONE)
			UnitSelection.AddItem(P);
}

function bool IsActorSelected(Actor CheckActor)
{
	local Vector2D MousePosition;
	local Vector2D StartPosition;
	local Vector2D EndPosition;
	local Vector ActorScreenPosition;

	if (!bSelectingUnits) return false;

	MousePosition = GetMousePosition();
	ActorScreenPosition = Canvas.Project(CheckActor.Location);

	StartPosition.X = Min(UnitSelectionDragStart.X, MousePosition.X);
	StartPosition.Y = Min(UnitSelectionDragStart.Y, MousePosition.Y);
	EndPosition.X = Max(UnitSelectionDragStart.X, MousePosition.X);
	EndPosition.Y = Max(UnitSelectionDragStart.Y, MousePosition.Y);

	return ActorScreenPosition.X > StartPosition.X &&
		ActorScreenPosition.X < EndPosition.X &&
		ActorScreenPosition.Y > StartPosition.Y &&
		ActorScreenPosition.Y < EndPosition.Y;
}


/**
 * Draws 3D brackets around an actor.
 * From: http://udn.epicgames.com/Three/DevelopmentKitGemsCreatingActorSelectionBoxesOrBrackets.html#3D%20selection%20bracket
 */
function RenderSelectionBracket(Actor Actor)
{
	local Box ComponentsBoundingBox;
	local Vector BoundingBoxCoordinates[8], InnerBoxCoordinates[8];
	local int i;
	local float f;

	if (Actor == None) return;

	Actor.GetComponentsBoundingBox(ComponentsBoundingBox);

	// Z1
	// X1, Y1
	BoundingBoxCoordinates[0].X = ComponentsBoundingBox.Min.X;
	BoundingBoxCoordinates[0].Y = ComponentsBoundingBox.Min.Y;
	BoundingBoxCoordinates[0].Z = ComponentsBoundingBox.Min.Z;
	// X2, Y1
	BoundingBoxCoordinates[1].X = ComponentsBoundingBox.Max.X;
	BoundingBoxCoordinates[1].Y = ComponentsBoundingBox.Min.Y;
	BoundingBoxCoordinates[1].Z = ComponentsBoundingBox.Min.Z;
	// X2, Y2
	BoundingBoxCoordinates[2].X = ComponentsBoundingBox.Max.X;
	BoundingBoxCoordinates[2].Y = ComponentsBoundingBox.Max.Y;
	BoundingBoxCoordinates[2].Z = ComponentsBoundingBox.Min.Z;
	// X1, Y2
	BoundingBoxCoordinates[3].X = ComponentsBoundingBox.Min.X;
	BoundingBoxCoordinates[3].Y = ComponentsBoundingBox.Max.Y;
	BoundingBoxCoordinates[3].Z = ComponentsBoundingBox.Min.Z;

	// Z2
	// X1, Y1
	BoundingBoxCoordinates[4].X = ComponentsBoundingBox.Min.X;
	BoundingBoxCoordinates[4].Y = ComponentsBoundingBox.Min.Y;
	BoundingBoxCoordinates[4].Z = ComponentsBoundingBox.Max.Z;
	// X2, Y1
	BoundingBoxCoordinates[5].X = ComponentsBoundingBox.Max.X;
	BoundingBoxCoordinates[5].Y = ComponentsBoundingBox.Min.Y;
	BoundingBoxCoordinates[5].Z = ComponentsBoundingBox.Max.Z;
	// X2, Y2
	BoundingBoxCoordinates[6].X = ComponentsBoundingBox.Max.X;
	BoundingBoxCoordinates[6].Y = ComponentsBoundingBox.Max.Y;
	BoundingBoxCoordinates[6].Z = ComponentsBoundingBox.Max.Z;
	// X1, Y2
	BoundingBoxCoordinates[7].X = ComponentsBoundingBox.Min.X;
	BoundingBoxCoordinates[7].Y = ComponentsBoundingBox.Max.Y;
	BoundingBoxCoordinates[7].Z = ComponentsBoundingBox.Max.Z;

	// Calc inner X
	f = VSize(BoundingBoxCoordinates[4] - BoundingBoxCoordinates[5]) * 0.3f;
   
	// Z1
	// X1, Y1
	InnerBoxCoordinates[0].X = ComponentsBoundingBox.Min.X + f;
	InnerBoxCoordinates[0].Y = ComponentsBoundingBox.Min.Y;
	InnerBoxCoordinates[0].Z = ComponentsBoundingBox.Min.Z;
	// X2, Y1
	InnerBoxCoordinates[1].X = ComponentsBoundingBox.Max.X - f;
	InnerBoxCoordinates[1].Y = ComponentsBoundingBox.Min.Y;
	InnerBoxCoordinates[1].Z = ComponentsBoundingBox.Min.Z;
	// X2, Y2
	InnerBoxCoordinates[2].X = ComponentsBoundingBox.Max.X - f;
	InnerBoxCoordinates[2].Y = ComponentsBoundingBox.Max.Y;
	InnerBoxCoordinates[2].Z = ComponentsBoundingBox.Min.Z;
	// X1, Y2
	InnerBoxCoordinates[3].X = ComponentsBoundingBox.Min.X + f;
	InnerBoxCoordinates[3].Y = ComponentsBoundingBox.Max.Y;
	InnerBoxCoordinates[3].Z = ComponentsBoundingBox.Min.Z;

	// Z2
	// X1, Y1
	InnerBoxCoordinates[4].X = ComponentsBoundingBox.Min.X + f;
	InnerBoxCoordinates[4].Y = ComponentsBoundingBox.Min.Y;
	InnerBoxCoordinates[4].Z = ComponentsBoundingBox.Max.Z;
	// X2, Y1
	InnerBoxCoordinates[5].X = ComponentsBoundingBox.Max.X - f;
	InnerBoxCoordinates[5].Y = ComponentsBoundingBox.Min.Y;
	InnerBoxCoordinates[5].Z = ComponentsBoundingBox.Max.Z;
	// X2, Y2
	InnerBoxCoordinates[6].X = ComponentsBoundingBox.Max.X - f;
	InnerBoxCoordinates[6].Y = ComponentsBoundingBox.Max.Y;
	InnerBoxCoordinates[6].Z = ComponentsBoundingBox.Max.Z;
	// X1, Y2
	InnerBoxCoordinates[7].X = ComponentsBoundingBox.Min.X + f;
	InnerBoxCoordinates[7].Y = ComponentsBoundingBox.Max.Y;
	InnerBoxCoordinates[7].Z = ComponentsBoundingBox.Max.Z;

	for (i = 0; i < 8; ++i) Draw3DLine(BoundingBoxCoordinates[i], InnerBoxCoordinates[i], class'HUD'.default.GreenColor);

	// Calc inner Y
	f = VSize(BoundingBoxCoordinates[4] - BoundingBoxCoordinates[7]) * 0.3f;

	// Z1
	// X1, Y1
	InnerBoxCoordinates[0].X = ComponentsBoundingBox.Min.X;
	InnerBoxCoordinates[0].Y = ComponentsBoundingBox.Min.Y + f;
	InnerBoxCoordinates[0].Z = ComponentsBoundingBox.Min.Z;
	// X2, Y1
	InnerBoxCoordinates[1].X = ComponentsBoundingBox.Max.X;
	InnerBoxCoordinates[1].Y = ComponentsBoundingBox.Min.Y + f;
	InnerBoxCoordinates[1].Z = ComponentsBoundingBox.Min.Z;
	// X2, Y2
	InnerBoxCoordinates[2].X = ComponentsBoundingBox.Max.X;
	InnerBoxCoordinates[2].Y = ComponentsBoundingBox.Max.Y - f;
	InnerBoxCoordinates[2].Z = ComponentsBoundingBox.Min.Z;
	// X1, Y2
	InnerBoxCoordinates[3].X = ComponentsBoundingBox.Min.X;
	InnerBoxCoordinates[3].Y = ComponentsBoundingBox.Max.Y - f;
	InnerBoxCoordinates[3].Z = ComponentsBoundingBox.Min.Z;

	// Z2
	// X1, Y1
	InnerBoxCoordinates[4].X = ComponentsBoundingBox.Min.X;
	InnerBoxCoordinates[4].Y = ComponentsBoundingBox.Min.Y + f;
	InnerBoxCoordinates[4].Z = ComponentsBoundingBox.Max.Z;
	// X2, Y1
	InnerBoxCoordinates[5].X = ComponentsBoundingBox.Max.X;
	InnerBoxCoordinates[5].Y = ComponentsBoundingBox.Min.Y + f;
	InnerBoxCoordinates[5].Z = ComponentsBoundingBox.Max.Z;
	// X2, Y2
	InnerBoxCoordinates[6].X = ComponentsBoundingBox.Max.X;
	InnerBoxCoordinates[6].Y = ComponentsBoundingBox.Max.Y - f;
	InnerBoxCoordinates[6].Z = ComponentsBoundingBox.Max.Z;
	// X1, Y2
	InnerBoxCoordinates[7].X = ComponentsBoundingBox.Min.X;
	InnerBoxCoordinates[7].Y = ComponentsBoundingBox.Max.Y - f;
	InnerBoxCoordinates[7].Z = ComponentsBoundingBox.Max.Z;

	for (i = 0; i < 8; ++i) Draw3DLine(BoundingBoxCoordinates[i], InnerBoxCoordinates[i], class'HUD'.default.GreenColor);

	// Calc inner Z
	f = VSize(BoundingBoxCoordinates[0] - BoundingBoxCoordinates[4]) * 0.3f;

	// Z1
	// X1, Y1
	InnerBoxCoordinates[0].X = ComponentsBoundingBox.Min.X;
	InnerBoxCoordinates[0].Y = ComponentsBoundingBox.Min.Y;
	InnerBoxCoordinates[0].Z = ComponentsBoundingBox.Min.Z + f;
	// X2, Y1
	InnerBoxCoordinates[1].X = ComponentsBoundingBox.Max.X;
	InnerBoxCoordinates[1].Y = ComponentsBoundingBox.Min.Y;
	InnerBoxCoordinates[1].Z = ComponentsBoundingBox.Min.Z + f;
	// X2, Y2
	InnerBoxCoordinates[2].X = ComponentsBoundingBox.Max.X;
	InnerBoxCoordinates[2].Y = ComponentsBoundingBox.Max.Y;
	InnerBoxCoordinates[2].Z = ComponentsBoundingBox.Min.Z + f;
	// X1, Y2
	InnerBoxCoordinates[3].X = ComponentsBoundingBox.Min.X;
	InnerBoxCoordinates[3].Y = ComponentsBoundingBox.Max.Y;
	InnerBoxCoordinates[3].Z = ComponentsBoundingBox.Min.Z + f;

	// Z2
	// X1, Y1
	InnerBoxCoordinates[4].X = ComponentsBoundingBox.Min.X;
	InnerBoxCoordinates[4].Y = ComponentsBoundingBox.Min.Y;
	InnerBoxCoordinates[4].Z = ComponentsBoundingBox.Max.Z - f;
	// X2, Y1
	InnerBoxCoordinates[5].X = ComponentsBoundingBox.Max.X;
	InnerBoxCoordinates[5].Y = ComponentsBoundingBox.Min.Y;
	InnerBoxCoordinates[5].Z = ComponentsBoundingBox.Max.Z - f;
	// X2, Y2
	InnerBoxCoordinates[6].X = ComponentsBoundingBox.Max.X;
	InnerBoxCoordinates[6].Y = ComponentsBoundingBox.Max.Y;
	InnerBoxCoordinates[6].Z = ComponentsBoundingBox.Max.Z - f;
	// X1, Y2
	InnerBoxCoordinates[7].X = ComponentsBoundingBox.Min.X;
	InnerBoxCoordinates[7].Y = ComponentsBoundingBox.Max.Y;
	InnerBoxCoordinates[7].Z = ComponentsBoundingBox.Max.Z - f;

	for (i = 0; i < 8; ++i) Draw3DLine(BoundingBoxCoordinates[i], InnerBoxCoordinates[i], class'HUD'.default.GreenColor);
}

/**
 * Displays a hit indicator on the HUD.
 */
function DisplayHit(Vector HitDir, int Damage, class<DamageType> DamageType)
{
	local Vector Loc;
	local Rotator Rot;
	local float DirOfHit;
	local Vector AxisX, AxisY, AxisZ;
	local Vector ShotDirection;
	local bool bIsInFront;
	local Vector2D	AngularDist;

	// Figure out the directional based on the victims current view
	PlayerOwner.GetPlayerViewPoint(Loc, Rot);
	GetAxes(Rot, AxisX, AxisY, AxisZ);

	ShotDirection = Normal(HitDir - Loc);
	bIsInFront = GetAngularDistance(AngularDist, ShotDirection, AxisX, AxisY, AxisZ);
	GetAngularDegreesFromRadians(AngularDist);
	DirOfHit = AngularDist.X;

	if (bIsInFront)
	{
		DirOfHit = AngularDist.X;
		if (DirOfHit < 0)
		{
			DirOfHit += 360;
		}
	}
	else
	{
		DirOfHit = 180 + AngularDist.X;
	}

	GFxHUD.DisplayHit(DirOfHit);
}

/**
 * Returns the screen coordinates for the mouse cursor.
 */
function Vector2D GetMousePosition()
{
	return LocalPlayer(PlayerOwner.Player).ViewportClient.GetMousePosition();
}

/**
 * Updates the movieclip priorities depending on if the player is using chat.
 */
function UpdateMoviePriorities(bool bIsChatting)
{
	if (bIsChatting)
	{
		GFxChat.SetPriority(100);
	}
	else
	{
		GFxChat.SetPriority(1);
	}
}

/**
 * Shows or hides the hardware mouse depending on HUD status.
 */
function UpdateHardwareMouseCursorVisibility()
{
	if (bIsDisplayingMouseCursor)
		LocalPlayer(PlayerOwner.Player).ViewportClient.SetHardwareMouseCursorVisibility(True);
	else
		LocalPlayer(PlayerOwner.Player).ViewportClient.SetHardwareMouseCursorVisibility(False);
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

/**
 * Begins unit selection.
 */
exec function BeginUnitSelection()
{
	// Only allow drag selection in command state
	if (FPlayerController(PlayerOwner).IsInState('Commanding'))
	{
		bSelectingUnits = True;
		UnitSelectionDragStart = GetMousePosition();
	}
}

/**
 * Ends unit selection.
 */
exec function EndUnitSelection()
{
	bSelectingUnits = False;
}

/**
 * Issues the default order to the selected units.
 */
exec function IssueOrder()
{
	local Pawn SelectedUnit;

	foreach UnitSelection(SelectedUnit)
	{
		FPlayerController(PlayerOwner).ServerIssueOrder(SelectedUnit, FPlayerController(PlayerOwner).LastMouseWorldLocation);
	}
}

defaultproperties
{
	MinimapMaterial=Material'Factions_Assets.minimap_render'
	MinimapPadding=(X=10,Y=50)
}