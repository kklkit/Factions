/**
 * Handles updating the infantry/vehicle HUD.
 * 
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
var bool bDragging;
var Vector2D DragStart;

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

	DrawPlayerNames();
	DrawMinimap();
	DrawSelectionBox();
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

/**
 * Draws the unit selection box.
 */
function DrawSelectionBox()
{
	local Vector2D MousePosition;

	if (!bDragging) return;

	MousePosition = GetMousePosition();

	Canvas.SetDrawColor(0, 255, 0);

	Canvas.SetPos(Min(DragStart.X, MousePosition.X), Min(DragStart.Y, MousePosition.Y));
	Canvas.DrawBox(Max(DragStart.X, MousePosition.X) - Min(DragStart.X, MousePosition.X), Max(DragStart.Y, MousePosition.Y) - Min(DragStart.Y, MousePosition.Y));
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
 * Begins drag selection on the HUD.
 */
exec function BeginDragging()
{
	// Only allow drag selection in command state
	if (FPlayerController(PlayerOwner).IsInState('Commanding'))
	{
		bDragging = True;
		DragStart = GetMousePosition();
	}
}

/**
 * Ends drag selection on the HUD.
 */
exec function EndDragging()
{
	bDragging = False;
}

defaultproperties
{
	MinimapMaterial=Material'Factions_Assets.minimap_render'
	MinimapPadding=(X=10,Y=50)
}